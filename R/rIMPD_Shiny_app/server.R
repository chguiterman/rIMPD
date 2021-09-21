library(dplyr)
library(tidyr)
library(purrr)
library(burnr)
library(zip)
library(ggplot2)



# Define server
server <- function(input, output, session) {

  # tab1, impd search ----
  # Sidebar search params

  input_inv <- eventReactive(input$search_button, {
    if (input$investigator == ""){
      return(NULL)
    } else return(input$investigator)
  })
  input_spp <- eventReactive(input$search_button, {
    if (input$species == "") {
      return(NULL)
    } else return(input$species)
  })
  input_elev <- eventReactive(input$search_button, {
    c(input$elevation[1], input$elevation[2])
  })
  input_lat <- eventReactive(input$search_button, {
    c(input$latitude[1], input$latitude[2])
  })
  input_lon <- eventReactive(input$search_button, {
    c(input$longitude[1], input$longitude[2])
  })
  input_first_yr <- eventReactive(input$search_button, {
    if (input$firstYear == ""){
      return(NULL)
    } else return(input$firstYear)
  })
  input_last_yr <- eventReactive(input$search_button, {
    if (input$lastYear == ""){
      return(NULL)
    } else return(input$lastYear)
  })
  # reset inputs
  observeEvent(input$reset_impd_search, {
    reset("impd_search_panel")
  })


  # Perform IMPD search

  impd_api_result <- eventReactive(input$search_button, {
    showNotification("Searching")
    ncei_paleo_api(investigators = input_inv(),
                                 species = input_spp(),
                                 minElev = input_elev()[1],
                                 maxElev = input_elev()[2],
                                 minLat = input_lat()[1],
                                 maxLat = input_lat()[2],
                                 minLon = input_lon()[1],
                                 maxLon = input_lon()[2],
                                 earliestYear = input_first_yr(),
                                 latestYear = input_last_yr()
    )
  })

  search_meta <- reactive({
    if (input$search_button) {
      return(build_impd_meta(impd_api_result()))
    }
    if (input$useDemoData) {
      return(rIMPD::quga_dat %>%
               select(-FHX)
             )
    }
  })

  output$meta_n <- renderText({
    glue("This search yielded {nrow(search_meta())} results")
  })


  # Map tab ----------------------------------------------------------------

  impd_meta <- rIMPD::impd_meta %>%
    st_as_sf(coords = c("longitude", "latitude"), crs=4326)

  search_map_df <- eventReactive(search_meta(), {
      search_meta() %>%
        st_as_sf(coords = c("longitude", "latitude"),
                 remove=FALSE, crs=4326)
  })

  output$impd_map <- renderLeaflet({
    leaflet(impd_meta) %>%
      addProviderTiles(providers$Esri.WorldImagery, "Satellite") %>%
      addProviderTiles(providers$Thunderforest.Outdoors,
                       options = tileOptions(apikey = 'a9d0362ca8e5483a98c4653356dd7661'),
                       group = "Topography") %>%
      addCircleMarkers(radius = 4,
                       fillOpacity = .2,
                       weight = 1,
                       fillColor = "yellow",
                       color = "yellow") %>%
      addLayersControl(
        baseGroups = c("Satellite", "Topography"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      fitBounds(-125, 15, -73, 51.5)
  })

  observeEvent(search_map_df(), {
    leafletProxy("impd_map", data = search_map_df()) %>%
      clearMarkers() %>%
      addCircleMarkers(data = impd_meta,
                       radius = 4,
                       fillOpacity = .2,
                       weight = 1,
                       fillColor = "yellow",
                       color = "yellow") %>%
      addCircleMarkers(data = search_map_df(),
                       radius = 4,
                       fillOpacity = .9,
                       opacity = .9,
                       weight = 1,
                       color = "white",
                       fillColor = "purple") %>%
      fitBounds(~min(longitude), ~min(latitude),
                ~max(longitude), ~max(latitude)) %>%
      addMiniMap(
        tiles = providers$Esri.WorldImagery,
        position = 'topright',
        width = 50, height = 50,
        toggleDisplay = FALSE,
        zoomLevelFixed = TRUE)

  })

  # Table tab ---------------------------------------------------------------
  output$downloadData <- downloadHandler(
    # filename = glue("{format(now(), '%Y-%m-%d_%H%M')}_IMPD_search_results.csv"),
    filename = "IMPD_Search_Metadata.csv",
    content = function(file) {
      write.csv(search_meta(), file, row.names = FALSE)
    }
  )
  output$meta_tbl <- renderDataTable({
    search_meta()
  })

# Tab2 -- FHX file retrieval ----------------------------------------------

  sites_to_get <- reactive({
    glue("{search_meta()$siteName} ({search_meta()$studyCode})")
  })
  observe({
      updatePickerInput(session = session,
                        inputId = "sitePicker",
                        choices = sites_to_get()
                        )
    })

  FHX_df <- reactive({
    if (input$useDemoData) {
      return(rIMPD::quga_dat)
    }
    if (input$get_fhx) {
      search_meta()[[2]] %>%
        filter(studyCode %in% gsub(".*[(]([^.]+)[)]", "\\1", input$sitePicker)) %>%
        mutate(FHX = map(studyCode, ~ get_impd_fhx(.x)))
    }
  })

  output$in_file_FHX <- renderTable({
    req(FHX_df())
    FHX_df() %>%
      transmute(studyCode,
                `Number of trees` = map_int(FHX, ~ length(series_names(.x)))
      )
  })

  # Download script for FHX files to .zip
  Sys.setenv(R_ZIPCMD="/usr/bin/zip")
  output$downloadFHX <- downloadHandler(
    filename = "FHX_Export.zip",
    content = function(file) {
      tmpdir <- tempdir()
      setwd(tempdir())
      print(tempdir())

      fhx_files <- glue("{FHX_df()$studyCode}.fhx")
      for (i in 1:length(fhx_files)) {
        write_fhx(x = FHX_df()$FHX[[i]],
                  fname = fhx_files[i])
      }
      zip(file, fhx_files)
    },
    contentType = "application/zip"
  )

# Tab3 -- fire history graphics -------------------------------------------

  sites_to_plot <- reactive({
    glue("{FHX_df()$siteName} ({FHX_df()$studyCode})")
  })

 # Provide sites to plot in picker tool
  observe({
    updatePickerInput(session = session,
                      inputId = "firePlotPicker",
                      choices = sites_to_plot()
    )
  })

 # Subset plotting meta from user-selected sites
  plot_FHX_df <- eventReactive(input$firePlotPicker, {
    FHX_df() %>%
    filter(studyCode %in% gsub(".*[(]([^.]+)[)]", "\\1", input$firePlotPicker)) %>%
      mutate(SERIES = map(FHX, series_names))
  })

 # Build tree-level meta for plot facets
  plot_FHX_meta <- reactive({
    plot_FHX_df() %>%
      select(siteName, studyCode, series = SERIES) %>%
      unnest(cols = series) %>%
      mutate(type = "Tree")
  })

 # Create composites
  fhx_comps <- reactive({
    if (input$plot_composite_on) {
      plot_FHX_df %>%
        mutate(COMP = map2(FHX, studyCode,
                           ~ composite(.x,
                                       comp_name = .y))
               ) %>%
        select(COMP) %>%
        unnest(cols = COMP) %>%
        as_fhx()
    }
  })
  plot_comp_meta <- eventReactive(fhx_comps(), {
    plot_FHX_meta() %>%
      group_by(studyCode) %>%
      summarize(series = studyCode,
                type = "Composite")
  })

  ## TODO -- combine comp meta and tree meta for facets
 # build fhx object to plot
  fhx_obj <- reactive({
    x <- plot_FHX_df() %>%
      select(FHX) %>%
      unnest(cols = FHX) %>%
      as_fhx()  ## Add sorting here??
    if (any(
      input$plot_sorting %in% c("first_year",
                                  "last_year")
    )) {
      x <- sort(x, sort_by = input$plot_sorting,
                decreasing = input$sort_decrease)
    }
    return(x)
  })

  ## plot parameters

  # X-axis years
  observe({
    new_min <- round(min(fhx_obj()$year), -1)
    new_max <- round(max(fhx_obj()$year), -1)
    updateSliderInput(session = session,
                      inputId = "plot_yr_range",
                      min = new_min,
                      max = new_max,
                      value = c(new_min, new_max)
    )
  })

 # Plot results
  output$fire_graphics <- renderPlot({
    req(fhx_obj())
    if (input$facetPlot == "single_plot") {
      p <-  plot_demograph(fhx_obj(),
                           ylabels = ! input$plot_removeY,
                           plot_legend = input$plot_legend,
                           composite_rug = input$plot_composite_on
                           )
    }
    if (input$facetPlot == "facet_plot") {
      p <- plot_demograph(fhx_obj(),
                          facet_group = plot_FHX_meta()$siteName,
                          facet_id = plot_FHX_meta()$series,
                          ylabels = ! input$plot_removeY,
                          plot_legend = input$plot_legend
                          )
    }
    p +
      scale_x_continuous(limits = c(input$plot_yr_range[1],
                                    input$plot_yr_range[2]),
                           breaks = seq(min(pretty(fhx_obj()$year)),
                                        max(pretty(fhx_obj()$year)),
                                        50),
                         sec.axis=dup_axis(name=''),
                         minor_breaks = seq(min(pretty(fhx_obj()$year)),
                                            max(pretty(fhx_obj()$year)),
                                            50),
                         expand = c(0, 0)) +
      theme(text = element_text(size=18)) +
      theme(axis.line = element_line(color = "black"),
            axis.ticks.x = element_line(unit(5, "points"), color = "black"),
            panel.grid.major.x = element_line(color = "grey70"),
            panel.grid.minor.x = element_line(color = "grey85"),
            legend.title = element_blank(),
            # legend.margin = margin(c(5, 5, 5, 0)),
            legend.text = element_text(margin = margin(l = 0,
                                                       r = 0,
                                                       unit = "pt"))
      )
  })


  # end server----
}


