######################################
# 02_DataLoadSheets.R
######################################

# This script is designed to read the google sheets associated with the 
# baseline commission template and create a set of tables after iterating
# across all files provided.

# Create list of files to iterate over
sheets_list <- drive_ls(path = URL, type = c("spreadsheet")) 

#### Set up data tables for reading into--------------------------------

# Service Contextual Info
svc_sheets_cntxt <- data.frame(
    `ServiceID` = character()
    , `SourceFile` = character()
    , `FileLink` = character()
    , `Service` = character()
    , `ServiceOwner` = character()
    , `URLService` = character()
    , `URLGovUK` = character()
    , `DepartmentParent` = character()
    , `DepartmentChild` = character()
    , `ServiceDescription` = character()
    , stringsAsFactors = FALSE
)

# Service Objectives table
svc_sheets_objctvs <- data.frame(
    `ServiceUserStart` = character()
    , `ServiceUserEnd` = character()
    , `ServiceTasks` = character()
    , `ServiceDependencies` = character()
    , stringsAsFactors = FALSE
)

# CDDO KPI table
svc_sheets_cddo <- data.frame(
    `FTECount` = numeric()
    , `FTECount_AddInfo` = character()
    , `FTECount_FreeText` = character()

    , `NonStaffCost` = numeric()
    , `NonStaffCost_AddInfo` = character()
    , `NonStaffCost_FreeText` = character()

    , `CompletedTransactions` = numeric()
    , `CompletedTransactions_AddInfo` = character()
    , `CompletedTransactions_FreeText` = character()

    , `CompletedDigitalTransactions` = numeric()
    , `CompletedDigitalTransactions_AddInfo` = character()
    , `CompletedDigitalTransactions_FreeText` = character()

    , `StartedDigitalTransactions` = numeric()
    , `StartedDigitalTransactions_AddInfo` = character()
    , `StartedDigitalTransactions_FreeText` = character()

    , `Complaints` = numeric()
    , `Complaints_AddInfo` = character()
    , `Complaints_FreeText` = character()

    , `UsersEmail` = numeric()
    , `UsersEmail_AddInfo` = character()
    , `UsersEmail_FreeText` = character()

    , `UsersPhone` = numeric()
    , `UsersPhone_AddInfo` = character()
    , `UsersPhone_FreeText` = character()

    , `UsersLetters` = numeric()
    , `UsersLetters_AddInfo` = character()
    , `UsersLetters_FreeText` = character()

    , `UsersVerySatisfied` = numeric()
    , `UsersVerySatisfied_AddInfo` = character()
    , `UsersVerySatisfied_FreeText` = character()

    , `UsersSatisfied` = numeric()
    , `UsersSatisfied_AddInfo` = character()
    , `UsersSatisfied_FreeText` = character()

    , `UsersDissatisfied` = numeric()
    , `UsersDissatisfied_AddInfo` = character()
    , `UsersDissatisfied_FreeText` = character()

    , `UsersVeryDissatisfied` = numeric()
    , `UsersVeryDissatisfied_AddInfo` = character()
    , `UsersVeryDissatisfied_FreeText` = character()

    , `UsersTotalSatisfactionRespondents` = numeric()
    , `UsersTotalSatisfactionRespondents_AddInfo` = character()
    , `UsersTotalSatisfactionRespondents_FreeText` = character()

    , `UsersJourneyTimeHours` = character() # This could be problematic as not consistent minutes/hours/days
    , `UsersJourneyTimeHours_AddInfo` = character()
    , `UsersJourneyTimeHours_FreeText` = character()

    , `AutomatedTransactions` = character() # Character since percentage range factor
    , `AutomatedTransactions_AddInfo` = character()
    , `AutomatedTransactions_FreeText` = character()
    , stringsAsFactors = FALSE
)

# Service specific KPI table
 svc_sheets_servspec <- data.frame(
    `KPI1_Name` = character()
    , `KPI1_Description` = character()
    , `KPI1_Value` = character()
    , `KPI1_AddInfo` = character()
    , `KPI1_FreeText` = character()

    , `KPI2_Name` = character()
    , `KPI2_Description` = character()
    , `KPI2_Value` = character()
    , `KPI2_AddInfo` = character()
    , `KPI2_FreeText` = character()

    , `KPI3_Name` = character()
    , `KPI3_Description` = character()
    , `KPI3_Value` = character()
    , `KPI3_AddInfo` = character()
    , `KPI3_FreeText` = character()

    , `KPI4_Name` = character()
    , `KPI4_Description` = character()
    , `KPI4_Value` = character()
    , `KPI4_AddInfo` = character()
    , `KPI4_FreeText` = character()

    , `KPI5_Name` = character()
    , `KPI5_Description` = character()
    , `KPI5_Value` = character()
    , `KPI5_AddInfo` = character()
    , `KPI5_FreeText` = character()

    , `KPI6_Name` = character()
    , `KPI6_Description` = character()
    , `KPI6_Value` = character()
    , `KPI6_AddInfo` = character()
    , `KPI6_FreeText` = character()

    , `KPI7_Name` = character()
    , `KPI7_Description` = character()
    , `KPI7_Value` = character()
    , `KPI7_AddInfo` = character()
    , `KPI7_FreeText` = character()

    , `KPI8_Name` = character()
    , `KPI8_Description` = character()
    , `KPI8_Value` = character()
    , `KPI8_AddInfo` = character()
    , `KPI8_FreeText` = character()
 
    , `KPI9_Name` = character()
    , `KPI9_Description` = character()
    , `KPI9_Value` = character()
    , `KPI9_AddInfo` = character()
    , `KPI9_FreeText` = character()
    
    , `KPI10_Name` = character()
    , `KPI10_Description` = character()
    , `KPI10_Value` = character()
    , `KPI10_AddInfo` = character()
    , `KPI10_FreeText` = character()
    , stringsAsFactors = FALSE
)
# CDDO Pain Point table
 svc_sheets_PP <- data.frame(
    `CSupport_TeamExists` = character()
    , `CSupport_StatusExists` = character()
    , `CSupport_ContactCount` = character()
    , `CSupport_ImprovementsText` = character()
    , `CSupport_ChallengesText` = character()

    , `PaperUse_LettersSendExist` = character()
    , `PaperUse_LettersSendCount` = character()
    , `PaperUse_LettersReceiveExist` = character()
    , `PaperUse_LettersReceiveCount` = character()
    , `PaperUse_SignatureExist` = character()
    , `PaperUse_SignaturePercent` = character()
    , `PaperUse_ImprovementsText` = character()
    , `PaperUse_ChallengesText` = character()

    , `Auto_ManCheckExists` = character()
    , `Auto_NoHuman` = character()
    , `Auto_Judgement` = character()
    , `Auto_ImprovementsText` = character()
    , `Auto_ChallengesText` = character()

    , `Legacy_PlusTenYear` = character()
    , `Legacy_ImprovementsText` = character()
    , `Legacy_ChallengesText` = character()

    , `PMonitoring_AnalyticsExist`= character()
    , `PMonitoring_MetricsExist` = character()
    , `PMonitoring_ImprovementsText` = character()
    , `PMonitoring_ChallengesText` = character()

    , `Additional_IDCheckExists` = character()
    , `Additional_TaxDisburse` = character()
    , `Additional_FundingAward` = character()

    , `Usability_Compliant` = character()
    , `Usability_CompliantImprovementsText` = character()
    , `Usability_CompliantChallengesText` = character()

    ## These were incorrectly omitted from the template sent out in December.
    ## Likely need to be put back in for the next one and relevant row/col refs
    ## repointed.
    #, `Usability_Skills` = character()
    #, `Usability_SkillsImprovementsText` = character()
    #, `Usability_SkillsChallengesText` = character()

    #, `Usability_Burden` = character()
    #, `Usability_BurdenImprovementsText` = character()
    #, `Usability_CompliantChallengesText` = character()

    , `Usability_Complex` = character()
    , `Usability_ComplexImprovementsText` = character()
    , `Usability_ComplexChallengesText` = character()

    , stringsAsFactors = FALSE
)

# Service-Specific Pain Point table
svc_sheets_ssPP <- data.frame(
    `Theme1_Name` = character()
    , `Theme1_Description` = character()
    , `Theme1_CDDOSupport` = character()

    , `Theme2_Name` = character()
    , `Theme2_Description` = character()
    , `Theme2_CDDOSupport` = character()
    
    , `Theme3_Name` = character()
    , `Theme3_Description` = character()
    , `Theme3_CDDOSupport` = character()

    , `Theme4_Name` = character()
    , `Theme4_Description` = character()
    , `Theme4_CDDOSupport` = character()

    , `Theme5_Name` = character()
    , `Theme5_Description` = character()
    , `Theme5_CDDOSupport` = character()

    , `Theme6_Name` = character()
    , `Theme6_Description` = character()
    , `Theme6_CDDOSupport` = character()

    , `Theme7_Name` = character()
    , `Theme7_Description` = character()
    , `Theme7_CDDOSupport` = character()

    , `Theme8_Name` = character()
    , `Theme8_Description` = character()
    , `Theme8_CDDOSupport` = character()

    , `Theme9_Name` = character()
    , `Theme9_Description` = character()
    , `Theme9_CDDOSupport` = character()

    , `Theme10_Name` = character()
    , `Theme10_Description` = character()
    , `Theme10_CDDOSupport` = character()

    , stringsAsFactors = FALSE
)

#### Begin extraction loop----------------------------------------------
for (i in 1:length(sheets_list$name)){

## Pull out service context table (if no data present in table AT ALL, 
# will say names must be same attribute as vector)
sheets_cntxt <- read_sheet(sheets_list$id[i]
        , sheet = 1
        , range = "C4:D10"
        , col_names = c("Guidance", "Value")
    )

sheets_cntxt2 <- rbind(
    str_extract(sheets_list$name[i][[1]],"(?<=-).+(?=-)")
    , sheets_list$name[i]
    , paste0("https://docs.google.com/spreadsheets/d/", sheets_list$id[i])
    , sheets_cntxt
)

# Populate table
for (j in 1:length(svc_sheets_cntxt)){
    svc_sheets_cntxt[i,j] = ifelse(is.null(sheets_cntxt2[[2]][j][[1]]) == TRUE
    , NA, sheets_cntxt2[[2]][j][[1]])
}

# To figure out what service we're dealing with in loop if it breaks!
print(paste0("Loop on service: ", svc_sheets_cntxt[i,4]))
print("-----------------------")

## Pull out Service Scope & Objectives (if no data present in table AT ALL, 
# will say names must be same attribute as vector)
sheets_objctvs <- read_sheet(sheets_list$id[i]
        , sheet = 2
        , range = "C6:D9"
        , col_names = c("Guidance", "Value")
    )

# Populate table
for (j in 1:length(svc_sheets_objctvs)){
    svc_sheets_objctvs[i,j] = ifelse(is.null(sheets_objctvs[[2]][j][[1]]) == TRUE
    , NA, sheets_objctvs[[2]][j][[1]])
}

## Pull out Performance Metrics 1 (if no data present in table AT ALL, 
# will say names must be same attribute as vector)
sheets_PMs1 <- read_sheet(sheets_list$id[i]
        , sheet = 3
        , range = "C7:F22"
        , col_names = FALSE
    )

# FTE Count
svc_sheets_cddo[i,1] = ifelse(is.null(sheets_PMs1[[2]][1][[1]]) == TRUE, NA, sheets_PMs1[[2]][1][[1]])
svc_sheets_cddo[i,2] = ifelse(is.null(sheets_PMs1[[3]][1][[1]]) == TRUE, NA, sheets_PMs1[[3]][1][[1]])
svc_sheets_cddo[i,3] = ifelse(is.null(sheets_PMs1[[4]][1][[1]]) == TRUE, NA, sheets_PMs1[[4]][1][[1]])

# NonStaff Cost
svc_sheets_cddo[i,4] = ifelse(is.null(sheets_PMs1[[2]][2][[1]]) == TRUE, NA, sheets_PMs1[[2]][2][[1]])
svc_sheets_cddo[i,5] = ifelse(is.null(sheets_PMs1[[3]][2][[1]]) == TRUE, NA, sheets_PMs1[[3]][2][[1]])
svc_sheets_cddo[i,6] = ifelse(is.null(sheets_PMs1[[4]][2][[1]]) == TRUE, NA, sheets_PMs1[[4]][2][[1]])

# Completed Transactions
svc_sheets_cddo[i,7] = ifelse(is.null(sheets_PMs1[[2]][3][[1]]) == TRUE, NA, sheets_PMs1[[2]][3][[1]])
svc_sheets_cddo[i,8] = ifelse(is.null(sheets_PMs1[[3]][3][[1]]) == TRUE, NA, sheets_PMs1[[3]][3][[1]])
svc_sheets_cddo[i,9] = ifelse(is.null(sheets_PMs1[[4]][3][[1]]) == TRUE, NA, sheets_PMs1[[4]][3][[1]])

# Completed Digital
svc_sheets_cddo[i,10] = ifelse(is.null(sheets_PMs1[[2]][4][[1]]) == TRUE, NA, sheets_PMs1[[2]][4][[1]])
svc_sheets_cddo[i,11] = ifelse(is.null(sheets_PMs1[[3]][4][[1]]) == TRUE, NA, sheets_PMs1[[3]][4][[1]])
svc_sheets_cddo[i,12] = ifelse(is.null(sheets_PMs1[[4]][4][[1]]) == TRUE, NA, sheets_PMs1[[4]][4][[1]])

# Started Digital
svc_sheets_cddo[i,13] = ifelse(is.null(sheets_PMs1[[2]][5][[1]]) == TRUE, NA, sheets_PMs1[[2]][5][[1]])
svc_sheets_cddo[i,14] = ifelse(is.null(sheets_PMs1[[3]][5][[1]]) == TRUE, NA, sheets_PMs1[[3]][5][[1]])
svc_sheets_cddo[i,15] = ifelse(is.null(sheets_PMs1[[4]][5][[1]]) == TRUE, NA, sheets_PMs1[[4]][5][[1]])

# Complaints
svc_sheets_cddo[i,16] = ifelse(is.null(sheets_PMs1[[2]][6][[1]]) == TRUE, NA, sheets_PMs1[[2]][6][[1]])
svc_sheets_cddo[i,17] = ifelse(is.null(sheets_PMs1[[3]][6][[1]]) == TRUE, NA, sheets_PMs1[[3]][6][[1]])
svc_sheets_cddo[i,18] = ifelse(is.null(sheets_PMs1[[4]][6][[1]]) == TRUE, NA, sheets_PMs1[[4]][6][[1]])

# Users - Emails
svc_sheets_cddo[i,19] = ifelse(is.null(sheets_PMs1[[2]][7][[1]]) == TRUE, NA, sheets_PMs1[[2]][7][[1]])
svc_sheets_cddo[i,20] = ifelse(is.null(sheets_PMs1[[3]][7][[1]]) == TRUE, NA, sheets_PMs1[[3]][7][[1]])
svc_sheets_cddo[i,21] = ifelse(is.null(sheets_PMs1[[4]][7][[1]]) == TRUE, NA, sheets_PMs1[[4]][7][[1]])

# Users - Phone
svc_sheets_cddo[i,22] = ifelse(is.null(sheets_PMs1[[2]][8][[1]]) == TRUE, NA, sheets_PMs1[[2]][8][[1]])
svc_sheets_cddo[i,23] = ifelse(is.null(sheets_PMs1[[3]][8][[1]]) == TRUE, NA, sheets_PMs1[[3]][8][[1]])
svc_sheets_cddo[i,24] = ifelse(is.null(sheets_PMs1[[4]][8][[1]]) == TRUE, NA, sheets_PMs1[[4]][8][[1]])

# Users - letters
svc_sheets_cddo[i,25] = ifelse(is.null(sheets_PMs1[[2]][9][[1]]) == TRUE, NA, sheets_PMs1[[2]][9][[1]])
svc_sheets_cddo[i,26] = ifelse(is.null(sheets_PMs1[[3]][9][[1]]) == TRUE, NA, sheets_PMs1[[3]][9][[1]])
svc_sheets_cddo[i,27] = ifelse(is.null(sheets_PMs1[[4]][9][[1]]) == TRUE, NA, sheets_PMs1[[4]][9][[1]])

# Users - V. Satisfied
svc_sheets_cddo[i,28] = ifelse(is.null(sheets_PMs1[[2]][10][[1]]) == TRUE, NA, sheets_PMs1[[2]][10][[1]])
svc_sheets_cddo[i,29] = ifelse(is.null(sheets_PMs1[[3]][10][[1]]) == TRUE, NA, sheets_PMs1[[3]][10][[1]])
svc_sheets_cddo[i,30] = ifelse(is.null(sheets_PMs1[[4]][10][[1]]) == TRUE, NA, sheets_PMs1[[4]][10][[1]])

# Users - Satisfied
svc_sheets_cddo[i,31] = ifelse(is.null(sheets_PMs1[[2]][11][[1]]) == TRUE, NA, sheets_PMs1[[2]][11][[1]])
svc_sheets_cddo[i,32] = ifelse(is.null(sheets_PMs1[[3]][11][[1]]) == TRUE, NA, sheets_PMs1[[3]][11][[1]])
svc_sheets_cddo[i,33] = ifelse(is.null(sheets_PMs1[[4]][11][[1]]) == TRUE, NA, sheets_PMs1[[4]][11][[1]])

# Users - Dissatisfied
svc_sheets_cddo[i,34] = ifelse(is.null(sheets_PMs1[[2]][12][[1]]) == TRUE, NA, sheets_PMs1[[2]][12][[1]])
svc_sheets_cddo[i,35] = ifelse(is.null(sheets_PMs1[[3]][12][[1]]) == TRUE, NA, sheets_PMs1[[3]][12][[1]])
svc_sheets_cddo[i,36] = ifelse(is.null(sheets_PMs1[[4]][12][[1]]) == TRUE, NA, sheets_PMs1[[4]][12][[1]])

# Users - V. Dissatisfied
svc_sheets_cddo[i,37] = ifelse(is.null(sheets_PMs1[[2]][13][[1]]) == TRUE, NA, sheets_PMs1[[2]][13][[1]])
svc_sheets_cddo[i,38] = ifelse(is.null(sheets_PMs1[[3]][13][[1]]) == TRUE, NA, sheets_PMs1[[3]][13][[1]])
svc_sheets_cddo[i,39] = ifelse(is.null(sheets_PMs1[[4]][13][[1]]) == TRUE, NA, sheets_PMs1[[4]][13][[1]])

# Users - Respondents
svc_sheets_cddo[i,40] = ifelse(is.null(sheets_PMs1[[2]][14][[1]]) == TRUE, NA, sheets_PMs1[[2]][14][[1]])
svc_sheets_cddo[i,41] = ifelse(is.null(sheets_PMs1[[3]][14][[1]]) == TRUE, NA, sheets_PMs1[[3]][14][[1]])
svc_sheets_cddo[i,42] = ifelse(is.null(sheets_PMs1[[4]][14][[1]]) == TRUE, NA, sheets_PMs1[[4]][14][[1]])

# Users - Journey Time
svc_sheets_cddo[i,43] = ifelse(is.null(sheets_PMs1[[2]][15][[1]]) == TRUE, NA, sheets_PMs1[[2]][15][[1]])
svc_sheets_cddo[i,44] = ifelse(is.null(sheets_PMs1[[3]][15][[1]]) == TRUE, NA, sheets_PMs1[[3]][15][[1]])
svc_sheets_cddo[i,45] = ifelse(is.null(sheets_PMs1[[4]][15][[1]]) == TRUE, NA, sheets_PMs1[[4]][15][[1]])

# Automated Transactions
svc_sheets_cddo[i,46] = ifelse(is.null(sheets_PMs1[[2]][16][[1]]) == TRUE, NA, sheets_PMs1[[2]][16][[1]])
svc_sheets_cddo[i,47] = ifelse(is.null(sheets_PMs1[[3]][16][[1]]) == TRUE, NA, sheets_PMs1[[3]][16][[1]])
svc_sheets_cddo[i,48] = ifelse(is.null(sheets_PMs1[[4]][16][[1]]) == TRUE, NA, sheets_PMs1[[4]][16][[1]])


## Pull out Performance Metrics for specific services (if no data present in table AT ALL, 
# will say names must be same attribute as vector)
sheets_PMs2 <- read_sheet(sheets_list$id[i]
        , sheet = 3
        , range = "A27:F36"
        , col_names = FALSE
    )

# KPI1
svc_sheets_servspec[i,1] = ifelse(is.null(sheets_PMs2[[2]][1][[1]]) == TRUE, NA, sheets_PMs2[[2]][1][[1]])
svc_sheets_servspec[i,2] = ifelse(is.null(sheets_PMs2[[3]][1][[1]]) == TRUE, NA, sheets_PMs2[[3]][1][[1]])
svc_sheets_servspec[i,3] = ifelse(is.null(sheets_PMs2[[4]][1][[1]]) == TRUE, NA, sheets_PMs2[[4]][1][[1]])
svc_sheets_servspec[i,4] = ifelse(is.null(sheets_PMs2[[5]][1][[1]]) == TRUE, NA, sheets_PMs2[[5]][1][[1]])
svc_sheets_servspec[i,5] = ifelse(is.null(sheets_PMs2[[6]][1][[1]]) == TRUE, NA, sheets_PMs2[[6]][1][[1]])

# KPI2
svc_sheets_servspec[i,6] = ifelse(is.null(sheets_PMs2[[2]][2][[1]]) == TRUE, NA, sheets_PMs2[[2]][2][[1]])
svc_sheets_servspec[i,7] = ifelse(is.null(sheets_PMs2[[3]][2][[1]]) == TRUE, NA, sheets_PMs2[[3]][2][[1]])
svc_sheets_servspec[i,8] = ifelse(is.null(sheets_PMs2[[4]][2][[1]]) == TRUE, NA, sheets_PMs2[[4]][2][[1]])
svc_sheets_servspec[i,9] = ifelse(is.null(sheets_PMs2[[5]][2][[1]]) == TRUE, NA, sheets_PMs2[[5]][2][[1]])
svc_sheets_servspec[i,10] = ifelse(is.null(sheets_PMs2[[6]][2][[1]]) == TRUE, NA, sheets_PMs2[[6]][2][[1]])

# KPI3
svc_sheets_servspec[i,11] = ifelse(is.null(sheets_PMs2[[2]][3][[1]]) == TRUE, NA, sheets_PMs2[[2]][3][[1]])
svc_sheets_servspec[i,12] = ifelse(is.null(sheets_PMs2[[3]][3][[1]]) == TRUE, NA, sheets_PMs2[[3]][3][[1]])
svc_sheets_servspec[i,13] = ifelse(is.null(sheets_PMs2[[4]][3][[1]]) == TRUE, NA, sheets_PMs2[[4]][3][[1]])
svc_sheets_servspec[i,14] = ifelse(is.null(sheets_PMs2[[5]][3][[1]]) == TRUE, NA, sheets_PMs2[[5]][3][[1]])
svc_sheets_servspec[i,15] = ifelse(is.null(sheets_PMs2[[6]][3][[1]]) == TRUE, NA, sheets_PMs2[[6]][3][[1]])

# KPI4
svc_sheets_servspec[i,16] = ifelse(is.null(sheets_PMs2[[2]][4][[1]]) == TRUE, NA, sheets_PMs2[[2]][4][[1]])
svc_sheets_servspec[i,17] = ifelse(is.null(sheets_PMs2[[3]][4][[1]]) == TRUE, NA, sheets_PMs2[[3]][4][[1]])
svc_sheets_servspec[i,18] = ifelse(is.null(sheets_PMs2[[4]][4][[1]]) == TRUE, NA, sheets_PMs2[[4]][4][[1]])
svc_sheets_servspec[i,19] = ifelse(is.null(sheets_PMs2[[5]][4][[1]]) == TRUE, NA, sheets_PMs2[[5]][4][[1]])
svc_sheets_servspec[i,20] = ifelse(is.null(sheets_PMs2[[6]][4][[1]]) == TRUE, NA, sheets_PMs2[[6]][4][[1]])

# KPI5
svc_sheets_servspec[i,21] = ifelse(is.null(sheets_PMs2[[2]][5][[1]]) == TRUE, NA, sheets_PMs2[[2]][5][[1]])
svc_sheets_servspec[i,22] = ifelse(is.null(sheets_PMs2[[3]][5][[1]]) == TRUE, NA, sheets_PMs2[[3]][5][[1]])
svc_sheets_servspec[i,23] = ifelse(is.null(sheets_PMs2[[4]][5][[1]]) == TRUE, NA, sheets_PMs2[[4]][5][[1]])
svc_sheets_servspec[i,24] = ifelse(is.null(sheets_PMs2[[5]][5][[1]]) == TRUE, NA, sheets_PMs2[[5]][5][[1]])
svc_sheets_servspec[i,25] = ifelse(is.null(sheets_PMs2[[6]][5][[1]]) == TRUE, NA, sheets_PMs2[[6]][5][[1]])

# KPI6
svc_sheets_servspec[i,26] = ifelse(is.null(sheets_PMs2[[2]][6][[1]]) == TRUE, NA, sheets_PMs2[[2]][6][[1]])
svc_sheets_servspec[i,27] = ifelse(is.null(sheets_PMs2[[3]][6][[1]]) == TRUE, NA, sheets_PMs2[[3]][6][[1]])
svc_sheets_servspec[i,28] = ifelse(is.null(sheets_PMs2[[4]][6][[1]]) == TRUE, NA, sheets_PMs2[[4]][6][[1]])
svc_sheets_servspec[i,29] = ifelse(is.null(sheets_PMs2[[5]][6][[1]]) == TRUE, NA, sheets_PMs2[[5]][6][[1]])
svc_sheets_servspec[i,30] = ifelse(is.null(sheets_PMs2[[6]][6][[1]]) == TRUE, NA, sheets_PMs2[[6]][6][[1]])

# KPI7
svc_sheets_servspec[i,31] = ifelse(is.null(sheets_PMs2[[2]][7][[1]]) == TRUE, NA, sheets_PMs2[[2]][7][[1]])
svc_sheets_servspec[i,32] = ifelse(is.null(sheets_PMs2[[3]][7][[1]]) == TRUE, NA, sheets_PMs2[[3]][7][[1]])
svc_sheets_servspec[i,33] = ifelse(is.null(sheets_PMs2[[4]][7][[1]]) == TRUE, NA, sheets_PMs2[[4]][7][[1]])
svc_sheets_servspec[i,34] = ifelse(is.null(sheets_PMs2[[5]][7][[1]]) == TRUE, NA, sheets_PMs2[[5]][7][[1]])
svc_sheets_servspec[i,35] = ifelse(is.null(sheets_PMs2[[6]][7][[1]]) == TRUE, NA, sheets_PMs2[[6]][7][[1]])

# KPI8
svc_sheets_servspec[i,36] = ifelse(is.null(sheets_PMs2[[2]][8][[1]]) == TRUE, NA, sheets_PMs2[[2]][8][[1]])
svc_sheets_servspec[i,37] = ifelse(is.null(sheets_PMs2[[3]][8][[1]]) == TRUE, NA, sheets_PMs2[[3]][8][[1]])
svc_sheets_servspec[i,38] = ifelse(is.null(sheets_PMs2[[4]][8][[1]]) == TRUE, NA, sheets_PMs2[[4]][8][[1]])
svc_sheets_servspec[i,39] = ifelse(is.null(sheets_PMs2[[5]][8][[1]]) == TRUE, NA, sheets_PMs2[[5]][8][[1]])
svc_sheets_servspec[i,40] = ifelse(is.null(sheets_PMs2[[6]][8][[1]]) == TRUE, NA, sheets_PMs2[[6]][8][[1]])

# KPI9
svc_sheets_servspec[i,41] = ifelse(is.null(sheets_PMs2[[2]][9][[1]]) == TRUE, NA, sheets_PMs2[[2]][9][[1]])
svc_sheets_servspec[i,42] = ifelse(is.null(sheets_PMs2[[3]][9][[1]]) == TRUE, NA, sheets_PMs2[[3]][9][[1]])
svc_sheets_servspec[i,43] = ifelse(is.null(sheets_PMs2[[4]][9][[1]]) == TRUE, NA, sheets_PMs2[[4]][9][[1]])
svc_sheets_servspec[i,44] = ifelse(is.null(sheets_PMs2[[5]][9][[1]]) == TRUE, NA, sheets_PMs2[[5]][9][[1]])
svc_sheets_servspec[i,45] = ifelse(is.null(sheets_PMs2[[6]][9][[1]]) == TRUE, NA, sheets_PMs2[[6]][9][[1]])

# KPI10
svc_sheets_servspec[i,46] = ifelse(is.null(sheets_PMs2[[2]][10][[1]]) == TRUE, NA, sheets_PMs2[[2]][10][[1]])
svc_sheets_servspec[i,47] = ifelse(is.null(sheets_PMs2[[3]][10][[1]]) == TRUE, NA, sheets_PMs2[[3]][10][[1]])
svc_sheets_servspec[i,48] = ifelse(is.null(sheets_PMs2[[4]][10][[1]]) == TRUE, NA, sheets_PMs2[[4]][10][[1]])
svc_sheets_servspec[i,49] = ifelse(is.null(sheets_PMs2[[5]][10][[1]]) == TRUE, NA, sheets_PMs2[[5]][10][[1]])
svc_sheets_servspec[i,50] = ifelse(is.null(sheets_PMs2[[6]][10][[1]]) == TRUE, NA, sheets_PMs2[[6]][10][[1]])


### Pull out Pain Point metrics for CDDO (if no data present in table AT ALL, 
# will say names must be same attribute as vector)
sheets_PPs <- read_sheet(sheets_list$id[i]
        , sheet = 4
        , range = "B8:F45"
        , col_names = TRUE
    )

## Populate CDDO Pain Point table 
# Customer Support
svc_sheets_PP[i,1] = ifelse(is.null(sheets_PPs[[3]][1][[1]]) == TRUE, NA, sheets_PPs[[3]][1][[1]])
svc_sheets_PP[i,2] = ifelse(is.null(sheets_PPs[[3]][2][[1]]) == TRUE, NA, sheets_PPs[[3]][2][[1]])
svc_sheets_PP[i,3] = ifelse(is.null(sheets_PPs[[3]][3][[1]]) == TRUE, NA, sheets_PPs[[3]][3][[1]])
svc_sheets_PP[i,4] = ifelse(is.null(sheets_PPs[[4]][1][[1]]) == TRUE, NA, sheets_PPs[[4]][1][[1]])
svc_sheets_PP[i,5] = ifelse(is.null(sheets_PPs[[5]][1][[1]]) == TRUE, NA, sheets_PPs[[5]][1][[1]])

# Use of Paper
svc_sheets_PP[i,6] = ifelse(is.null(sheets_PPs[[3]][6][[1]]) == TRUE, NA, sheets_PPs[[3]][6][[1]])
svc_sheets_PP[i,7] = ifelse(is.null(sheets_PPs[[3]][7][[1]]) == TRUE, NA, sheets_PPs[[3]][7][[1]])
svc_sheets_PP[i,8] = ifelse(is.null(sheets_PPs[[3]][9][[1]]) == TRUE, NA, sheets_PPs[[3]][9][[1]])
svc_sheets_PP[i,9] = ifelse(is.null(sheets_PPs[[3]][10][[1]]) == TRUE, NA, sheets_PPs[[3]][10][[1]])
svc_sheets_PP[i,10] = ifelse(is.null(sheets_PPs[[3]][12][[1]]) == TRUE, NA, sheets_PPs[[3]][12][[1]])
svc_sheets_PP[i,11] = ifelse(is.null(sheets_PPs[[3]][13][[1]]) == TRUE, NA, sheets_PPs[[3]][13][[1]])
svc_sheets_PP[i,12] = ifelse(is.null(sheets_PPs[[4]][6][[1]]) == TRUE, NA, sheets_PPs[[4]][6][[1]])
svc_sheets_PP[i,13] = ifelse(is.null(sheets_PPs[[5]][6][[1]]) == TRUE, NA, sheets_PPs[[5]][6][[1]])

# Automated Processing
svc_sheets_PP[i,14] = ifelse(is.null(sheets_PPs[[3]][15][[1]]) == TRUE, NA, sheets_PPs[[3]][15][[1]])
svc_sheets_PP[i,15] = ifelse(is.null(sheets_PPs[[3]][16][[1]]) == TRUE, NA, sheets_PPs[[3]][16][[1]])
svc_sheets_PP[i,16] = ifelse(is.null(sheets_PPs[[3]][17][[1]]) == TRUE, NA, sheets_PPs[[3]][17][[1]])
svc_sheets_PP[i,17] = ifelse(is.null(sheets_PPs[[4]][15][[1]]) == TRUE, NA, sheets_PPs[[4]][15][[1]])
svc_sheets_PP[i,18] = ifelse(is.null(sheets_PPs[[5]][15][[1]]) == TRUE, NA, sheets_PPs[[5]][15][[1]])

# Legacy IT
svc_sheets_PP[i,19] = ifelse(is.null(sheets_PPs[[3]][19][[1]]) == TRUE, NA, sheets_PPs[[3]][19][[1]])
svc_sheets_PP[i,20] = ifelse(is.null(sheets_PPs[[4]][19][[1]]) == TRUE, NA, sheets_PPs[[4]][19][[1]])
svc_sheets_PP[i,21] = ifelse(is.null(sheets_PPs[[5]][19][[1]]) == TRUE, NA, sheets_PPs[[5]][19][[1]])

# Performance Monitoring
svc_sheets_PP[i,22] = ifelse(is.null(sheets_PPs[[3]][22][[1]]) == TRUE, NA, sheets_PPs[[3]][22][[1]])
svc_sheets_PP[i,23] = ifelse(is.null(sheets_PPs[[3]][24][[1]]) == TRUE, NA, sheets_PPs[[3]][24][[1]])
svc_sheets_PP[i,24] = ifelse(is.null(sheets_PPs[[4]][22][[1]]) == TRUE, NA, sheets_PPs[[4]][22][[1]])
svc_sheets_PP[i,25] = ifelse(is.null(sheets_PPs[[5]][22][[1]]) == TRUE, NA, sheets_PPs[[4]][22][[1]])

# Additional characteristics
svc_sheets_PP[i,26] = ifelse(is.null(sheets_PPs[[3]][27][[1]]) == TRUE, NA, sheets_PPs[[3]][27][[1]])
svc_sheets_PP[i,27] = ifelse(is.null(sheets_PPs[[3]][29][[1]]) == TRUE, NA, sheets_PPs[[3]][29][[1]])
svc_sheets_PP[i,28] = ifelse(is.null(sheets_PPs[[3]][30][[1]]) == TRUE, NA, sheets_PPs[[3]][30][[1]])

# Usability - Compliance
svc_sheets_PP[i,29] = ifelse(is.null(sheets_PPs[[3]][33][[1]]) == TRUE, NA, sheets_PPs[[3]][33][[1]])
svc_sheets_PP[i,30] = ifelse(is.null(sheets_PPs[[4]][33][[1]]) == TRUE, NA, sheets_PPs[[4]][33][[1]])
svc_sheets_PP[i,31] = ifelse(is.null(sheets_PPs[[5]][33][[1]]) == TRUE, NA, sheets_PPs[[5]][33][[1]])

# Usability - Complex Eligibility
svc_sheets_PP[i,32] = ifelse(is.null(sheets_PPs[[3]][35][[1]]) == TRUE, NA, sheets_PPs[[3]][35][[1]])
svc_sheets_PP[i,33] = ifelse(is.null(sheets_PPs[[4]][35][[1]]) == TRUE, NA, sheets_PPs[[4]][35][[1]])
svc_sheets_PP[i,34] = ifelse(is.null(sheets_PPs[[5]][35][[1]]) == TRUE, NA, sheets_PPs[[5]][35][[1]])

### This section no longer needed because of incorrect template sent out,
## keep for now as likely need it for next run.
# Usability - Accessibility
#svc_sheets_PP[i,29] = sheets_PPs[[1]][33]
#svc_sheets_PP[i,30] = sheets_PPs[[2]][33]
#svc_sheets_PP[i,31] = sheets_PPs[[3]][33]

# Usability - Burden
#svc_sheets_PP[i,34] = sheets_PPs[[1]][35]
#svc_sheets_PP[i,35] = sheets_PPs[[2]][35]
#svc_sheets_PP[i,35] = sheets_PPs[[3]][35]


### Pull out Pain Point metrics for service (if no data present in table AT ALL, 
# will say names must be same attribute as vector)
sheets_ssPPs <- read_sheet(sheets_list$id[i]
        , sheet = 4
        , range = "A48:D58" # Once template is corrected, should be A50:D60
        , col_names = TRUE
    )

## Populate Service Pain Point table, grouped by Theme
svc_sheets_ssPP[i,1] = ifelse(is.null(sheets_ssPPs[[2]][1][[1]]) == TRUE, NA, sheets_ssPPs[[2]][1][[1]])
svc_sheets_ssPP[i,2] = ifelse(is.null(sheets_ssPPs[[3]][1][[1]]) == TRUE, NA, sheets_ssPPs[[3]][1][[1]])
svc_sheets_ssPP[i,3] = ifelse(is.null(sheets_ssPPs[[4]][1][[1]]) == TRUE, NA, sheets_ssPPs[[4]][1][[1]])

svc_sheets_ssPP[i,4] = ifelse(is.null(sheets_ssPPs[[2]][2][[1]]) == TRUE, NA, sheets_ssPPs[[2]][2][[1]])
svc_sheets_ssPP[i,5] = ifelse(is.null(sheets_ssPPs[[3]][2][[1]]) == TRUE, NA, sheets_ssPPs[[3]][2][[1]])
svc_sheets_ssPP[i,6] = ifelse(is.null(sheets_ssPPs[[4]][2][[1]]) == TRUE, NA, sheets_ssPPs[[4]][2][[1]])

svc_sheets_ssPP[i,7] = ifelse(is.null(sheets_ssPPs[[2]][3][[1]]) == TRUE, NA, sheets_ssPPs[[2]][3][[1]])
svc_sheets_ssPP[i,8] = ifelse(is.null(sheets_ssPPs[[3]][3][[1]]) == TRUE, NA, sheets_ssPPs[[3]][3][[1]])
svc_sheets_ssPP[i,9] = ifelse(is.null(sheets_ssPPs[[4]][3][[1]]) == TRUE, NA, sheets_ssPPs[[4]][3][[1]])

svc_sheets_ssPP[i,10] = ifelse(is.null(sheets_ssPPs[[2]][4][[1]]) == TRUE, NA, sheets_ssPPs[[2]][4][[1]])
svc_sheets_ssPP[i,11] = ifelse(is.null(sheets_ssPPs[[3]][4][[1]]) == TRUE, NA, sheets_ssPPs[[3]][4][[1]])
svc_sheets_ssPP[i,12] = ifelse(is.null(sheets_ssPPs[[4]][4][[1]]) == TRUE, NA, sheets_ssPPs[[4]][4][[1]])

svc_sheets_ssPP[i,13] = ifelse(is.null(sheets_ssPPs[[2]][5][[1]]) == TRUE, NA, sheets_ssPPs[[2]][5][[1]])
svc_sheets_ssPP[i,14] = ifelse(is.null(sheets_ssPPs[[3]][5][[1]]) == TRUE, NA, sheets_ssPPs[[3]][5][[1]])
svc_sheets_ssPP[i,15] = ifelse(is.null(sheets_ssPPs[[4]][5][[1]]) == TRUE, NA, sheets_ssPPs[[4]][5][[1]])

svc_sheets_ssPP[i,16] = ifelse(is.null(sheets_ssPPs[[2]][6][[1]]) == TRUE, NA, sheets_ssPPs[[2]][6][[1]])
svc_sheets_ssPP[i,17] = ifelse(is.null(sheets_ssPPs[[3]][6][[1]]) == TRUE, NA, sheets_ssPPs[[3]][6][[1]])
svc_sheets_ssPP[i,18] = ifelse(is.null(sheets_ssPPs[[4]][6][[1]]) == TRUE, NA, sheets_ssPPs[[4]][6][[1]])

svc_sheets_ssPP[i,19] = ifelse(is.null(sheets_ssPPs[[2]][7][[1]]) == TRUE, NA, sheets_ssPPs[[2]][7][[1]])
svc_sheets_ssPP[i,20] = ifelse(is.null(sheets_ssPPs[[3]][7][[1]]) == TRUE, NA, sheets_ssPPs[[3]][7][[1]])
svc_sheets_ssPP[i,21] = ifelse(is.null(sheets_ssPPs[[4]][7][[1]]) == TRUE, NA, sheets_ssPPs[[4]][7][[1]])

svc_sheets_ssPP[i,22] = ifelse(is.null(sheets_ssPPs[[2]][8][[1]]) == TRUE, NA, sheets_ssPPs[[2]][8][[1]])
svc_sheets_ssPP[i,23] = ifelse(is.null(sheets_ssPPs[[3]][8][[1]]) == TRUE, NA, sheets_ssPPs[[3]][8][[1]])
svc_sheets_ssPP[i,24] = ifelse(is.null(sheets_ssPPs[[4]][8][[1]]) == TRUE, NA, sheets_ssPPs[[4]][8][[1]])

svc_sheets_ssPP[i,25] = ifelse(is.null(sheets_ssPPs[[2]][9][[1]]) == TRUE, NA, sheets_ssPPs[[2]][9][[1]])
svc_sheets_ssPP[i,26] = ifelse(is.null(sheets_ssPPs[[3]][9][[1]]) == TRUE, NA, sheets_ssPPs[[3]][9][[1]])
svc_sheets_ssPP[i,27] = ifelse(is.null(sheets_ssPPs[[4]][9][[1]]) == TRUE, NA, sheets_ssPPs[[4]][9][[1]])

svc_sheets_ssPP[i,28] = ifelse(is.null(sheets_ssPPs[[2]][10][[1]]) == TRUE, NA, sheets_ssPPs[[2]][10][[1]])
svc_sheets_ssPP[i,29] = ifelse(is.null(sheets_ssPPs[[3]][10][[1]]) == TRUE, NA, sheets_ssPPs[[3]][10][[1]])
svc_sheets_ssPP[i,30] = ifelse(is.null(sheets_ssPPs[[4]][10][[1]]) == TRUE, NA, sheets_ssPPs[[4]][10][[1]])

}


