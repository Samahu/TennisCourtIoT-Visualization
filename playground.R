library(jsonlite)

dev1_data <- db_data %>%
  filter(DeviceID == "dev-1")

dev1_data$PersonCount <- lapply(dev1_data$Classes, extractPersonCount)
x <- as.POSIXlt(dev1_data$DateTime)
plot(x, dev1_data$PersonCount, main = "Sample Time Series", xlab = "Time", ylab = "Persons")
lines(x, dev1_data$PersonCount, type="b", col="black")
#legend("top", legend = "Activity", col = "black", lty = 1)
