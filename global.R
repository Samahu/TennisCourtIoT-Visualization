library(mongolite)
library(leaflet)
library(dplyr)
library(dotenv)

load_dot_env(file = ".env.development")

Sys.setenv(TZ="America/Chicago")  # TODO: hardcoded for now. However, this should depend on the location of the device.

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
db_data$DeviceName <- NULL

db_data$DateTimeT <- as.POSIXct(db_data$DateTime)

# Generate random set of locations
devicesDB <- function() {
  db_deviceinfos = mongo(url = connUrl, collection = "deviceinfos")
  return (collect(db_deviceinfos$find('{}')))
}

db_devices <- devicesDB()
db_data <- db_data %>% left_join(db_devices, by = "DeviceId")

db_summary <- db_data %>%
  group_by(DeviceId) %>%
  summarise(deviceName = first(DeviceName), latitude = mean(Latitude), longitude = mean(Longitude), events_count = n())
