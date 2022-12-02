######################################
# 00_Master.R
######################################

# This script is designed to set things up ready to run the collation code
# to pull together the various sources required to create the final table.

#### Packages-----------------------------------------------------------# 
getCRANmirrors() # Check CRAN mirrors when installing packages
chooseCRANmirror(ind = 89) # Specify a mirror to avoid popups

# Base packages (always load these)
library(tidyverse) # The master package for ggplot and data manipulation
library(RColorBrewer)    #To give access to a greater range of colours
library(lubridate) # Easier date manipulation
library(reshape2) # Just in case we're doing long to wide or vice versa
library(stringi) # Easier manipulation of strings
library(scales) # Automatically determines breaks and labels for axes and legends
library(clipr) # Write tables to clipboard
library(data.table)

# Word Document scraping
library(officer)

# Sheets webscraping
library(googlesheets4)
library(googledrive)

## Custom Functions
# Write clip function, writes last table created to the clipboard ready to be
# entered into an Excel worksheet or something like that.
wc <- function(x = .Last.value) {
  clipr::write_clip(x)
}

#### Settings-----------------------------------------------------------

## Get authorised and tell googlesheets4 to use same authorisation token
drive_auth(
    email = "Jose.Orjales@digital.cabinet-office.gov.uk"
)
gs4_auth(token = drive_token())

# Store text for naming conventions later
snapshot = "December 2022"

# Google Drive storage folder for returns
URL <- "https://drive.google.com/drive/folders/1U6LZnpjxSw16oPXf8BRjKmF_NjC-nm68"

# Google Drive storage folder for collated output
URL_collate <- "https://https://drive.google.com/drive/folders/12q6DA_yyyTjSxD8hbYJaG1lD2w0-A5Yp"

# Local folder for Word documents (no longer needed)
# DocsLocal <- "/Users/jose.orjales/Repos/Commission/Data/01_CommissionDocs/"

#### Scripts------------------------------------------------------------
#source("01_DataLoadDocs.R")
source("02_DataLoadSheets.R")
source("03_DataWrangle.R")