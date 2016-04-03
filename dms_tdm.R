# FILE: dms_tdm.R
# DESC: cleans up and sparsifies the big NSF TermDocumentMatrix for Division of Mathematical Sciences only
# USAGE: given the tdm.rds read from gen_tdm.R, this file looks only at the first division and sparsifies it (only looks at terms appearing in abstracts from at least 20% of the years)

YEARS <- 1990:2015
div <- 1

tdm <- readRDS("/Users/stevenkim/R-files/nsfads/tdm.rds")
grant_counts <- data.frame(YEARS, apply(tdm[[div]], 2, sum))
tdm_sparse <- removeSparseTerms(tdm[[ div ]], 0.2)

saveRDS(grant_counts, "/Users/stevenkim/R-files/nsfads/grant_counts.rds")
saveRDS(tdm_sparse, "/Users/stevenkim/R-files/nsfads/tdm_sparse.rds")