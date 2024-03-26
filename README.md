# marineHeatwave


### Cloning Git Repository
1. In GitHub, click "<>Code" and in the drop-down, copy the HTTPS link.
2. Go to the folder in your desktop where you want to put this file in, open the folder in your terminal (right-click the folder name -> click "Open in Terminal").
3. In your terminal, type "git clone" and paste the link. The folder should now cloned into your local environment.

</br>

### Setting Your Environment
Put your environment variable set in a `.env` file in your working directory.
```
AWS_DEFAULT_REGION = '', 
AWS_S3_ENDPOINT = 'projects.pawsey.org.au', 
AWS_ACCESS_KEY_ID = PUT YOUR ACCESS KEY ID, 
AWS_SECRET_ACCESS_KEY = PUT YOUR SECRET ACCESS KEY
```

</br>

### Running The Code

#### 1. Using R markdown
If you prefer to use the `.Rmd` file provided, it is advised that you open it in **R Studio**, and turn the **Visual** mode on.

After you do that, you could run the code chunk accordingly to the instructions in the `.Rmd` file.

**REMEMBER TO SET YOUR WORKING DIRECTORY TO THE RESPECTIVE FOLDER IF YOU ARE USING R/R STUDIO.**

#### 2. Using R code
If you prefer to use the `.R` code provided, you could open them in any editor.

**REMEMBER TO SET YOUR WORKING DIRECTORY TO THE RESPECTIVE FOLDER IF YOU ARE USING R/R STUDIO.**

Run the `.R` file as follows:
1. After setting your working directory, run the `1_DataExtraction:LibraryPackage.R`. You should not have the whole dataset loaded as `Rawdata`.
2. Run the `2_DataCleaning.R` for functions to clean the raw dataset into the required format for the package.
3. Run the `3_DataInterpolation.R` for function to interpolate daily data as required to use the heatwaveR package. This is because the raw data only contains weekly data.
4. Run the `4_EventDetection.R` for function to calculate climatology and detect Marine Heatwave (MHW) events.
5. Run the R code staring with `5_Plotting_` for plotting the graph you require.





#### **References**
Schlegel RW, Smit AJ (2018). “heatwaveR: A central algorithm for the detection of heatwaves and cold-spells.” Journal of Open Source Software, 3(27), 821. doi:10.21105/joss.00821.[heatwaveR package](https://robwschlegel.github.io/heatwaveR/index.html).

#### **DATA EXTRACTION FROM PAWSEY/ LIBRARY PACKAGE USED**

Run this code chunk **only once** to read in the data file and load the library needed, you do not need to run this after you change variable.

```{r DataExtraction/LibraryPackage}
## Library needed
library(dplyr)
library(ggplot2)
library(heatwaveR)
library(patchwork)

## Data Extraction
library('aws.s3')
Sys.setenv('USE_HTTPS' = TRUE)

# if you do not have environment variable set in .env file, comment the readRenviron() function and uncomment the Sys.setenv() function below

readRenviron(".env")

# Sys.setenv(
#   'AWS_DEFAULT_REGION' = '', 
#   'AWS_S3_ENDPOINT' = 'projects.pawsey.org.au', 
#   'AWS_ACCESS_KEY_ID' = PUT YOUR ACCESS KEY ID, 
#   'AWS_SECRET_ACCESS_KEY' = PUT YOUR SECRET ACCESS KEY
# )

awss3Connect <- function(filename){
  bucket <- 'scevo-data'
  fetchedData <- aws.s3::s3read_using(FUN = utils::read.csv,
                                      check.names = FALSE,
                                      object = filename,
                                      bucket = bucket,
                                      filename = basename(filename),
                                      opts = list(
                                        base_url = Sys.getenv('AWS_S3_ENDPOINT'),
                                        region = Sys.getenv('AWS_DEFAULT_REGION'),
                                        key = Sys.getenv('AWS_ACCESS_KEY_ID'),
                                        secret = Sys.getenv('AWS_SECRET_ACCESS_KEY')))
  return(fetchedData)
}

Rawdata <- awss3Connect(filename = 'arms/wiski.csv')  
```

------------------------------------------------------------------------

------------------------------------------------------------------------

#### **FUNCTIONS USED**

Run this code chunk **only once** to run the functions to be used, you do not need to run this after you change variable.

```{r NOTINUSE_SelectFullYearsTimeFrame}
detect_events <- function(interpolated_data) {
  # Extract start and end dates
  start_date <- min(interpolated_data$t)
  end_date <- max(interpolated_data$t)
  
  # Extract start and end years
  start_year <- as.numeric(format(start_date, "%Y"))
  end_year <- as.numeric(format(end_date, "%Y"))
  
  # Extract start and end month and day
  start_month_day <- format(start_date, "%m-%d")
  end_month_day <- format(end_date, "%m-%d")
  
  test_start_date <- as.Date(paste0(start_year,"-", end_month_day))
  test_end_date <- as.Date(paste0(end_year, "-",start_month_day))
  
  if ((max(test_end_date, end_date)-max(test_start_date, start_date)) > (min(test_end_date, end_date)-min(test_start_date, start_date))){
    clima_start_date <- max(test_start_date, start_date)
    clima_end_date <- max(test_end_date, end_date)
  } else {
    clima_start_date <- min(test_start_date, start_date)
    clima_end_date <- min(test_end_date, end_date)
  }
  
  climatologyPeriod <- c(clima_start_date, clima_end_date)
  
  ts <- ts2clm(interpolated_data, climatologyPeriod = climatologyPeriod)
  mhw <- detect_event(ts)
  
  return(mhw)
}
```

```{r FunctionsUsed}
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

# Event Detection Function
detect_events <- function(interpolated_data) {
  ts <- ts2clm(interpolated_data, climatologyPeriod = c(min(interpolated_data$t), max(interpolated_data$t)))
  mhw <- detect_event(ts)
  
  return(mhw)
}

# Data Visualization Functions
visualize_weekly_raw_data <- function(averaged_data, start_date_plot, end_date_plot) {
  filtered_data <- averaged_data[averaged_data$t >= start_date_plot & averaged_data$t <= end_date_plot,]
  footnote <- "* This plot shows the raw weekly sea surface temperature of the selected selected timeframe (START and END date)."
  ggplot(filtered_data, aes(x = t, y = avg_temperature)) +
    geom_point(color = "red", size = 2) + 
    labs(x = "", y = "Temperature [\u00B0C]", caption = footnote) +
    theme_bw() +
    theme(plot.caption = element_text(hjust = 0))
}

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

visualize_lolli_plot <- function(mhw, event_count, start_date_plot, end_date_plot) {
  filtered_events <- mhw$event[mhw$event$date_peak >= start_date_plot & mhw$event$date_peak <= end_date_plot, ]
  footnote <- glue::glue("* The event highlighted is the top ", event_count, " largest event based on the selected timeframe (START and END date of this plot),\n   instead of the whole period of data.")
  ggplot(filtered_events, aes(x = date_start, y = intensity_max)) +
  geom_lolli(colour = "salmon", colour_n = "red", n = 3) +
  labs(y = expression(paste("Max. intensity [", degree, "C]")), caption = footnote) +
  theme_bw() +
  theme(plot.caption = element_text(hjust = 0))
}

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
```

------------------------------------------------------------------------

------------------------------------------------------------------------

#### **Variables to be changed (change the value and run the respective code chunk):**

<br/>

#### Step 1 (Select your site)

Select a site from: (**`ARM`**, **`BLA`**, **`FP1`**, **`FP7`**, **`FP22`**, **`CAV`**, **`HEA`**, **`NAR`**, **`NIL`**, **`STJ`**, **`MAY`**, **`RON`**, **`KIN`**, **`SUC`**, **`MEAD`**, **`MULB`**, **`WMP`**, **`REG`**, **`MSB`**, **`POL`**, **`SANDBR`**, **`KMO`**, **`JBC`**, **`VIT`**).

```{r SelectYourSite}
swansites <- c('ARM')
```

------------------------------------------------------------------------

#### Step 2 (Select your desired depth data)

Determine the **`depth`** measured you want to filter the data, the filtered data will only included data with depth less than or equal to the depth you set.

```{r FilterYourDepth}
depth = 2

# do not change the code below
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
climatologyperiod()
```

------------------------------------------------------------------------

#### Step 3 (For all data visualization)

Determine **start and end date** for data visualization, this can only within the available date period outlined in **Step 2**.

```{r SelectTheTimeFrameForPlotting}
start_date_plot = "2010-04-12"
end_date_plot = "2012-12-12"
```

------------------------------------------------------------------------

#### Step 4 (For [event line](https://robwschlegel.github.io/heatwaveR/reference/event_line.html) plot)

Determine the **period (day) before & after the peak event** you want the graph to show (for event line plot); and determine if you want the plot to be **categorised**.

The **metric** tells the function how to choose the event that should be highlighted as the 'greatest' of the events in the chosen period. You may choose from the following options: **`intensity_mean`**, **`intensity_max`**, **`intensity_var`**,**`intensity_cumulative`**, **`intensity_mean_relThresh`**, **`intensity_max_relThresh`**, **`intensity_var_relThresh`**, **`intensity_cumulative_relThresh`**, **`intensity_mean_abs`**, **`intensity_max_abs`**, **`intensity_var_abs`**, **`intensity_cumulative_abs`**, **`rate_onset`**, **`rate_decline`**.

The plot may not necessarily correspond to the biggest event of the specified metric within the entire time series; instead, this plot shows the biggest event within the **`start_date_plot`** and **`end_date_plot`** you chose.

To plot the largest event within the whole time series, make sure you chose the **`start_date_plot`** and **`end_date_plot`** that cover the whole time series.

```{r CustomiseVariableForEventLinePlot}
spread = 180
category = FALSE
metric = "intensity_cumulative"
```

------------------------------------------------------------------------

#### Step 5 (For [exceedance](https://robwschlegel.github.io/heatwaveR/reference/exceedance.html) plot)

Determine temperature **`threshold`** to be detected (for exceedance plot).

```{r CustomiseThresholdToDetectExceedanceEvent}
threshold = 25
```

------------------------------------------------------------------------

#### Step 6 (For lolli plot)

Determine the **event count** to be highlighted (for lolli plot), the top x highest event will be in brighter red colour than others. The graph plotted here is adapted from the [**`lolli_plot()`**](https://robwschlegel.github.io/heatwaveR/reference/lolli_plot.html) function in the **heatwaveR package**, using **`ggplot()`**.

```{r CustomiseHighlightedEventForLolliPlot}
event_count = 3
```

------------------------------------------------------------------------

------------------------------------------------------------------------

#### **DATA TRANSFORMATION**

Run this code chunk to transform your data into the correct format to plot graphs, rerun this **every time you change your site and/or desired depth data**.

```{r DataTransformation}
cleaned_data = clean_data(Rawdata, swansites, depth) 
averaged_data = average_data(cleaned_data)
interpolated_data = interpolate_data(averaged_data) 
mhw = detect_events(interpolated_data)
```

------------------------------------------------------------------------

------------------------------------------------------------------------

#### **PLOT GRAPHS**

Run these code chunks to plot the graphs respectively, rerun this **every time you change variable**:

##### [Weekly Raw Data]{.underline}

```{r WeeklyRawDataPlot}
visualize_weekly_raw_data(averaged_data, start_date_plot, end_date_plot) 
```

##### [Exceedance]{.underline}

```{r ExceedancePlot}
visualize_exceedance(interpolated_data, threshold, start_date_plot, end_date_plot)
```

##### [Event Line]{.underline}

```{r EventLinePlot}
visualize_event_line(mhw, spread, metric, start_date_plot, end_date_plot, category)
```

##### [Lolli Plot]{.underline}

```{r LolliPlot}
visualize_lolli_plot(mhw, event_count, start_date_plot, end_date_plot)
```

##### [Bubble Plot]{.underline}

```{r BubblePlot}
visualize_bubble_plot(mhw, start_date_plot, end_date_plot)
```
