library(shiny)
library(httr)

ui <- fluidPage(
  actionButton("action", "Request"),
  textOutput("version"),
  
  textInput("studyTitle", "Study Title", "Study title ...")
  
)

server <- function(input, output) {

  observeEvent(input$action, {})
  
  output$version <- renderText({
    r <- GET("https://byrikz.deta.dev/")
    paste(toString(content(r)["System"]))
  })
}

shinyApp(ui = ui, server = server)
