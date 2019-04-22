library(shiny)
library(shinyjs)
library(shinyBS)

sbp <- sidebarPanel(id="sidePanel",
  
  selectInput("deviceId", "Device:", structure(db_summary$DeviceId, names=db_summary$deviceName)),
  selectInput("classId", "Class:", db_class_ids, selected = "person"),
  selectInput("average", "Average:", structure(c("hour", "day", "week", "month", "quarter", "year"), names=c("Hourly", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly"))),
  dateRangeInput("dates", 
                 "Date range",
                 start = "2019-04-01", 
                 end = as.character(Sys.Date()+1)),
  width = 3
)

navbarPage("Tennis Court Presentation", id="nav",

  tabPanel("Interactive map",
           fluidPage(
             useShinyjs(),
             leafletOutput("map"),
             sidebarLayout(sidebarPanel = sbp, mainPanel = mainPanel(id="MainPanel", plotOutput("tsplot", width="100%", height="300"))),

            tags$div(id="cite", 'Data compiled for ', tags$em('Tulsa Tennis Court IoT Project'), '.')
            )
      )
  
  # ,
  # 
  # tabPanel("Data explorer",
  #          fluidRow(
  #            column(3,
  #                   selectInput("DevicesId", "DeviceId", structure(db_summary$DeviceID, names=db_summary$deviceName), multiple=FALSE)
  #            )
  #          ),
  #          hr(),
  #          DT::dataTableOutput("table")
  # )
)