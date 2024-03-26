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


# Data Transformation
# Run the code below to transform your data into the correct format to plot graph, rerun this every time you change your site and/or desired depth data.
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
interpolated_data = interpolate_data(averaged_data) 
mhw = detect_events(interpolated_data)


# Data Visualization Function

visualize_bubble_plot <- function(mhw, start_date_plot, end_date_plot) {
  filtered_events <- mhw$event[mhw$event$date_peak >= start_date_plot & mhw$event$date_peak <= end_date_plot, ]
  footnote <- ("* The event highlighted is the event that exceeds the temperature threshold set within the selected timeframe\n   (START and END date of this plot), instead of the whole period of data.")
  ggplot(filtered_events, aes(x = date_peak, y = intensity_max)) +
    geom_point(aes(size = intensity_cumulative), shape = 21, fill = "salmon", alpha = 0.8) +
    labs(x = NULL, y = "Maximum Intensity [°C]", size = "Cumulative Intensity [°C x days]", caption = footnote) +
    scale_size_continuous(range = c(0.1, 6), 
                          guide = guide_legend(title.position = "top", direction = "horizontal")) +
    theme_bw() +
    theme(legend.position = "bottom",
          legend.key.size = unit(0.2, "lines"),
          legend.title = element_text(size=8), 
          legend.text = element_text(size=6),
          legend.box.background = element_rect(colour = "black"),
          plot.caption = element_text(hjust = 0))
}


# Plot graph
# Run the code below to plot the graph, rerun this every time you change variable.
visualize_bubble_plot(mhw, start_date_plot, end_date_plot)