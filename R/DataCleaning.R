# Data Cleaning Functions

clean_data <- function(raw_data, swansites, depth) {
  samp_data <- raw_data %>%
    dplyr::filter(`Program Site Ref` %in% swansites, `Sample Depth (m)` <= depth) %>%
    dplyr::select(`Collect Date`, `Temperature (deg C)`)
  
  # Remove NA data
  samp_data <- na.omit(samp_data)
  
  # Change column names
  colnames(samp_data) <- c("t", "temp")
  
  # Change date format
  samp_data$t <- as.Date(samp_data$t, format = "%d/%m/%Y")
  
  return(samp_data)
}

average_data <- function(cleaned_data) {
  avg_temp <- cleaned_data %>%
    group_by(t) %>%
    summarise(avg_temperature = mean(temp))
}

climatologyperiod <- function() {
  note <- paste("Data available for site", swansites, "at depth <=", depth, "(m) are from", min(averaged_data$t), "to", max(averaged_data$t), ".")
  return(note)
}