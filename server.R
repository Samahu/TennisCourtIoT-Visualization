library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(htmltools)
library(ggplot2)
library(lubridate)

function(input, output, session) {
  
  deviceData <- reactive({
    
    dev_data <- db_data %>%
      filter(DeviceID == input$deviceId,
             DateTimeT >= as.POSIXct(input$dates[1]),
             DateTimeT <= as.POSIXct(input$dates[2]))
    
    dev_data$DateTimeS <- round_date(dev_data$DateTimeT, input$average)
    
    summary_func <- ifelse(TRUE, mean, sum)

    dev_data_s <- dev_data %>%
      group_by(DateTimeS) %>%
      summarise(deviceName = first(DeviceName),
                SummarizedClass = summary_func(switch(input$classId,
                                                     "person" = Classes.person,
                                                     "dog" = Classes.dog,
                                                     "cat" = Classes.cat,
                                                     "bird" = Classes.bird,
                                                     "car" = Classes.car,
                                                     "motorcycle" = Classes.motorcycle,
                                                     "bicycle" = Classes.bicycle,
                                                     "bus" = Classes.bus,
                                                     "truck" = Classes.truck), na.rm = TRUE))
    
    return (dev_data_s)
  })

  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      addMarkers(layerId=db_summary$DeviceID, lng=db_summary$longitude, lat=db_summary$latitude,
                       popup = htmlEscape(db_summary$deviceName))
  })
  
  observeEvent( input$map_marker_click, {
  
    if (is.null(input$map_marker_click))
      return()
    
    updateSelectInput(session, "deviceId", selected = input$map_marker_click$id)
  })
  
  output$table <- DT::renderDataTable({
    df <- db_summary
    action <- DT::dataTableAjax(session, df)
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })
  
  output$tsplot <- renderPlot({
    di <- deviceData()
    di$SummarizedClass[is.na(di$SummarizedClass)] <- 0
    ggplot(di) +
      geom_line(aes(DateTimeS, SummarizedClass, color=SummarizedClass)) +
      labs(x = "Time", y = input$classId, title = "Visits Over Time")
  })
}