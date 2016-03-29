# xml_munge.R
# rolls through NSF XML data and pumps out one data table per year

library(XML)
library(plyr)
library(data.table)

# ptm <- proc.time()
# proc.time() - ptm         # 10 minutes for 10 years

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

