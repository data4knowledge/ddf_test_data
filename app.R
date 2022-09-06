library(shiny)
library(httr)
library(jsonlite)
library(rhandsontable)

d <- c("AAA","BBB","CCC","DDD")
e <- c("red", "white", "red", "Something")
f <- c("Code 1","Code 1","Code 1","Code 1")
mydata <- data.frame(d,e,f)
names(mydata) <- c("Name","Description","Org Code") 

g <- c("AAA","BBB","CCC","DDD")
h <- c("red", "white", "red", "Something")
amendmentdata <- data.frame(g, h)
names(amendmentdata) <- c("Effective Date","Version") 

ui <- fluidPage(
  
  titlePanel("DDF Test Data Generator (v0.1)"),
  sidebarLayout(
    
    sidebarPanel(
      #actionButton("action", "Request"),
      h4(textOutput("version")),
      textOutput("studyList")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Study & Protocol", 
                 wellPanel(
                   fluidRow(width=12,
                            column(12, h4("Basic Data"))
                   ),
                   fluidRow(width=12,
                            column(4, textInput("studyTitle", "Title:", placeholder = "Study title, free text ...")),
                            column(4, textInput("studyVersion", "Version:", placeholder = "Study version, free text ...")),
                            column(4, textInput("studyStatus", "Status:", placeholder = "Study status, free text ..."))
                   ),
                   fluidRow(width=12,
                            column(4, selectInput("studyType", "Type:", c("CROSSOVER" = "C12345","PLAIN" = "C12346"))),
                            column(4, selectInput("studyPhase", "Phase:",
                                                c("PHASE I" = "C12345",
                                                  "PHASE II" = "C12346",
                                                  "PHASE III" = "C12347")))
                           )
                ),
                
                # study_identifier: Union[List[StudyIdentifier], List[str], None] = []
                fluidRow(width=12, 
                         column ( 6, 
                                  wellPanel(
                                    h4("Study Identifiers"),
                                    rHandsontableOutput("hottable"),
                                    actionButton("save1", "Save")
                                  )
                         ),
                         column ( 6, 
                                  wellPanel(
                                    h4("Amendments"),
                                    rHandsontableOutput("amendments"),
                                    actionButton("save2", "Save")
                                  )
                         ),
                ),
                # Not Used                 
                # study_protocol_version: str
                 
                # To be Done
                # study_protocol_reference: Union[StudyProtocol, str, None] = None
                 
                fluidRow(width=12, column(12, h4("Resulting JSON"))),
                fluidRow(width=12, column(12, verbatimTextOutput("jsonview"))),
                fluidRow(width=12, column(12, h4("Save"))),
                fluidRow(width=12,
                         column(4, actionButton("action", "Submit")),
                         column(4, textOutput("result"))
                )
                
        ), 
        tabPanel("SoA", verbatimTextOutput("soa")), 
        tabPanel("Other ...", verbatimTextOutput("other"))
      )
    )
  )
)

server <- function(input, output) {

  observeEvent(input$action, {
    r <- POST("https://byrikz.deta.dev/v1/study/", body = req(json_data()))
    if (status_code(r) == 200) {
      result <- paste0("Using microservice version: ", toString(content(r)["Version"]))
    } else {
      result <- "Using microservice version: Not running, error!"
    }
    paste(result)
  })
  
  output$version <- renderText({
    r <- GET("https://byrikz.deta.dev/")
    if (status_code(r) == 200) {
      version <- paste0("Using microservice version: ", toString(content(r)["version"]))
    } else {
      version <- "Using microservice version: Not running, error!"
    }
    paste(version)
  })
  
  output$studyList <- renderText({
    r <- GET("https://byrikz.deta.dev/v1/studies/")
    if (status_code(r) == 200) {
      study_list <- content(r)
    } else {
      study_list <- "Error!"
    }
    paste(study_list)
  })

  output$study <- renderText("We will put data entry for the Study level items here...")
  output$soa <- renderText("We will put data entry for the SoA items here...")
  output$other <- renderText("We will put all the other items here...")
  
  json_data <- reactive({
    study_title = (input$studyTitle)
    study_version = (input$studyVersion)
    study_status = (input$studyStatus)
    study_type = (input$studyType)
    study_phase = (input$studyPhase)
    study_protocol_version = ("")
    df <- data.frame(study_title, study_version, study_status, study_type, study_phase, study_protocol_version)
    toJSON(unbox(df), pretty = TRUE)
  })

    output$jsonview <- renderPrint({
    req(json_data())
  })
    
  output$hottable <- renderRHandsontable({
    rhandsontable(mydata)
  })
  
  output$amendments <- renderRHandsontable({
    rhandsontable(amendmentdata)
  })

  observeEvent(input$save, { 
    si_df <- hot_to_r(input$rhandsontable)
    print(si_df)
  })
  
}

shinyApp(ui = ui, server = server)
