library(leaflet)


navbarPage("Tennis Court Presentation", id="nav",

  tabPanel("Interactive map",
           
    div(class="outer",

      tags$head(
        # Include custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="50%"),
      
      textInput("deviceId", "Device", "dev-1"),
      plotOutput("tsplot", width="100%", height="50%"),

      tags$div(id="cite",
        'Data compiled for ', tags$em('Tulsa Tennis Court IoT Project'), '.'
      )
    )
  ),
  
  tabPanel("Data explorer",
           fluidRow(
             column(3,
                    selectInput("DevicesId", "DeviceID", c("All Ids"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=FALSE)
             )
           ),
           hr(),
           DT::dataTableOutput("table")
  ),

  conditionalPanel("false", icon("crosshair"))
)