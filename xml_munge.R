# FILE: xml_munge.R
# DESC: munges through NSF XML data and outputs one data table per year
# USAGE: download XML files from https://www.nsf.gov/awardsearch/download.jsp and place in HOME_DIR/AWARD_PATH/ with one folder per year in YEARS; the output is one .Rds file per year, each containing a data table for all awards granted in that year

library(XML)
library(plyr)
library(data.table)

HOME_DIR = "/Users/stevenkim/R-files/nsfads/"
AWARD_PATH <- "nsf_grants/"
YEARS = 1990:2015

clean_abs <- function(chars) {
  chars <- gsub("<br/>", " ", chars)
  chars <- gsub("- ", " ", chars)
  chars <- gsub(" -", " ", chars)
  chars <- gsub("--", " ", chars)
  chars <- gsub("`", "", chars)
}

parse_xml <- function(FileName) {
  doc <- xmlParse(FileName)
  list(xmlValue(doc[["//AwardID"]]),
       xmlValue(doc[["//AwardTitle"]]),
       clean_abs(xmlValue(doc[["//AbstractNarration"]])), 
       doc[["number(//AwardAmount)"]], 
       format(as.Date(xmlValue(doc[["//AwardEffectiveDate"]]), "%m/%d/%Y"), "%Y"),
       xmlValue(doc[["//Organization/Division/LongName"]]))
}

colnames <- c("ID", "Title", "Abstract", "Amount", "Year", "Division")

for (year in YEARS) { 
  
  setwd(paste(HOME_DIR, AWARD_PATH, year,sep="")) 
  files <- list.files(pattern="*.xml") 
  
  l <- lapply(files, function(x) { 
    if(!file.size(x) == 0) {
      parse_xml(x)
    }
  })
  
  dt <- rbindlist( l )
  names(dt) <- colnames
  
  saveRDS(dt,file=paste(HOME_DIR, "data_tables/awards", year, ".rds", sep=""))
  
}

