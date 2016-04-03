# FILE: gen_tdm.R
# DESC: for a given vector of divisions of interest, outputs a TermDocumentMatrix where columns are years and rows are N-Grams for N=1,2,3
# USAGE: set DIVS to be a vector of all divisions of interest; the outputs are: an .Rds file containing a vector of "corpora" (one for each division), and an .Rds file containing a vector of "tdm" (one for each division)
 
library("RWeka")
library("tm")
library("data.table")

HOME_DIR = "/Users/stevenkim/R-files/nsfads/"
AWARD_PATH <- "nsf_grants/"
DIVS <- c("Division Of Mathematical Sciences")
# DIVS <- c("Division Of Mathematical Sciences", "Div Of Civil, Mechanical, & Manufact Inn", "Division of Computing and Communication Foundations",  "Division Of Computer and Network Systems")
YEARS = 1990:2015

dt <- list()
for (i in 1:length(YEARS)) {
  dt[[i]] <- readRDS(paste(HOME_DIR, "data_tables/awards", YEARS[i], ".rds", sep=""))
}
bigdt = rbindlist(dt)

award.corpus <- list()
for (div in DIVS) {
  corpora <- list()
  for (j in 1:length(YEARS)) {
    subdt = bigdt[which( (bigdt$Division == div) & (bigdt$Year == YEARS[[j]]))]
    corpora[[j]] <- paste(subdt$Abstract, subdt$Title, collapse=' ')
  }
  award.corpus[[div]] <- Corpus(VectorSource(corpora))
}
saveRDS(award.corpus,paste(HOME_DIR,"award_corpus.rds", sep=''))

ptm <- proc.time()
options(mc.cores=1)   # sets 1 thread; seems to prevent NGramTokenizer() error 
TriTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 3))
tdm <- list()
for (div in DIVS) {
  tdm[[ div ]] <- TermDocumentMatrix(award.corpus[[ div ]], control = list(tokenize = TriTokenizer, removePunctuation = TRUE))
}
saveRDS(tdm, paste(HOME_DIR,"tdm.rds",sep=''))
proc.time() - ptm 