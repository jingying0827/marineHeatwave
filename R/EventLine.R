# Variables to be changed

# Step 1 (Select your site)
# Select a site from: (ARM, BLA, FP1, FP7, FP22, CAV, HEA, NAR, NIL, STJ, MAY, RON, KIN, SUC, MEAD, MULB, WMP, REG, MSB, POL, SANDBR, KMO, JBC, VIT).
swansites <- c('ARM')

# Step 2 (Select your desired depth data)
# Determine the depth measured you want to filter the data, the filtered data will only included data with depth less than or equal to the depth you set.
depth = 2
# do not change the code below
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
climatologyperiod()

# Step 3
# Determine start and end date for data visualization, this can only within the available date period outlined in Step 2.
start_date_plot = "2010-04-12"
end_date_plot = "2012-12-12"

# Step 4
# Determine the period (day) before & after the peak event you want the graph to show (for event line plot); and determine if you want the plot to be categorised.
# The metric tells the function how to choose the event that should be highlighted as the 'greatest' of the events in the chosen period. You may choose from the following options: intensity_mean, intensity_max, intensity_var,intensity_cumulative, intensity_mean_relThresh, intensity_max_relThresh, intensity_var_relThresh, intensity_cumulative_relThresh, intensity_mean_abs, intensity_max_abs, intensity_var_abs, intensity_cumulative_abs, rate_onset, rate_decline.
# The plot may not necessarily correspond to the biggest event of the specified metric within the entire time series; instead, this plot shows the biggest event within the start_date_plot and end_date_plot you chose.
# To plot the largest event within the whole time series, make sure you chose the start_date_plot and end_date_plot that cover the whole time series.
spread = 180
category = FALSE
metric = "intensity_cumulative"


# Data Transformation
# Run the code below to transform your data into the correct format to plot graph, rerun this every time you change your site and/or desired depth data.
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
interpolated_data = interpolate_data(averaged_data) 
mhw = detect_events(interpolated_data)


# Data Visualization Function

visualize_event_line <- function(mhw, spread, metric, start_date_plot, end_date_plot, category) {
  footnote <- glue::glue(
    "* Temperature :  daily sea surface temperature. \n",
    "* Climatology   :  is calculated based on {min(averaged_data$t)} to {max(averaged_data$t)}. \n",
    "* Threshold      :  the 90th percentile (default) of daily sea surface temperature. \n", 
    "* The event highlighted is the largest event based on the selected timeframe (START and END date of this plot),\n",
    "   instead of the whole period of data.")
  messages <- "No events detected within the selected period. Please choose another date period."
  
  if(category) {
    plot <- tryCatch(
      event_line(mhw, spread = spread, metric = metric, start_date = start_date_plot, end_date = end_date_plot, category = TRUE),
      error = function(e) {
        message(messages)
        return(messages)
      }
    )
  } else {
    plot <- tryCatch(
      event_line(mhw, spread = spread, metric = metric, start_date = start_date_plot, end_date = end_date_plot),
      error = function(e) {
        message(messages)
        return(messages)
      }
    )
  }
  
  if(is.character(plot)) {
    return(plot)  # Return the message directly
  } else {
    plot <- plot + labs(caption = footnote) +
      theme(plot.caption = element_text(hjust = 0))
    return(plot)
  }
}


# Plot graph
# Run the code below to plot the graph, rerun this every time you change variable.
visualize_event_line(mhw, spread, metric, start_date_plot, end_date_plot, category)