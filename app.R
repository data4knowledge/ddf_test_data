library(shiny)
library(httr)

ui <- fluidPage(
  
  titlePanel("DDF Test Data Generator (v0.1)"),
  sidebarLayout(
    
    sidebarPanel(
      #actionButton("action", "Request"),
      h4(textOutput("version"))
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Study & Protocol", 
                 fluidRow(width=12,
                          column(12,verbatimTextOutput("study"))
                 ),
                 fluidRow(width=12,
                          column(12,textInput("studyTitle", "Study Title", "Study title ...")),
                 )
        ), 
        tabPanel("SoA", verbatimTextOutput("soa")), 
        tabPanel("Other ...", verbatimTextOutput("other"))
      )
    )
  )
  
  
)

server <- function(input, output) {

  observeEvent(input$action, {})
  
  output$version <- renderText({
    r <- GET("https://byrikz.deta.dev/")
    if (status_code(r) == 200) {
      version <- paste0("Using microservice version: ", toString(content(r)["Version"]))
    } else {
      version <- "Using microservice version: Not running, error!"
    }
    paste(version)
  })
  
  output$study <- renderText("We will put data entry for the Study level items here...")
  output$soa <- renderText("We will put data entry for the SoA items here...")
  output$other <- renderText("We will put all the other items here...")
  
}

shinyApp(ui = ui, server = server)
