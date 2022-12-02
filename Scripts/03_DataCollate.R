######################################
# 01_DataCollate.R
######################################

# This script is designed to collate the tables together from reading 
# in google sheets.

#### Cleaning and Transformation----------------------------------------

# Create list of files to iterate over

#### Create the "master table"------------------------------------------

svc_sheets_overall <- cbind(
    svc_sheets_cntxt
    , svc_sheets_objctvs
    , svc_sheets_cddo
    , svc_sheets_servspec
    , svc_sheets_PP
    , svc_sheets_ssPP
)

#### Placeholders and transformation------------------------------------

### Context and Objectives
svc_sheets_cntxtobjectvs  <- cbind(
    svc_sheets_cntxt
    , svc_sheets_objctvs
)

### Context and CDDO KPIs
svc_sheets_cntxtcddo <- cbind(
    svc_sheets_cntxt
    , svc_sheets_cddo
)

### Context and Service Specific KPIs
svc_sheets_cntxtservspec  <- cbind(
    svc_sheets_cntxt
    , svc_sheets_servspec
)

### Context and Pain Points
svc_sheets_cntxtPP  <- cbind(
    svc_sheets_cntxt
    , svc_sheets_PP
)

### Context and Service Specific Pain Points
svc_sheets_cntxtssPP <- cbind(
    svc_sheets_cntxt
    , svc_sheets_ssPP
)
