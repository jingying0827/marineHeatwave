# DATA EXTRACTION FROM PAWSEY/ LIBRARY PACKAGE USED
# Run this code chunk only once to read in the data file and load the library needed, you do not need to run this after you change variable.

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