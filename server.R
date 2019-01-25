library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(htmltools)

function(input, output, session) {

  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      addCircleMarkers(lng=db_summary$longitude, lat=db_summary$latitude,
                       popup = htmlEscape(db_summary$deviceName),radius = db_summary$events_count)
  })
  
  output$table <- DT::renderDataTable({
    
    df <- db_summary
    action <- DT::dataTableAjax(session, df)
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)

  })
  
  dataInput <- reactive({
    dev_data <- db_data %>%
      filter(DeviceID == input$deviceId)
    dev_data$PersonCount <- lapply(dev_data$Classes, extractPersonCount)
    
    return (dev_data)
  })
  
  output$tsplot <- renderPlot({
    di <- dataInput()
    x <- as.POSIXlt(di$DateTime)
    plot(x, di$PersonCount, main = "Sample Time Series", xlab = "Time", ylab = "Persons")
    lines(x, di$PersonCount, type="b", col="black")
  })
}