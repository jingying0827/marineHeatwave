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


# Data Visualization Function

visualize_weekly_raw_data <- function(averaged_data, start_date_plot, end_date_plot) {
  filtered_data <- averaged_data[averaged_data$t >= start_date_plot & averaged_data$t <= end_date_plot,]
  footnote <- "* This plot shows the raw weekly sea surface temperature of the selected selected timeframe (START and END date)."
  ggplot(filtered_data, aes(x = t, y = avg_temperature)) +
    geom_point(color = "red", size = 2) + 
    labs(x = "", y = "Temperature [\u00B0C]", caption = footnote) +
    theme_bw() +
    theme(plot.caption = element_text(hjust = 0))
}


# Plot graph
# Run the code below to plot the graph, rerun this every time you change variable.
visualize_weekly_raw_data(averaged_data, start_date_plot, end_date_plot) 