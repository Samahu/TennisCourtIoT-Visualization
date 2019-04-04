library(mongolite)
library(leaflet)
library(dplyr)
library(dotenv)

load_dot_env(file = ".env.development")

extractPersonCount_Str <- function(x) {
  v <- gsub("\'", "\"", x)
  v <- jsonlite::fromJSON(v)
  v <- ifelse(is.null(v$person), 0, as.numeric(v$person))
  return (v)
}

extractPersonCount <- function(x) {
  v <- ifelse(is.na(x), 0, as.numeric(x))
  return (v)
}

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

db_data$PersonCount <- sapply(db_data$Classes$person, extractPersonCount)
db_data$DateTimeT <- as.POSIXct(db_data$DateTime)

#TODO: A workaround to get reactive expression be able to execute without a warning - remove Classes column.
drops <- c("Classes")
db_data <- db_data[, !(names(db_data) %in% drops)]

db_summary <- db_data %>%
  group_by(DeviceID) %>%
  summarise(deviceName = first(DeviceName), latitude = mean(Latitude), longitude = mean(Longitude), events_count = n())

tulsa_long_left = -96.069
tulsa_long_right = -95.719
tulsa_lat_top  = 36.199
tulsa_lat_bottom = 35.923

center_long_range = tulsa_long_left + 0.5 * abs(tulsa_long_right - tulsa_long_left)
center_lat_range = tulsa_lat_bottom + 0.5 * abs(tulsa_lat_top - tulsa_lat_bottom)