library(leaflet)


navbarPage("Tennis Court Presentation", id="nav",

  tabPanel("Interactive map",
           
    div(class="outer",

      tags$head(includeCSS("styles.css"), includeScript("gomap.js")),

      leafletOutput("map", width="100%", height="50%"),
      
      selectInput("deviceId", "Device:", structure(db_summary$DeviceID, names=db_summary$deviceName)),
      selectInput("average", "Average:", structure(c("h", "d", "w", "m", "y"), names=c("Hourly", "Daily", "Weekly", "Monthly", "Yearly"))),
      dateRangeInput("dates", 
                     "Date range",
                     start = "2019-01-01", 
                     end = as.character(Sys.Date())),
      plotOutput("tsplot", width="100%", height="50%"),

      tags$div(id="cite",
        'Data compiled for ', tags$em('Tulsa Tennis Court IoT Project'), '.'
      )
    )
  ),
  
  tabPanel("Data explorer",
           fluidRow(
             column(3,
                    selectInput("DevicesId", "DeviceID", structure(db_summary$DeviceID, names=db_summary$deviceName), multiple=FALSE)
             )
           ),
           hr(),
           DT::dataTableOutput("table")
  ),

  conditionalPanel("false", icon("crosshair"))
)