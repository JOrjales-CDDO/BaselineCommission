######################################
# 03_DataCollate.R
######################################

# This script is designed to collate the tables together from reading 
# in google sheets and do cleaning on them before they are linked 
# together.

#### Set up some custom functions for QA -----------------------

# Convert specific cell values like "unknown" and "N/A" to NAs
replace_NA_unknown <- function(data) {
  for (col in 1:ncol(data)) {
    for (row in 1:nrow(data)) {
      if (isTRUE(data[row, col] == "N/A" || 
      data[row, col] == "n/a" || 
      data[row, col] == "N/a" || 
      data[row, col] == "NA" ||
      data[row, col] == "Unknown" || 
      data[row, col] == "Not known" || 
      data[row, col] == " " || 
      data[row, col] == "Data not available"
    )) {
        data[row, col] <- NA
      }
    }
  }
  return(data)
}


# Calculate the proportion of NAs across entire table
section_nas <- function(df) {
  
  na_prop <- colMeans(!is.na(df), na.rm = TRUE)
  
  # Return the mean of the NA proportions across all columns
  return(mean(na_prop))
}

# Calculate the proportion of NAs by row across table
row_nas <- function(df) {
  
  na_prop <- apply(df, 1, function(x) {
    sum(!is.na(x)) / length(x)
  })
  
  # Return as data frame we can extract from
  
  return(data.frame(na_prop))
}

## Convenience function to derive NA proportion per column
check_completeness_section <- function(x) {
  # Return the number of non-missing values divided by the total number of values
  return(sum(!is.na(x)) / length(x))
}

## Function to create summary of section completeness by field within a 
# given section table. By default, any columns you specify won't be included in
# summary table unless you specify remove = FALSE, then includes ONLY those 
# columns
# test2 <- fieldsection_maker(svc_sheets_cddo, c("AddInfo", "FreeText")). If leave 
# blank, it calculates completeness for every field.
fieldsection_maker <- function(df, names = NULL, remove = TRUE) {
  if(is.null(names)){
    
    output <- as.data.frame(df %>% 
                              summarize_all(funs(check_completeness_section)) %>% 
                              t()) %>% 
      rename(`Proportion Complete` = 1) %>% 
      mutate(`Proportion Complete` = round(`Proportion Complete` * 100.0, 1))
    
  } else {
    
    if(remove == TRUE) {
      output <- as.data.frame(df %>% 
                              select(-contains(names)
                                     ) %>% 
                              summarize_all(funs(check_completeness_section)) %>% 
                              t()) %>% 
        rename(`Proportion Complete` = 1) %>% 
        mutate(`Proportion Complete` = round(`Proportion Complete` * 100.0, 1))
    
    } else {
      output <- as.data.frame(df %>% 
                                select(contains(names)
                                ) %>% 
                                summarize_all(funs(check_completeness_section)) %>% 
                                t()) %>% 
        rename(`Proportion Complete` = 1) %>% 
        mutate(`Proportion Complete` = round(`Proportion Complete` * 100.0, 1))
    }
    
    
  }
  return(output)
}

#### Set some variable values-------------------------------------------
AVGFTECost = 41500 # Provided by Ed Mack, EO FTE overhead.
WkHrsYr = 1857.4 # 7.4 hours/day, 251 working days.

#### Cleaning and Transformation----------------------------------------

### Cleaning------------------------------------------------------------

### Context Table
svc_sheets_cntxt <- svc_sheets_cntxt %>% 
    mutate(
        URLGovUKStart = str_replace(URLGovUKStart, "https://www.gov.uk", "")

    # Clean up the department names subject to what we expect!
    , DepartmentParent = ifelse(
        str_detect(ServiceID, "CO") == TRUE
        , "Cabinet Office"
        , ifelse(
            str_detect(ServiceID, "BEIS") == TRUE
            , "Department for Business, Energy & Industrial Strategy"
            , ifelse(
                str_detect(ServiceID, "DCMS") == TRUE
                , "Department for Digital, Culture, Media & Sport"
                , ifelse(
                    str_detect(ServiceID, "DFE") == TRUE
                    , "Department for Education"
                    , ifelse(
                        str_detect(ServiceID, "DEFRA") == TRUE
                        , "Department for Environment, Food & Rural Affairs"
                        , ifelse(
                            str_detect(ServiceID, "DIT") == TRUE
                            , "Department for International Trade"
                            , ifelse(
                                str_detect(ServiceID, "DLUHC") == TRUE
                                , "Department for Levelling Up, Housing & Communities"
                                , ifelse(
                                    str_detect(ServiceID, "DFT") == TRUE
                                    , "Department for Transport"
                                    , ifelse(
                                        str_detect(ServiceID, "DWP") == TRUE
                                        , "Department for Work & Pensions"
                                        , ifelse(
                                            str_detect(ServiceID, "DHSC") == TRUE
                                            , "Department of Health & Social Care"
                                            , ifelse(
                                                str_detect(ServiceID, "FCDO") == TRUE
                                                , "Foreign, Commonwealth & Development Office"
                                                , ifelse(
                                                    str_detect(ServiceID, "HMT") == TRUE
                                                    , "HM Treasury"
                                                    , ifelse(
                                                        str_detect(ServiceID, "HMRC") == TRUE
                                                        , "HM Revenue & Customs"
                                                        , ifelse(
                                                            str_detect(ServiceID, "HO") == TRUE
                                                            , "Home Office"
                                                            , ifelse(str_detect(ServiceID, "MOD") == TRUE
                                                            , "Ministry of Defence"
                                                            , ifelse(
                                                                str_detect(ServiceID, "MOJ") == TRUE
                                                                , "Ministry of Justice"
                                                                , ifelse(
                                                                    str_detect(ServiceID, "SLC") == TRUE
                                                                    , "Student Loans Company"
                                                                    , ifelse(
                                                                        str_detect(ServiceID, "DVSA") == TRUE
                                                                        , "Driver & Vehicle Standards Agency"
                                                                        , "NEW DEPARTMENT OR ALB"
                                                                    ))))))))))))))))))
    )




### Objectives table

### CDDO KPIs - most are just expected raw numbers
svc_sheets_cddo <- svc_sheets_cddo %>% 
    mutate(
        
        # Non Staff Costs
        NonStaffCost = as.numeric(ifelse(str_detect(NonStaffCost, "£") == TRUE
            , gsub("£", "", NonStaffCost), NonStaffCost)
        )

        # Started Digital Transactions - replace zero with NA to avoid 
        # inf if completed digital != 0
        , StartedDigitalTransactions = ifelse(StartedDigitalTransactions == 0 &
            (CompletedDigitalTransactions != 0 | !is.na(CompletedDigitalTransactions))
                , NA, StartedDigitalTransactions
            )

        # Timeliness KPI conversions
        , UsersJourneyTimeFlag = ifelse(str_detect(UsersJourneyTimeHours, "d") == TRUE, "days"
            , ifelse(str_detect(UsersJourneyTimeHours, "h") == TRUE, "hours"
                , ifelse(str_detect(UsersJourneyTimeHours, "ms") == TRUE, "months"
                    , ifelse(str_detect(UsersJourneyTimeHours, "w") == TRUE, "weeks"
                        , ifelse(str_detect(UsersJourneyTimeHours, "m") == TRUE, "minutes"
                            , "other"
                        )))))
        
        , UsersJourneyTime2 = ifelse(UsersJourneyTimeFlag == "minutes"
            , str_replace(UsersJourneyTimeHours, "m", "")
            , ifelse(UsersJourneyTimeFlag == "hours"
                , str_replace(UsersJourneyTimeHours, "h", "")
                , ifelse(UsersJourneyTimeFlag == "days"
                    , str_replace(UsersJourneyTimeHours, "d", "")
                    , ifelse(UsersJourneyTimeFlag == "weeks"
                        , str_replace(UsersJourneyTimeHours, "w", "")
                        , ifelse(UsersJourneyTimeFlag == "months"
                            , str_replace(UsersJourneyTimeHours, "ms", "")
                            , NA
                        )))))

        , UsersJourneyTimeHours = ifelse(UsersJourneyTimeFlag == "minutes"
            , round(as.numeric(UsersJourneyTime2) / 60.0, 2)
            , ifelse(UsersJourneyTimeFlag == "days"
                , round(as.numeric(UsersJourneyTime2) * 24.0, 2)
                , ifelse(UsersJourneyTimeFlag == "hours"
                    , round(as.numeric(UsersJourneyTime2), 2)
                    , ifelse(UsersJourneyTimeFlag == "weeks"
                        # Based on 365.25 days X 24 hours / 52 weeks = 168.6 hours
                        , round(as.numeric(UsersJourneyTime2) * 168.6, 2)
                        , ifelse(UsersJourneyTimeFlag == "months"
                        # Based on 365.25 days X 24 hours / 12 months = 730.5 hours
                            , round(as.numeric(UsersJourneyTime2) * 730.5, 2)
                            , NA
                    )))))
    ) %>% 

## Remove working columns as final step
select(-UsersJourneyTimeFlag
    , -UsersJourneyTime2)

### Service - Specific KPI Summary
svc_sheets_servspec <- svc_sheets_servspec %>% 
    mutate(
        KPI1_Name = ifelse(KPI1_Name == "This is space to add your own KPIs for your service. See \"About this section\" above for guidance." | 
        is.na(KPI1_Name) == TRUE |
        KPI1_Name == "", 
        NA, KPI1_Name)
    )

### Pain Points
svc_sheets_PP <- svc_sheets_PP %>% 
  
  # Remove placeholder for Compliant Challenges text field (not currently used)
  select(-`Usability_CompliantChallengesText`) %>% 

  ## Replace blank cell values with NAs and remove placeholder texts
  replace_with_na_all(condition = ~.x == "") %>% 
  
  ## Customer Support section
  mutate(
        CSupport_ImprovementsText = gsub("any steps being taken to reduce burden on customer support teams", NA, 
                                         CSupport_ImprovementsText)
        , CSupport_ChallengesText = gsub("or have low impact in reducing burden to customer support teams", NA, 
                                         CSupport_ChallengesText)
    
    ## Paper Use Section
        , PaperUse_ImprovementsText = gsub("any steps being taken to reduce use of paper when conducting transactions", NA, 
                                           PaperUse_ImprovementsText)
        , PaperUse_ChallengesText = gsub("challenges that the service has which prevent", NA, 
                                         PaperUse_ChallengesText)
    
    ## Auto
        , Auto_ImprovementsText = gsub("any steps being taken to increase automated processing", NA, Auto_ImprovementsText)
        , Auto_ChallengesText = gsub("circumstances or challenges does your service have", NA, Auto_ChallengesText)
    
    ## Legacy
        , Legacy_ImprovementsText = gsub("What impacts could this have on the running costs", NA, Legacy_ImprovementsText)
        , Legacy_ChallengesText = gsub("does your service have to overcoming legacy", NA, Legacy_ChallengesText)

    ## Performance Monitoring
        , PMonitoring_ImprovementsText = gsub("plans to introduce or extend these features", NA, PMonitoring_ImprovementsText)
        , PMonitoring_ChallengesText = gsub("circumstances or challenges does your service have which", NA, PMonitoring_ChallengesText)    

    ## Usability
        , Usability_CompliantImprovementsText = gsub("what are the plans to achieve compliance", NA, Usability_CompliantImprovementsText)
        #, Usability_CompliantChallengesText = gsub("", NA, Usability_CompliantChallengesText) 
    
        , Usability_ComplexImprovementsText = gsub("plans to lighten the complexity for users or staff", NA, Usability_ComplexImprovementsText)
        , Usability_ComplexChallengesText = gsub("challenges does your service have which makes complex eligibility", NA, Usability_ComplexChallengesText)
    
  )

#### Replace strings like "N/A", "Unknown", "blank", "not sure", "" with NA for all tables
svc_sheets_cntxt <- replace_NA_unknown(svc_sheets_cntxt)
svc_sheets_objctvs <- replace_NA_unknown(svc_sheets_objctvs)
svc_sheets_cddo <- replace_NA_unknown(svc_sheets_cddo)
svc_sheets_servspec <- replace_NA_unknown(svc_sheets_servspec)
svc_sheets_PP <- replace_NA_unknown(svc_sheets_PP)
svc_sheets_ssPP <- replace_NA_unknown(svc_sheets_ssPP)

#### Create tables for Google sheet -------------------------------------

### Context and Objectives
svc_sheets_cntxtobjectvs  <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUKStart
        )
    , svc_sheets_objctvs
)

### Context and CDDO KPIs
svc_sheets_cntxtcddo <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUKStart
        )
    , svc_sheets_cddo
)

### Context and Service Specific KPIs
svc_sheets_cntxtservspec  <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUKStart
        )
    , svc_sheets_servspec
)

### Context and Pain Points
svc_sheets_cntxtPP  <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUKStart
        )
    , svc_sheets_PP
)

### Context and Service Specific Pain Points
svc_sheets_cntxtssPP <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLService
        , URLGovUKStart
        )
    , svc_sheets_ssPP
)


#### Calculated fields--------------------------------------------------

#### Bespoke tables for analysis----------------------------------------

### CCDO KPI Calculations

svc_sheets_KPIcalcs <- svc_sheets_cddo %>%
    mutate(
        CDDOKPI_DigitalAdoption = round(as.numeric(CompletedDigitalTransactions) / 
        as.numeric(CompletedTransactions) * 100.0, 1)

        , CDDOKPI_DigitalCompletion = round(as.numeric(CompletedDigitalTransactions) / 
        as.numeric(StartedDigitalTransactions) * 100.0, 1)

        , CDDOKPI_UserSatisfaction = round((as.numeric(UsersVerySatisfied) + 
            as.numeric(UsersSatisfied)) / as.numeric(UsersTotalSatisfactionRespondents) * 100.0, 1)

        , CDDOKPI_TransactionCost = round((as.numeric(FTECount) * AVGFTECost + 
            NonStaffCost) / as.numeric(CompletedTransactions), 2)

        , CDDOKPI_StaffTime = round((as.numeric(FTECount) * WkHrsYr) / 
            as.numeric(CompletedTransactions), 1)

        , CDDOKPI_FailureDemand = round(
            (as.numeric(UsersEmail) + as.numeric(UsersPhone) + as.numeric(UsersLetters)) /
            as.numeric(CompletedTransactions) * 100.0, 1)
            
        )  %>% 
    select(CompletedDigitalTransactions
    , CompletedTransactions
    , StartedDigitalTransactions
    , UsersVerySatisfied 
    , UsersSatisfied 
    , UsersTotalSatisfactionRespondents
    , FTECount
    , NonStaffCost
    , UsersEmail
    , UsersPhone
    , UsersLetters
    # , CDDOKPI_DigitalAdoption
    # , CDDOKPI_DigitalCompletion
    # , CDDOKPI_UserSatisfaction
    , Complaints
    # , UsersJourneyTimeHours
    # , CDDOKPI_TransactionCost
    # , CDDOKPI_StaffTime
    , AutomatedTransactions
    # , CDDOKPI_FailureDemand
    )

bespoke_CDDOKPI <- cbind(svc_sheets_cntxt %>%
    select(ServiceID
        , Service
        , URLGovUKStart
        , DepartmentParent
        , DepartmentChild
    )
    , svc_sheets_KPIcalcs)


### Opportunity Analysis
bespoke_OppA <- cbind(svc_sheets_cntxt
    , svc_sheets_PP
    , svc_sheets_cddo
    # , svc_sheets_KPIcalcs %>% 
    #     select(AutomatedTransactions
    #            , FTECount
    #            , NonStaffCost
    #            , UsersEmail
    #            , UsersPhone
    #            , CDDOKPI_DigitalAdoption
        # )
    
    
    
    ) %>%

    mutate(ChannelShift_TransactionsFlag = ifelse(
        !is.na(CompletedTransactions) == TRUE & 
        !is.na(CompletedDigitalTransactions) == TRUE, 
        "Yes", "No")
    )  %>% 
    select(ServiceID
        , Service
        , URLGovUKStart
        , DepartmentParent
        , DepartmentChild
        , CSupport_TeamExists
        , CSupport_StatusExists
        , CSupport_ContactCount

        , PaperUse_LettersSendExist
        , PaperUse_LettersSendCount
        , PaperUse_LettersReceiveExist
        , PaperUse_LettersReceiveCount
        , PaperUse_SignatureExist
        , PaperUse_SignaturePercent

        , Auto_ManCheckExists
        , Auto_NoHuman
        , Auto_Judgement

        , Additional_IDCheckExists
        , Additional_TaxDisburse
        , Additional_FundingAward

        , ChannelShift_TransactionsFlag
        , CompletedDigitalTransactions
        , CompletedTransactions

        , Legacy_PlusTenYear
        , AutomatedTransactions
        , FTECount
        , NonStaffCost
        , UsersEmail
        , UsersPhone
        # , CDDOKPI_DigitalAdoption
    )

#### Create master final table with ALL fields present------------------
svc_sheets_overall_final <- cbind(
    svc_sheets_cntxt
    , svc_sheets_objctvs
    , svc_sheets_cddo
    , svc_sheets_servspec
    , svc_sheets_PP
    , svc_sheets_ssPP
    # , bespoke_CDDOKPI %>% 
    # select(
    # CDDOKPI_DigitalAdoption
    # , CDDOKPI_DigitalCompletion
    # , CDDOKPI_UserSatisfaction
    # , CDDOKPI_TransactionCost
    # , CDDOKPI_StaffTime
    # , CDDOKPI_FailureDemand
    # )
)

#### Create placeholder views for QA document---------------------------

### Create CDDO Pain Point QA version of table subject to logic (to avoid
# counting cells that are empty that are correctly left empty! e.g. Q1b - 
# if no go to Q2)

svc_sheets_PP_QA <- svc_sheets_PP %>% 
  mutate(CSupport_StatusExists = ifelse(CSupport_TeamExists == "Yes", CSupport_StatusExists, 1)
         , CSupport_ContactCount = ifelse(CSupport_TeamExists == "Yes", CSupport_ContactCount, 1)
         
         , PaperUse_LettersSendCount = ifelse(PaperUse_LettersSendExist == "Yes", PaperUse_LettersSendCount, 1)
         , PaperUse_LettersReceiveCount = ifelse(PaperUse_LettersReceiveExist == "Yes", PaperUse_LettersReceiveCount, 1)
         
         , PaperUse_SignaturePercent = ifelse(PaperUse_SignatureExist == "Yes", PaperUse_SignaturePercent, 1)
         
         , Auto_NoHuman = ifelse(Auto_ManCheckExists == "Yes", Auto_NoHuman, 1)
         , Auto_Judgement = ifelse(Auto_ManCheckExists == "Yes", Auto_Judgement, 1)
         
         , Additional_FundingAward = ifelse(Additional_TaxDisburse == "Yes", Additional_FundingAward, 1)
  )

### Overall section completeness across all services

overall_completeness <- as.data.frame(rbind(
  
  # Context 
  "Context" = round((section_nas(svc_sheets_cntxt %>% 
                select(-ServiceID
                       , -SourceFile
                       , -FileLink)
  )) * 100.0, 1)
  
   # Objectives
  , "Objectives" = round((section_nas(svc_sheets_objctvs)) * 100.0, 1)
  
  # CDDO KPI fields
  , "CDDO KPI Values" = round((section_nas(svc_sheets_cddo %>% 
                  select(-contains(c("AddInfo", "FreeText")))
                  )) * 100.0, 1)
  
  # CDDO Additional Info fields
  , "CDDO KPI Additional Info" = round((section_nas(svc_sheets_cddo %>% 
                               select(contains(c("AddInfo")))
                             )) * 100.0, 1)
  
  # CDDO Free Text
  , "CDDO KPI Free Text" = round((section_nas(svc_sheets_cddo %>% 
                               select(contains(c("FreeText")))
                             )) * 100.0, 1)
  
  # CDDO Pain Points
  , "CDDO Pain Points" = round((section_nas(svc_sheets_PP_QA %>% 
                               select(-contains(c("ImprovementsText"
                                                  , "ChallengesText")))
                             )) * 100.0, 1)
  
  # CDDO Improvements
  , "CDDO Pain Points - Improvement Text" = round((section_nas(svc_sheets_PP_QA %>% 
                               select(contains(c("ImprovementsText")))
                             )) * 100.0, 1)
  
  # CDDO Challenges
  , "CDDO Pain Points - Challenges Text" = round((section_nas(svc_sheets_PP_QA %>% 
                               select(contains(c("ChallengesText")))
                             )) * 100.0, 1)
  
  # Service Specific KPIs (first row only)
  , "Service-specific KPIs" = round((section_nas(svc_sheets_servspec %>% 
                               select(contains(c("KPI1_Name")))
                             )) * 100.0, 1)
  
  # Service Specific Pain points (first row only)
  , "Service-specific Pain Points" = round((section_nas(svc_sheets_ssPP %>% 
                               select(contains(c("Theme1_Name")))
  )) * 100.0, 1)
  
)
) %>% 
  rename("Proportion complete" = 1)



### Individual service section completion
services_colnames <- c("ServiceID", "Service", "Context", "Objectives"
                       , "CDDO KPI Values", "CDDO KPI Add. Info", "CDDO KPI Free Text", 
                       "CDDO PP Values", "CDDO PP Improv. Text", "CDDO PP Chall. Text",
                       "Service-specific KPIs Flag", "Service-specific PP Flag"
                       )
service_completeness <- data.frame(
    "ServiceID" = svc_sheets_cntxt$ServiceID
  , "Service" = svc_sheets_cntxt$Service
  , "Contextual Information" = round(row_nas(svc_sheets_cntxt %>% 
                                         select(-ServiceID, -SourceFile
                                                , -FileLink, -Service)) * 100.0, 1)
  , "Objectives" = round(row_nas(svc_sheets_objctvs) * 100.0, 1)
  , "CDDO KPI Values" = round(row_nas(svc_sheets_cddo %>% 
                                          select(-contains(c("AddInfo"
                                                             , "FreeText")))) * 100.0, 1)
  , "CDDO KPI Add. Info" = round(row_nas(svc_sheets_cddo %>% 
                                          select(contains(c("AddInfo")))) * 100.0, 1)
  , "CDDO KPI Free Text" = round(row_nas(svc_sheets_cddo %>% 
                                             select(contains(c("FreeText")))) * 100.0, 1)
  , "CDDO PP Values" = round(row_nas(svc_sheets_PP_QA %>% 
                                          select(-contains(c("ImprovementsText"
                                                             , "ChallengesText")))) * 100.0, 1)
  , "CDDO PP Improvements" = round(row_nas(svc_sheets_PP_QA %>% 
                                             select(contains(c("ImprovementsText")))) * 100.0, 1)
  , "CDDO PP Challenges" = round(row_nas(svc_sheets_PP_QA %>% 
                                               select(contains(c("ChallengesText")))) * 100.0, 1)
  
  , "Service-specific KPIs Flag" = ifelse(row_nas(svc_sheets_servspec %>% 
                                             select(contains(c("KPI1_Name")))) == 1, "Provided", 
                                          "Not Available")
  , "Service-specific PP Flag" = ifelse(row_nas(svc_sheets_ssPP %>% 
                                                    select(contains(c("Theme1_Name")))) == 1, "Provided", 
                                          "Not Available")
 )
colnames(service_completeness) = services_colnames

### Field completion across all services by section

## Context
cntxt_section <- fieldsection_maker(svc_sheets_cntxt, names = c("ServiceID", "SourceFile", "FileLink"))

## Objectives
objctvs_section <- fieldsection_maker(svc_sheets_objctvs)

## CDDO KPIs
cddo_section_KPIs <- fieldsection_maker(svc_sheets_cddo
                                        , names = c("AddInfo", "FreeText"))
cddo_section_AddInfo <- fieldsection_maker(svc_sheets_cddo
                                           , names = c("AddInfo"), remove = FALSE)
cddo_section_FreeText <- fieldsection_maker(svc_sheets_cddo
                                            , names = c("FreeText"), remove = FALSE)

## CDDO-specific Pain points
cddoPP_section <- fieldsection_maker(svc_sheets_PP_QA
                                     , names = c("ImprovementsText", "ChallengesText"))
cddoPP_section_ImprovementsText <- fieldsection_maker(svc_sheets_PP_QA
                                                      , names = c("ImprovementsText"), remove = FALSE)
cddoPP_section_ChallengesText <- fieldsection_maker(svc_sheets_PP_QA
                                                    , names = c("ChallengesText"), remove = FALSE)

## Service Specific KPIs
servspecKPI_section <- fieldsection_maker(svc_sheets_servspec)
rows = c("KPI1", "KPI2", "KPI3", "KPI4", "KPI5", "KPI6", "KPI7", "KPI8", "KPI9", "KPI10")
servspec_section <- data.frame(
  `Name` = numeric()
  , `Description` = numeric()
  , `Value` = numeric()
  , `AdditionalInfo` = numeric()
  , `FreeText` = numeric()
  , stringsAsFactors = FALSE
)

j = 1
for (i in 1:10){
  servspec_section[i, 1] = servspecKPI_section$`Proportion Complete`[j]
  servspec_section[i, 2] = servspecKPI_section$`Proportion Complete`[j+1]
  servspec_section[i, 3] = servspecKPI_section$`Proportion Complete`[j+2]
  servspec_section[i, 4] = servspecKPI_section$`Proportion Complete`[j+3]
  servspec_section[i, 5] = servspecKPI_section$`Proportion Complete`[j+4]

 j = j + 5
  
}
rownames(servspec_section) = rows

## Service Specific Pain points
servspecpains_section <- fieldsection_maker(svc_sheets_ssPP)
rows = c("PP1", "PP2", "PP3", "PP4", "PP5", "PP6", "PP7", "PP8", "PP9", "PP10")
servspecPP_section <- data.frame(
  `Theme` = numeric()
  , `Description` = numeric()
  , `CDDOSupport` = numeric()
  , stringsAsFactors = FALSE
)

j = 1
for (i in 1:10){
  servspecPP_section[i, 1] = servspecpains_section$`Proportion Complete`[j]
  servspecPP_section[i, 2] = servspecpains_section$`Proportion Complete`[j+1]
  servspecPP_section[i, 3] = servspecpains_section$`Proportion Complete`[j+2]
  
  j = j + 3
  
}
rownames(servspecPP_section) = rows

#### Save to a .rds file for tracking via RMarkdown---------------------
#### SAVE GLOBAL ENVIRONMENT TO LOAD TO RMARKDOWN ----
save(sheets_list
     
     # Overall completeness 
     , overall_completeness
     
     # By service completion
     , service_completeness
     
     # Field completion % by section tables
     , cntxt_section
     , objctvs_section
     , cddo_section_KPIs
     , cddo_section_AddInfo
     , cddo_section_FreeText
     , cddoPP_section
     , cddoPP_section_ImprovementsText 
     , cddoPP_section_ChallengesText
     , servspec_section
     , servspecPP_section
     
     
     , file = "RMarkdown/my_data.RData")





