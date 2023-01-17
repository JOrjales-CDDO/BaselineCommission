# Introduction

This repository contains a copy of the Baseline Commission R code that is 
used to collate together data from the Top 75 Services commission.

The code has been set up to work in a modular manner, in classic R project 
format. Below each section will run through what the script is doing in 
each case.

## 00_Master.R

00_Master.R should be the starting point before attempting to run the other 
scripts. You may need to install some of the packages used, and these will be 
carried through to when the output QA summary on completeness is produced.

The first main section allows you to introduce settings for the code to work 
from. This includes assigning your email address (required to access Google 
Drive with your CDDO credentials). You can also set the snapshot which will 
be assigned to some outputs.

If you are cloning the code to your local machine, either set up a /Repos 
folder into which you can clone the code, alternatively amend the working 
directory field once it's cloned to your system.

Please note that the Google Drive storage folder for returns and the collated 
output folders should NOT be amended. These are based on expectations from the
data management process document stored [here](https://docs.google.com/document/d/1DScBh7fYkMnF-vLAReS4IXXPfMzUKQ0NJ4I34gl1bYM/edit). A good rule of thumb is to 
attempt to access those folders before you run the code \- you may need to 
request access first.

Subsequently, you can "source" each individual file as required.

## 02_DataLoadSheets.R

This is the script that reads from all of the google sheets held within the 
aforementioned Google Drive folder for returns. At a high level, it creates a 
series of container data frames, identifies the number of sheets held within the 
storage folder, and iterates over them and their component tables to extract to the 
container data frames.

Things to be aware of:

- The extracted data tables are annoyingly output as a list of lists, so 
indexes need to be used to correctly take the relevant element of each sub-list.
- A breakdown of which question each field name relates to in the baseline commission 
template can be found [here](https://docs.google.com/spreadsheets/d/1cEdgBv2dQEUVoZRechZKynrt8IS86IoMMldNiPKmnMA/edit#gid=0).
- All output table names from this section start with the prefix "sheets_" 
but please review the code itself to understand which data frame container 
relates to which table in the commission template.
- The Google API has a rate limiter; consequently if running in Visual Studio 
code (or your GUI of choice), you may get a Request failed 429 error and a 
time (100.4 seconds) until next attempt. The code is still running however it 
must be slowed down.

## 03_DataCollate.R

This script both cleans/tidies the data held in the containers and also 
brings the data together for eventual output. It also sets up QA tables that
will feed into a QA summary markdown document (see below) that tracks the 
completeness of each overall section and on a service-by-service basis.

Each section is extensively commented to help follow along with what is happening.ßß

### Custom functions
The QA completeness tables are derived in this script and so some functions 
are set up to help with that.

- section_nas: Derives the completeness across an entire table such as one
for an individual section.
- row_nas: Calculates the proportion of NAs by row across a given table. 
This is obviously helpful for service-by-service calculations.
- check_completeness_section: This just derives proportion of NAs by 
column. This is a convenience function that gets wrapped into the fieldsection_maker 
function.
- fieldsection_maker: Given that some columns aren't meant to be included 
for consideration (e.g. free text can be mostly empty), this function takes 
some input values specified by the user to derive column completeness per 
section depending on which columns are in scope.

### Cleaning and transformation

Some variable values have been set for calculation of KPIs per service. These are:

- AVGFTECost: Set at 41500 following discussion with Ed Mack on EO FTE overhead.
- WkHrsYr: Set at 1857.4, assuming 7.4 hours per day of work, for 251 working days.

The cleaning sections amend columns to remove e.g. https://www.gov.uk for easier 
linkage to other datasets with the URLGovUKStart, or to remove placeholder 
text added to data entry cells to aid service teams in completing the template 
(particularly prevalent in the pain points section). The timeliness KPI 
also adjusts the entry from 5d, 5w for days and weeks respectively to be 
set as hours for consistency across services.

There is also a set of commands to replace any strings of unknown, N/A, 
Not sure etc with NA to ensure consistency in how unknown values are handled.

### Bespoke tables

In addition to the main collated data table that covers all fields, the 
output file has individual tabs for each template table for all services, 
and at time of writing "OpportunityAnalysis" and "CDDO_CalcKPIs" sheets for 
the Opportunity Analysis work and analysis required on the performance metric 
KPIs within the template.

All created tables are saved to an RData object on the local system which 
the R Markdown summary document reads from.

## 04_Export.R

The sole purpose of this code is to output the tables to a Google Sheet 
file in Google Drive.

It firstly creates a file with blank sheets. The sheet_id and folder_id variables 
determine its location in Google Drive after which each data table can be sent to 
the relevant sheet in the file. 

The output file to begin with is stored in YOUR GOOGLE DRIVE, not the 
Transforming Government Services drive. This is to give you a chance to look 
at the data prior to moving it to the collated datasets folder in the TGS drive.
drive_mv will take your file and move it to TGS.

Things to be aware of:

- If you have already run the code once that day and wish to run it again, 
you will need to remove the old version first. Otherwise the sheet_id variable 
will flag TWO or more potential files to send data to which will confuse the
sheet_write function and cause an error. Moving the file to your bin is sufficient.
- If you are amending the destination folder (for some reason), if there is more 
than one folder with that name on the entirety of the TGS drive, it will 
cause an error. Folder names MUST be unique, hence why the "All Services Datasets" 
folder was created as a single repository for top 75 services data.

## QASummary.Rmd

An RMarkdown document that essentially just takes the created QA tables from
03_DataCollate.R and applies some conditional formatting. Tables are broken out 
on a section-by-section basis, by service and fields by section overall.

Things to be aware of:

- Conditional formatting is applied individually to each table in the R chunk 
present in the markdown doc. Any amendments will need to be applied individually.
- This applies more to 03, however the way the completeness is counted varies. 
Most sections will just be a case of looking how many NAs/blanks there are in 
the table. However, when there is a logical i.e. if Yes, then fill this in, 
otherwise skip, the collation code will discount any entry in the field if it 
is NOT specifically "Yes". This applies to the Pain points section primarily.
- Some tables such as the optional service-specific KPIs and service-specific 
challenges can be left entirely blank. The QA document only looks at the first 
cell for most sections, though the final "Field Completion - Optional Sections"
will show completeness across all services for the relevant tables.

## 05_AnalysisOutputs.R

This script is the placeholder for analysis arising from the baseline template 
data. Please keep analytical outputs to this script, or create a new 
markdown document if that is what is required.

Currently, the script contains one main function that sets up a distribution 
analysis for a specific variable and combines it with a box plot, saved 
as a jpeg output. Mostly ggplot in the backend running the show on this.
