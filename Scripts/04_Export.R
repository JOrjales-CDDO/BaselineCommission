######################################
# 04_Export.R
######################################

# This script is to write to Google sheets the various tables set up
# in 03_DataCollate.R.

#### Create placeholder sheet in local drive----------------------------
gs4_create(name = paste0(snapshot, " - ServiceBaselines_"
    , format(Sys.time(), "%Y%m%d"))
    , sheets = c("AllData"
        , "ServiceObjectives"
        , "CDDO_KPIs"
        , "CDDO_PainPts"
        , "ServiceSpecKPIs"
        , "ServiceSpecPainPts"
        , "OpportunityAnalysis"
        , "CDDO_CalcKPIs"
        )
)

#### Read in file/folder IDs. Be careful, if more than one file with same 
# naming convention, will bring back multiple IDs. THERE CAN ONLY BE ONE!!!!!
sheet_id <- drive_get(paste0(snapshot, " - ServiceBaselines_"
    , format(Sys.time(), "%Y%m%d")))

folder_id <- drive_find(n_max = 10
    , pattern = "Collated Datasets")$id # Be careful of this,
# if have more than one folder called 99_Testing, will find all of them.

#### Send tables to placeholder sheet(s)--------------------------------
sheet_write(data = svc_sheets_overall_final
    , ss = sheet_id
    , sheet = "AllData")

sheet_write(data = svc_sheets_cntxtobjectvs
    , ss = sheet_id
    , sheet = "ServiceObjectives")

sheet_write(data = svc_sheets_cntxtcddo
    , ss = sheet_id
    , sheet = "CDDO_KPIs")

sheet_write(data = svc_sheets_cntxtPP
    , ss = sheet_id
    , sheet = "CDDO_PainPts")

sheet_write(data = svc_sheets_cntxtservspec
    , ss = sheet_id
    , sheet = "ServiceSpecKPIs")

sheet_write(data = svc_sheets_cntxtssPP
    , ss = sheet_id
    , sheet = "ServiceSpecPainPts")

sheet_write(data = bespoke_OppA
    , ss = sheet_id
    , sheet = "OpportunityAnalysis")

sheet_write(data = bespoke_CDDOKPI
    , ss = sheet_id
    , sheet = "CDDO_CalcKPIs")


#### Move the sheet to the final output folder area---------------------
drive_mv(paste0(snapshot, " - ServiceBaselines_"
    , format(Sys.time(), "%Y%m%d"))
    , path = as_id(folder_id))
