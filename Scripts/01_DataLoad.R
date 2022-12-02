######################################
# 01_DataLoad.R
######################################

# This script is a test to try to read in bits of the commission template
# shared by Amelia on 16/11/2022. Can we do it?

# OBSOLETE, USE 02_DataLoadSheets.R!

#### Load packages ----
# macbooks!
getCRANmirrors() # Check CRAN mirrors when installing packages
chooseCRANmirror(ind = 89) # corresponds to UK mirror

# Base packages (always load these)
library(tidyverse) # The master package for ggplot and data manipulation
library(RColorBrewer)    #To give access to a greater range of colours
library(lubridate) # Easier date manipulation
library(reshape2) # Just in case we're doing long to wide or vice versa
library(stringi) # Easier manipulation of strings
library(scales) # Automatically determines breaks and labels for axes and legends
library(clipr) # Write tables to clipboard

# Word Document scraping
library(officer)
library(ggtext)
library(janitor)

# Sheets webscraping
library(googlesheets4)

#### Read in docx contents
commission_docx <- read_docx("/Users/jose.orjales/Repos/Commission/Data/Copy of Top 75 Service Baselining Commission - Part 1 (Qual).docx")
commission_docx <- read_docx("/Users/jose.orjales/Repos/Commission/Data/Copy of Top 75 Service Baselining Template - Part 1 (Qualitative Report_LANDSCAPE).docx")

summary <- docx_summary(commission_docx) %>% as_tibble()

View(summary)
View(summary  %>% filter(content_type == "table cell"))



#### Read in google sheets

sht_contextinfo <- read_sheet("https://docs.google.com/spreadsheets/d/1sPPxcQ_nvWMgHruVbZ8wzDrh7rJ2ujMfYKC7kBkvt1c/edit#gid=0" 
    , sheet = 1
    , range = "C13:D19" 
    , col_names = c("Field", "Value")
    )
View(sht_contextinfo)

sht_PM <- read_sheet("https://docs.google.com/spreadsheets/d/1sPPxcQ_nvWMgHruVbZ8wzDrh7rJ2ujMfYKC7kBkvt1c/edit#gid=0" 
    , sheet = 2
    , range = "B5:H21" 
    , col_names = TRUE
    )
View(sht_PM)
