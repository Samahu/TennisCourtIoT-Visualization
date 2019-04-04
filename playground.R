library(jsonlite)
library(ggplot2)
library(lubridate)

dev1_data <- db_data %>%
  filter(DeviceID == "dev-1")


dev2_data <- dev1_data %>%
  filter(DateTimeT >= as.POSIXct("2019-01-01"), DateTimeT <= as.POSIXct("2019-01-06"))

dev2_data$DateTimeS <- as.POSIXct(dev2_data$DateTimeT, format="%d/%m/%y %H")

dev2_data <- dev2_data %>%
  group_by(DateTimeS) %>%
  summarise(deviceName = first(DeviceName), PersonCountS = sum(Classes.person, na.rm = TRUE))

ggplot(dev2_data) +
  geom_point(aes(DateTimeS, PersonCountS))