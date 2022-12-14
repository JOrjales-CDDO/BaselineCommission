######################################
# 01_DataCollate.R
######################################

# This script is designed to collate the tables together from reading 
# in google sheets and do cleaning on them before they are linked 
# together.

#### Set some variable values-------------------------------------------
AVGFTECost = 27000
WkHrsYr = 2080 # 40 hours per week as an average for now.

#### Cleaning and Transformation----------------------------------------

### Cleaning------------------------------------------------------------

### Context Table
svc_sheets_cntxt <- svc_sheets_cntxt %>% 
    mutate(
        URLGovUK = str_replace(URLGovUK, "https://www.gov.uk", "")
    )

### Objectives table

### CDDO KPIs - most are just expected raw numbers
svc_sheets_cddo <- svc_sheets_cddo %>% 
    mutate(
        
        # Non Staff Costs
        NonStaffCost = as.numeric(ifelse(str_detect(NonStaffCost, "£") == TRUE
            , gsub("£", "", NonStaffCost), NonStaffCost)
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

    ## Customer Support section
    mutate(
        CSupport_ImprovementsText = str_replace_all(CSupport_ImprovementsText, 
        fixed(c(
            "Please specifiy any steps being taken to reduce burden on customer support teams, 
            and the impacts this will have on the running costs of the service" = ""
            , "Please specify any steps being taken to reduce burden on customer support teams, 
            and the impacts this will have on the running costs of the service" = ""
        )))
        , CSupport_ChallengesText = str_replace(CSupport_ChallengesText, 
        "E.g. why automated updates might not work, or have low impact in reducing burden to customer support teams"
        , ""
        )
    
    ## Paper Use Section
        , PaperUse_ImprovementsText = str_replace_all(PaperUse_ImprovementsText, 
        fixed(c(
            "Please specifiy any steps being taken to reduce use of paper when 
            conducting transactions with users in your service, and the impacts 
            this will have on the running costs of the service" = ""
            , "Please specify any steps being taken to reduce use of paper when 
            conducting transactions with users in your service, and the impacts 
            this will have on the running costs of the service" = ""
        )))
        , PaperUse_ChallengesText = str_replace(PaperUse_ChallengesText, 
        "E.g. specific requriements or challenges that the service has which 
        prevent substituion of paper documents for digital alternatives, 
        particularly where this is associated with large cohorts of users."
        , ""
        )

    ## Auto
        , Auto_ImprovementsText = str_replace(Auto_ImprovementsText, 
        "Please specify any steps being taken to increase automated processing 
        in your service, and the impacts this will have on the running costs of the service"
        , ""
        )
        , Auto_ChallengesText = str_replace(Auto_ChallengesText, 
        "What circumstances or challenges does your service have which would 
        prevent straight through processing in some (or all) cases? "
        , ""
        )
    
    ## Legacy
        , Legacy_ImprovementsText = str_replace(Legacy_ImprovementsText, 
        "Please specify any plans to remove or reduce the service's dependency on 
        legacy IT. What impacts could this have on the running costs of the service?"
        , ""
        )
        , Legacy_ChallengesText = str_replace(Legacy_ChallengesText, 
        "What challenges does your service have to overcoming legacy IT dependence?"
        , ""
        )

    ## Performance Monitoring
        , PMonitoring_ImprovementsText = str_replace(PMonitoring_ImprovementsText, 
        "Please specify any plans to introduce or extend these features."
        , ""
        )
        , PMonitoring_ChallengesText = str_replace(PMonitoring_ChallengesText, 
        "What circumstances or challenges does your service have which makes these difficult to implement or run?"
        , ""
        )

    ## Usability
        , Usability_CompliantImprovementsText = str_replace(Usability_CompliantImprovementsText, 
        "If not fully compliant what are the plans to achieve compliance."
        , ""
        )
        #, Usability_CompliantChallengesText = str_replace(Usability_CompliantChallengesText, 
        #""
        #, ""
        #)
        , Usability_ComplexImprovementsText = str_replace(Usability_ComplexImprovementsText, 
        "If yes, please specify any plans to lighten the complexity for users or staff"
        , ""
        )
        , Usability_ComplexChallengesText = str_replace(Usability_ComplexChallengesText, 
        "What circumstances, requirements or challenges does your service have which makes complex eligibility difficult to simplify?"
        , ""
        )

    )

#### Create tables------------------------------------------------------

### Context and Objectives
svc_sheets_cntxtobjectvs  <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUK
        )
    , svc_sheets_objctvs
)

### Context and CDDO KPIs
svc_sheets_cntxtcddo <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUK
        )
    , svc_sheets_cddo
)

### Context and Service Specific KPIs
svc_sheets_cntxtservspec  <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUK
        )
    , svc_sheets_servspec
)

### Context and Pain Points
svc_sheets_cntxtPP  <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLGovUK
        )
    , svc_sheets_PP
)

### Context and Service Specific Pain Points
svc_sheets_cntxtssPP <- cbind(
    svc_sheets_cntxt %>% 
        select(ServiceID
        , Service
        , URLService
        , URLGovUK
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
    , CDDOKPI_DigitalAdoption
    , CDDOKPI_DigitalCompletion
    , CDDOKPI_UserSatisfaction
    , Complaints
    , UsersJourneyTimeHours
    , CDDOKPI_TransactionCost
    , CDDOKPI_StaffTime
    , AutomatedTransactions
    , CDDOKPI_FailureDemand
    )

bespoke_CDDOKPI <- cbind(svc_sheets_cntxt %>%
    select(ServiceID
        , Service
        , URLGovUK
        , DepartmentParent
        , DepartmentChild
    )
    , svc_sheets_KPIcalcs)


### Opportunity Analysis
bespoke_OppA <- cbind(svc_sheets_cntxt
    , svc_sheets_PP
    , svc_sheets_cddo) %>%

    mutate(ChannelShift_TransactionsFlag = ifelse(
        !is.na(CompletedTransactions) == TRUE & 
        !is.na(CompletedDigitalTransactions) == TRUE, 
        "Yes", "No")
    )  %>% 
    select(ServiceID
        , Service
        , URLGovUK
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
    )

#### Create master final table with ALL fields present------------------
svc_sheets_overall_final <- cbind(
    svc_sheets_cntxt
    , svc_sheets_objctvs
    , svc_sheets_cddo
    , svc_sheets_servspec
    , svc_sheets_PP
    , svc_sheets_ssPP
    , bespoke_CDDOKPI %>% 
    select(
    CDDOKPI_DigitalAdoption
    , CDDOKPI_DigitalCompletion
    , CDDOKPI_UserSatisfaction
    , CDDOKPI_TransactionCost
    , CDDOKPI_StaffTime
    , CDDOKPI_FailureDemand
    )
)

#### Create placeholder views for QA document---------------------------
### Percentage complete per section
complete_cntxt <- as.data.frame(colMeans(is.na(svc_sheets_cntxt %>% 
select(-ServiceID
    , -SourceFile
    , -FileLink)
    ))) %>% 
select(`Proportion Response` = 1) * 100.0
#### Save to a .rds file for tracking via RMarkdown---------------------

save(sheets_list, complete_cntxt, file = "my_data.RData")





