# Data Interpolation Function

interpolate_data <- function(averaged_data) {
  # Create a sequence of daily dates
  daily_dates <- seq(min(averaged_data$t), max(averaged_data$t), by = "day")
  
  # Perform linear interpolation
  interpolated_data <- approx(averaged_data$t, averaged_data$avg_temperature, xout = daily_dates)
  
  # Convert to dataframe
  interpolated_df <- data.frame(date = interpolated_data$x, value = interpolated_data$y)
  
  # Change column names
  colnames(interpolated_df) <- c("t", "temp")
  
  return(interpolated_df)
}