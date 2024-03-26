# Event Detection Function

detect_events <- function(interpolated_data) {
  ts <- ts2clm(interpolated_data, climatologyPeriod = c(min(interpolated_data$t), max(interpolated_data$t)))
  mhw <- detect_event(ts)
  
  return(mhw)
}