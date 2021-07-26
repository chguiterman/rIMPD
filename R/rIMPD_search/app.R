#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(rIMPD)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Search the IMPD for North American Fire Scar Records"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(

        # Sidebar panel for inputs ----
        sidebarPanel(
            textInput(
                inputId = "investigators",
                label = h3("Investigator"),
                value = ""
            ),
            textInput(
                inputId = "species",
                label = h3("Species code"),
                value = ""
            ),
            actionButton("search_button", "Search")
        ),
        # Main panel for displaying outputs ----
        mainPanel(
            # includeMarkdown("text_intro.Rmd"),
            # Output: Data file ----
            tableOutput("contents")

        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    observeEvent(input$search_button, {
        showNotification("Searching")
        output$contents <- renderTable({
            if (!is.null(input$investigators)) {
                search_inv <- input$investigators
            } else search_inv <- NULL
            if (!is.null(input$species)) {
                search_spp <- input$spp
            } else search_spp <- NULL

            search_impd(investigators = search_inv,
                        species = search_spp
            ) %>%
                select( -c(1:3))
        },
        striped = TRUE,
        bordered = TRUE,
        specing = "xs",
        na = ""
        )
    })
}


# Run the application
shinyApp(ui = ui, server = server)
