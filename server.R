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
      filter(DeviceId == input$deviceId,
             DateTimeT >= as.POSIXct(input$dates[1], tz=getOption("tz")),
             DateTimeT <= as.POSIXct(input$dates[2], tz=getOption("tz")))
    
    dev_data$DateTimeS <- round_date(dev_data$DateTimeT, input$average)

    dev_data_s <- dev_data %>%
      group_by(DateTimeS) %>%
      summarise(first(db_devices[db_devices$DeviceId == input$deviceId, ]$DeviceName),
                visits = mean(switch(input$classId,
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
      addMarkers(layerId=db_devices$DeviceId,
                 lng=db_devices$Longitude, lat=db_devices$Latitude,
                 popup = htmlEscape(db_devices$DeviceName),
                 clusterOptions = markerClusterOptions())
  })
  
  observeEvent( input$map_marker_click, {
  
    if (is.null(input$map_marker_click))
      return()
    
    updateSelectInput(session, "deviceId", selected = input$map_marker_click$id)
  })
  
  capitalize_first_letter_of_string  <- function(value) {
    paste0(toupper(substr(value, 1, 1)), substr(value, 2, nchar(value)))
  }

  output$tsplot <- renderPlot({
    di <- deviceData()
    di$visits[is.na(di$visits)] <- 0
    
    # assign the number of breaks in propertion to the number of samples
    samples <- seq.POSIXt(as.POSIXct(input$dates[1], tz=getOption("tz")),
                          as.POSIXct(input$dates[2], tz=getOption("tz")),
                          by=input$average)
    samples_count <- length(samples)
    
    divider <- 1
    max_breaks <- 30
    if (samples_count > max_breaks) {
      divider <- round(samples_count / max_breaks)
    }
    
    custom_date_break <- paste(divider, input$average)
    y_label <- capitalize_first_letter_of_string(input$classId)
    y_label <- paste0(y_label, "(s)")
    
    ggplot(di, aes(DateTimeS, visits)) +
      geom_bar(stat = "identity") +
      labs(x = "Time", y = y_label, title = "Average Visits") +
      scale_x_datetime(date_breaks = custom_date_break, labels = date_format("%b %d - %H:%M")) +
      theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))
  })
  
  output$pieplot <- renderPlot({
    
    di <- deviceData()
    di$visits[is.na(di$visits)] <- 0
    
    # assign the number of breaks in propertion to the number of samples
    samples <- seq.POSIXt(as.POSIXct(input$dates[1], tz=getOption("tz")),
                          as.POSIXct(input$dates[2], tz=getOption("tz")),
                          by=input$average)
    samples_count <- length(samples)
    actual_visits <- nrow(di[di$visits!=0,]) # only count records that have actual visits
    total <- samples_count + actual_visits

    df <- data.frame(
      "Utilization" = c("Occupied", "Free"),
      "Value" = c(actual_visits / total, (samples_count - actual_visits) / total)
    )
    
    footnote = if (input$average=="hour") "Hourly utilization excludes night times between 10 pm to 6 am" else ""
    
    #print(paste("total:", samples_count, "records", nrow(di)))

    ggplot(df, aes(x="", y=Value, fill=Utilization)) +
      geom_bar(width = 1, stat = "identity") +
      coord_polar("y", start=0) +
      geom_text(aes(label = paste0(round(Value*100), "%")), position = position_stack(vjust = 0.5)) +
      labs(x = NULL, y = NULL, fill = NULL, title = "Court Utilization", caption = footnote) +
      theme_classic() +
      theme(axis.line = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            plot.title = element_text(hjust = 0.5, color = "#666666"))
  })
}