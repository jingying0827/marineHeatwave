# marineHeatwave
<hr>

### Cloning Git Repository
1. In GitHub, click "<>Code" and in the drop-down, copy the HTTPS link.
2. Go to the folder in your desktop where you want to put this file in, open the folder in your terminal (right-click the folder name -> click "Open in Terminal").
3. In your terminal, type "git clone" and paste the link. The folder should now cloned into your local environment.

<hr>

### Setting Your Environment
Put your environment variable set in a `.env` file in your working directory.
```
AWS_DEFAULT_REGION = '', 
AWS_S3_ENDPOINT = 'projects.pawsey.org.au', 
AWS_ACCESS_KEY_ID = PUT YOUR ACCESS KEY ID, 
AWS_SECRET_ACCESS_KEY = PUT YOUR SECRET ACCESS KEY
```

<hr>

### Requirement And Explanation For Some Functions
[**ts2clm( )**](https://robwschlegel.github.io/heatwaveR/reference/ts2clm.html)

Creates a **daily climatology** from a time series of daily temperatures using a user-specified sliding window for the mean and threshold calculation.

| t                                  | temp               |
|:-----------------------------------|:-------------------|
| date values (in YYYY-MM-DD format) | temperature values |

-   Dataset is expected to have headers **t** and **temp** (2-column dataframe).

-   Preferably **30 years** in length for climatologyPeriod (**min**imum **3 years** *- derived from testing code*).

-   This function assumes that the input time series consists of **continuous daily values** with few missing values.

-   It is further advised that full the start and end dates for the climatology period result in **full years**, if applicable.

-   **Avoid having duplicated rows or replicate** temperature readings per day.

</br>   

[**detect_event()**](https://robwschlegel.github.io/heatwaveR/reference/detect_event.html)

-   Need to use the **output from `ts2clm()`**.

-   Data frame need to be at least four columns (expected to have headers **`t`, `temp`, `seas`, `thresh`**).

-   The default minimum duration for acceptance of detected events is 5 days.

</br>

[**event_line()**](https://robwschlegel.github.io/heatwaveR/reference/event_line.html)

Creates a line plot of heatwaves or cold-spells.

-   metric: tells the function how to choose the event that should be highlighted as the 'greatest' of the events in the chosen period. (Default: `intensity_cumulative`).

-   spread: the number of days leading and trailing the largest event (as per `metric`) detected within the time period specified by `start_date` and `end_date`. The default is 150 days.

</br>

[**exceedance()**](https://robwschlegel.github.io/heatwaveR/reference/exceedance.html)

Detect consecutive days in exceedance above or below of a given threshold (temperature).

-   The function will **not accurately detect** consecutive days of temperatures in exceedance of the threshold **if missing days of data are not filled in with NA**.

-   The function will return a list of two data.frames. The first being **threshold**, which shows the **daily temperatures** and on which **specific days the given threshold was exceeded**. The second component of the list is **exceedance**, which shows a medley of **statistics** for each discrete group of days in exceedance of the given exceedance.

<hr>

### Running The Code

#### 1. Using R markdown
If you prefer to use the `.Rmd` file provided, it is advised that you open it in **R Studio**, and turn the **Visual** mode on.

After you do that, you could run the code chunk accordingly to the instructions in the `.Rmd` file.

**REMEMBER TO SET YOUR WORKING DIRECTORY TO THE RESPECTIVE FOLDER IF YOU ARE USING R/R STUDIO.**

</br>

#### 2. Using R code
If you prefer to use the `.R` code provided, you could open them in any editor.

**REMEMBER TO SET YOUR WORKING DIRECTORY TO THE RESPECTIVE FOLDER IF YOU ARE USING R/R STUDIO.**

Run the `.R` file as follows:
1. After setting your working directory, run the `1_DataExtraction:LibraryPackage.R`. You should not have the whole dataset loaded as `Rawdata`.
2. Run the `2_DataCleaning.R` for functions to clean the raw dataset into the required format for the package.
3. Run the `3_DataInterpolation.R` for function to interpolate daily data as required to use the heatwaveR package. This is because the raw data only contains weekly data.
4. Run the `4_EventDetection.R` for function to calculate climatology and detect Marine Heatwave (MHW) events.
5. Run the R code staring with `5_Plotting_` for plotting the graph you require.

<hr>

### Library Used
   - [dplyr](https://rdocumentation.org/packages/dplyr/versions/1.0.10)
   - [ggplot2](https://rdocumentation.org/packages/ggplot2/versions/3.5.0)
   - [heatwaveR](https://rdocumentation.org/packages/heatwaveR/versions/0.4.6)
   - [patchwork](https://www.rdocumentation.org/packages/patchwork/versions/1.2.0/topics/patchwork-package)
   - [aws.s3](https://rdocumentation.org/packages/aws.s3/versions/0.3.21)

<hr>

#### **References**
Schlegel RW, Smit AJ (2018). “heatwaveR: A central algorithm for the detection of heatwaves and cold-spells.” Journal of Open Source Software, 3(27), 821. doi:10.21105/joss.00821.[heatwaveR package](https://robwschlegel.github.io/heatwaveR/index.html).

<hr>
