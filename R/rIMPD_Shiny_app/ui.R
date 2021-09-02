
library(shiny)
library(dplyr)
library(rIMPD)
library(glue)
library(leaflet)
library(sf)
library(lubridate)
library(shinyjs)
library(shinyWidgets)


# Define UI

ui <- navbarPage(
    title = "rIMPD",
    id = "navbar",
    # 1st tab ----
    tabPanel(title = "Search the IMPD", value="tab1",
             sidebarLayout(
                 sidebarPanel(
                     useShinyjs(),
                     id = "impd_search_panel",
                     textInput( # Check out options for selectizeInput
                         inputId = "investigator",
                         label = h5("Investigator"),
                         value = ""),
                     textInput(
                         inputId = "species",
                         label = h5("Species code"),
                         value = ""),
                     fluidRow(
                         h4("Date range"),
                         fluidRow(
                             column(5,
                                    textInput(
                                        inputId = "firstYear",
                                        label = NULL,
                                        value = "",
                                        width = "100px"
                                    )),
                             column(5,
                                    textInput(
                                        inputId = "lastYear",
                                        label = NULL,
                                        value = "",
                                        width = "100px"
                                    )))
                     ),
                     sliderInput(
                         inputId = "elevation",
                         label = h5("Elevation range"),
                         min = 0,
                         max = ceiling(max(impd_meta$elevation, na.rm=TRUE)),
                         value = c(0,
                                   ceiling(max(impd_meta$elevation, na.rm=TRUE))),
                         step = 100,
                         round = -2),
                     sliderInput(
                         inputId = "latitude",
                         label = h5("Latitudinal range"),
                         min = 10,
                         max = 65,
                         value = c(18, 52),
                         step = .25,
                         round = 0),
                     sliderInput(
                         inputId = "longitude",
                         label = h5("Longitudinal range"),
                         min = -125,
                         max = -75,
                         value = c(-125, -75),
                         step = .25,
                         round = 0),
                     fluidRow(
                         align = "center",
                         column(6,
                                actionButton("search_button", "Search")
                         ),
                         column(6,
                                actionButton("reset_impd_search", "Reset inputs")
                         )
                     ),
                     checkboxInput(inputId="useDemoData", label="Or use example data",
                                   value=FALSE),
                 ),
                 # Main panel, tab1
                 mainPanel(
                     tabsetPanel(
                         tabPanel("Map",
                                  textOutput("meta_n"),
                                  br(),
                                  br(),
                                  leafletOutput("impd_map")),

                         tabPanel("Table",
                                  downloadButton("downloadData", "Download table as .csv"),
                                  br(),
                                  br(),
                                  dataTableOutput("meta_tbl"))
                     )
                 )
             )
    ),
    # 2nd tab ----
    tabPanel(title = "Retrieve FHX files", value = "tab2",
             fluidPage(
                 fluidRow(
                     column(6,
                            pickerInput(inputId = "sitePicker",
                                        label = "Select sites to import",
                                        choices = "",
                                        multiple = TRUE,
                                        options = list(
                                            `actions-box` = TRUE,
                                            size = 10,
                                            `selected-text-format` = "count > 3"
                                        ))
                     ),
                 ),
                 fluidRow(
                     column(6,
                            actionBttn(
                                inputId = "get_fhx",
                                label = "Retrieve selected fire history site files from IMPD"
                            )
                     )
                 ),
                 br(),
                 br(),
                 fluidRow(
                     column(6,
                            h4("Imported fire history site files"),
                            tableOutput("in_file_FHX")
                            )
                 ),
                 fluidRow(
                     column(6,
                            downloadButton("downloadFHX", "Download FHX files")
                            )
                 )
             ) # end-fluidpage
    ),
    # 3rd tab ----
    tabPanel(title = "Graphics", value = "tab3",
             sidebarLayout(
                     sidebarPanel(
                         useShinyjs(),
                         id = "fire_graph_control_panel",
                         # Choose sites to plot
                         pickerInput(inputId = "firePlotPicker",
                                     label = "Sites to graph",
                                     choices = "",
                                     multiple = TRUE,
                                     options = list(
                                         `actions-box` = TRUE,
                                         size = 10,
                                         `selected-text-format` = "count > 3"
                                     )),
                         # Choose facet plot
                         radioButtons(inputId = "facetPlot",
                                       label = "Plot all sites togther or in separate panels?",
                                       choices = c("One panel" = "single_plot",
                                                   "Multi-panel" = "facet_plot"),
                                       selected = "single_plot")
                     ),
                 mainPanel(
                     plotOutput("fire_graphics",
                                height = "800px")
                 )
             )
    )

    # end tabs ----
)
