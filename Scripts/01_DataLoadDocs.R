######################################
# 01_DataLoadDocs.R
######################################

# This script is designed to read the google docs associated with the 
# baseline commission template and create a set of tables after iterating
# across all files provided.

#### OBSOLETE, IGNORE!!!!!!!!!!!

# Create list of files to iterate over
doclist <- drive_ls(path = URL, type = "document")

#### Review local file counts-------------------------------------------
file_count <- length(list.files(path = DocsLocal ,pattern="*.docx",ignore.case = TRUE))
file_list <- list.files(path = DocsLocal, pattern="*.docx",ignore.case = TRUE )

## Prep for loop(s)
doc.list <- vector(mode = "list", length = 0)
list_names <- c(LETTERS)

## Loop over all files within the folder and pull out service names
for (i in 1:length(file_list)){

data <- docx_summary(read_docx(paste0(DocsLocal, file_list[i])))  %>% 
filter(content_type == "table cell" & doc_index == 63 & row_id == 1 & cell_id == 3)  %>% 
select(text)

## Append new list onto placeholder.list
doc.list <- append(doc.list, data)  
}

#### Set up loop and data tables for reading into-----------------------
svc_context_tbl <- data.frame(
    Service = character()
    , Owner = character()
    , URLService = character()
    , URLGovuk = character()
    , routes = character()
    , DepartmentParent = character()
    , DepartmentChild = character()
)


for (j in 1:length(doc.list)){

## To figure out what region we're dealing with in loop if it breaks!
print(paste0("Loop on service: ", doc.list[j]))
print(paste0("File name:", DocsLocal, "/", 
                 file_list[j]))
print("-----------------------")

## Create overall summary to read from
summary <- docx_summary(read_docx(paste0(DocsLocal, file_list[1])))

## Pull out service context table
svc_context <- as.data.frame(
    transpose(summary %>% 
    filter(content_type == "table cell" & doc_index == 63 & cell_id == 3)  %>% 
    select("Value" = text)
    )) %>% 
select(
    `Service` = "V1"
    , `Owner` = "V2"
    , `URLService` = "V3"
    , `URLGovuk` = "V4"
    , `RoutesOther` = "V5"
    , `DepartmentParent` = "V6"
    , `DepartmentChild` = "V7"
 )
svc_context_tbl <- rbind(svc_context_tbl, svc_context)

## Pull out Service Scope & Objectives
}
