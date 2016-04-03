# nsfads

## Introduction

This repository contains [R](https://www.r-project.org) code to munge, analyze, and publish (as a [Shiny](http://shiny.rstudio.com) web app) summaries of word counts in National Science Foundation (NSF) grant abstracts from the Division of Mathematical Sciences (DMS). See  [mathtrends.ssk.im](http://mathtrends.ssk.im) for an example.

The relevant files are:
   xml_munge.R
   gen_tdm.R
   tdm_dms.R
   ui.R
   server.R

For any questions, bug reports, etc., contact [Steven S. Kim](http://ssk.im) via e-mail at [steven_kim@brown.edu](mailto:steven_kim@brown.edu).

## Requirements

Required R packages include:
   XML
   plyr
   data.table
   tm
   RWeka
   ggplot2
   stringr

The XML files containing abstract data were downloaded from the [NSF website](https://www.nsf.gov/awardsearch/download.jsp).

## Project Notes

* Default constants look through years 1990 -- 2015, but this was an arbitrary choice, and easily changed by updating the YEARS constant in the code. However, many XML files from earlier years do not contain abstract data.
* Key functionality is provided by the `tm` text-mining package in R.
* The file `tdm_dms.R` sparsifies the TermDocumentMatrix to only include terms which occur in at least 20% of the years analyzed.
* This project was heavily influenced by the [Google Ngram viewer](https://books.google.com/ngrams)
* A few example terms with interesting trends:
   - `machine learning` and `data` vs. `statistics + statistical`
   - `biology + biological`
   - `underrepresented, minority + minorities`
   - `outreach`
   - `young researchers` and `undergraduate, graduate`
   - `develop, advance + advances`
   - `the project will`
   - `network + networks`
   - `control, partial differential`
* Some eventual TODOs:
   - smoothing the time series
   - a "shuffle" option incorporating list of sample queries
   - look at all divisions and make comparisons across NSF
   - compare to NIH/DOD/NSERC funding priorities
   - use a Markov model to generate a "sample" abstract
   - map [textual differences across corpora](http://blog.rolffredheim.com/2013/02/mapping-significant-textual-differences.html)
   - a "dollar-weighted" count (weighting gram proportion in a given grant by dollars in grant)
