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
# Determine temperature threshold to be detected (for exceedance plot).
threshold = 25


# Data Transformation
# Run the code below to transform your data into the correct format to plot graph, rerun this every time you change your site and/or desired depth data.
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
interpolated_data = interpolate_data(averaged_data) 


# Data Visualization Function

visualize_exceedance <- function(interpolated_df, threshold, start_date_plot, end_date_plot) {
  exc <- exceedance(interpolated_df, threshold = threshold)
  exc_thresh <- exc$threshold[exc$threshold$t >= start_date_plot & exc$threshold$t <= end_date_plot, ]
  footnote <- glue::glue(
    "* temp   :  daily sea surface temperature. \n",
    "* thresh :  the threshold of daily sea surface temperature for highlighting. \n", 
    "* The event highlighted is the event that exceeds the temperature threshold set within the\n",
    "   selected timeframe (START and END date of this plot), instead of the whole period of data.")
  
  ggplot(data = exc_thresh, aes(x = t)) +
    geom_flame(aes(y = temp, y2 = thresh, fill = "all"), show.legend = FALSE) +
    geom_line(aes(y = temp, colour = "temp")) +
    geom_line(aes(y = threshold, colour = "thresh"), size = 1.0) +
    scale_colour_manual(name = "Legend", values = c("temp" = "black", "thresh" = "forestgreen")) +
    scale_fill_manual(name = "Event Colour", values = c("all" = "salmon")) +
    guides(colour = guide_legend(override.aes = list(fill = NA))) +
    scale_x_date(date_labels = "%b %Y") +
    labs(x = "", y = "Temperature [\u00B0C]", caption = footnote) +
    theme_bw() +
    theme(plot.caption = element_text(hjust = 0))
}


# Plot graph
# Run the code below to plot the graph, rerun this every time you change variable.
visualize_exceedance(interpolated_data, threshold, start_date_plot, end_date_plot)