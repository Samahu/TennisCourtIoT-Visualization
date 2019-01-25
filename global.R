library(mongolite)
library(leaflet)
library(dplyr)

db = mongo(url = "mongodb://localhost/TulsaTennisCourts", collection = "deviceevents")


db_data = collect(db$find('{}'))

db_summary <- db_data %>%
  group_by(DeviceID) %>%
  summarise(deviceName = first(DeviceName), latitude = mean(Latitude), longitude = mean(Longitude), events_count = n())

tulsa_long_left = -96.069
tulsa_long_right = -95.719
tulsa_lat_top  = 36.199
tulsa_lat_bottom = 35.923

center_long_range = tulsa_long_left + 0.5 * abs(tulsa_long_right - tulsa_long_left)
center_lat_range = tulsa_lat_bottom + 0.5 * abs(tulsa_lat_top - tulsa_lat_bottom)

extractPersonCount <- function(x) {
  v <- gsub("\'", "\"", x)
  v <- jsonlite::fromJSON(v)
  v <- ifelse(is.null(v$person), 0, as.numeric(v$person))
  return (v)
}