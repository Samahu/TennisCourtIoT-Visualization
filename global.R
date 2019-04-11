library(mongolite)
library(leaflet)
library(dplyr)
library(dotenv)

load_dot_env(file = ".env.development")

if (Sys.getenv("MONGODB_PASSWORD") == '') {
  connUrl = paste0("mongodb://",
                   Sys.getenv("MONGODB_ACCOUNT"), Sys.getenv("MONGODB_BASE_URL"), ":", Sys.getenv("MONGODB_PORT"), "/",
                   Sys.getenv("MONGODB_DBNAME"))
} else {
  connUrl = paste0("mongodb://",
                   Sys.getenv("MONGODB_ACCOUNT"), ":", Sys.getenv("MONGODB_PASSWORD"), "@",
                   Sys.getenv("MONGODB_ACCOUNT"), Sys.getenv("MONGODB_BASE_URL"), ":", Sys.getenv("MONGODB_PORT"), "/",
                   Sys.getenv("MONGODB_DBNAME"), "?ssl=true")
}

db = mongo(url = connUrl, collection = "deviceevents")
db_data = collect(db$find('{}'))
db_data <- jsonlite::flatten(db_data)
matches <- stringr::str_match(names(db_data), "Classes.(.+)")
db_class_ids_idx <- which(!is.na(matches[, 2]))
db_class_ids <- matches[db_class_ids_idx, 2]

db_data$DateTimeT <- as.POSIXct(db_data$DateTime)
db_data$Longitude <- NULL
db_data$Latitude <- NULL

# Generate random set of locations
constructDevicesDB <- function(deviceIds) {
  
  tulsa_lat_top  = 36.199
  tulsa_lat_bottom = 35.923
  tulsa_long_left = -96.069
  tulsa_long_right = -95.719


  deviceCount <- length(deviceIds)
  latitude <- runif(deviceCount, tulsa_lat_bottom, tulsa_lat_top)
  longitude <- runif(deviceCount, tulsa_long_left, tulsa_long_right)

  return (data_frame(DeviceID = deviceIds, Latitude = latitude, Longitude = longitude))
}

if ( !("DeviceID" %in% names(db_data)) ){
  db_data$DeviceID <- db_data$DeviceName
}

deviceIds <- unique(db_data$DeviceID)
db_devices <- constructDevicesDB(deviceIds)
db_data <- db_data %>% left_join(db_devices)

db_summary <- db_data %>%
  group_by(DeviceID) %>%
  summarise(deviceName = first(DeviceName), latitude = mean(Latitude), longitude = mean(Longitude), events_count = n())
