
sbp <- sidebarPanel(
  
  selectInput("deviceId", "Device:", structure(db_summary$DeviceID, names=db_summary$deviceName)),
  selectInput("average", "Average:", structure(c("hour", "day", "week", "month", "quarter", "year"), names=c("Hourly", "Daily", "Weekly", "Monthly", "Quarterly", "Yearly"))),
  dateRangeInput("dates", 
                 "Date range",
                 start = "2019-01-01", 
                 end = as.character(Sys.Date())),
  width = 3
)

navbarPage("Tennis Court Presentation", id="nav",

  tabPanel("Interactive map",
           
    div(class="outer",

      tags$head(includeCSS("styles.css"), includeScript("gomap.js")),

      leafletOutput("map", width="100%", height="60%"),
      
      
      
      sidebarLayout(sidebarPanel = sbp,
      mainPanel = mainPanel(
        plotOutput("tsplot", width="100%", height="300"))),

      tags$div(id="cite",
        'Data compiled for ', tags$em('Tulsa Tennis Court IoT Project'), '.'
      )
    )
  )
  
  ,

  tabPanel("Data explorer",
           fluidRow(
             column(3,
                    selectInput("DevicesId", "DeviceID", structure(db_summary$DeviceID, names=db_summary$deviceName), multiple=FALSE)
             )
           ),
           hr(),
           DT::dataTableOutput("table")
  )
)