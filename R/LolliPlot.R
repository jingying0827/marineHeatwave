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
# Determine the event count to be highlighted (for lolli plot), the top x highest event will be in brighter red colour than others. The graph plotted here is adapted from the lolli_plot() function in the heatwaveR package, using ggplot().
event_count = 3


# Data Transformation
# Run the code below to transform your data into the correct format to plot graph, rerun this every time you change your site and/or desired depth data.
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
interpolated_data = interpolate_data(averaged_data) 
mhw = detect_events(interpolated_data)


# Data Visualization Function

visualize_lolli_plot <- function(mhw, event_count, start_date_plot, end_date_plot) {
  filtered_events <- mhw$event[mhw$event$date_peak >= start_date_plot & mhw$event$date_peak <= end_date_plot, ]
  footnote <- glue::glue("* The event highlighted is the top ", event_count, " largest event based on the selected timeframe (START and END date of this plot),\n   instead of the whole period of data.")
  ggplot(filtered_events, aes(x = date_start, y = intensity_max)) +
    geom_lolli(colour = "salmon", colour_n = "red", n = 3) +
    labs(y = expression(paste("Max. intensity [", degree, "C]")), caption = footnote) +
    theme_bw() +
    theme(plot.caption = element_text(hjust = 0))
}


# Plot graph
# Run the code below to plot the graph, rerun this every time you change variable.
visualize_lolli_plot(mhw, event_count, start_date_plot, end_date_plot)