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
library(geomtextpath) # Convenience, combines geom_vline with geom_text call
library(ggpubr)
library(naniar) # Easy treatment of NAs and blanks like ""
library(knitr)
library(markdown)
library(kableExtra)
library(DT)

# Word Document scraping
library(officer)

# Sheets webscraping
library(googlesheets4)
library(googledrive)

# Miscellaneous
library(wordstonumbers) # Convert text numbers to numeric numbers e.g four to 4

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

# Set Working Directory (create a folder called Repos/BaselineCommission)
setwd("~/Repos/BaselineCommission")

# Google Drive storage folder for returns
URL <- "https://drive.google.com/drive/folders/1wGGdygAufpQTBg8aeciDpWCNRODm2mbQ"

# Google Drive storage folder for collated output
URL_collate <- "https://drive.google.com/drive/folders/1O56sQdBXEUNXZDc5OxksYEHAXUBDGyex"

# Local folder for Word documents (no longer needed)
# DocsLocal <- "/Users/jose.orjales/Repos/Commission/Data/01_CommissionDocs/"

#### Scripts------------------------------------------------------------

### Collate baseline template data together
#source("01_DataLoadDocs.R")
source("Scripts/02_DataLoadSheets.R")
source("Scripts/03_DataCollate.R")
source("Scripts/04_Export.R")

### Create QA HTML document (ensure Visual Studio Code runs pandoc, otherwise use RStudio)
rmarkdown::render("RMarkdown/QASummary.Rmd")
