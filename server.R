# FILE: server.R
# DESC: server file for Shiny app

library("data.table")
library("RWeka")
library("tm")
library("ggplot2")
library("stringr")

YEARS <- 1990:2015
grant_counts <- readRDS("/Users/stevenkim/R-files/nsfads/grant_counts.rds")
names(grant_counts) <- c("year", "grams")
tdm_sparse <- readRDS("/Users/stevenkim/R-files/nsfads/tdm_sparse.rds")

make_plot <- function(q, tdm_s) {
  # parse through ',' and '+' operators
  queries <- strsplit(q, ',\\s*')[[1]]
  dfs <- vector("list", length(queries))
  for (i in 1:length(queries)) {
    combs <- strsplit(queries[i], '\\s*\\+\\s*')[[1]]
    for (j in 1:length(combs)) {
      combs[[j]] <- str_trim(combs[[j]], side="both")
    }
    freqs <- inspect(tdm_s[combs,])
    freqDF <- data.frame(rep(queries[i], length(YEARS)), YEARS, colSums(freqs))
    rownames(freqDF) <- NULL
    names(freqDF) <- c("terms", "year", "occurrences")
    dfs[[i]] <- freqDF
  }
  
  # merge data frames from all terms
  bigdf <- Reduce(function(...) merge(...,all=T), dfs)
  bigdf <- merge(bigdf, grant_counts, id.vars= , by ="year")
  plot_table <- transform(bigdf, freq = occurrences / grams * 100)
  
  # make the plot
  queryplot <- ggplot(data=plot_table, aes(x=year, y=freq, group=terms)) + geom_line(aes(colour=terms, group=terms)) +  geom_point(aes(colour=terms, group=terms)) + ylim(0,1.5*max(plot_table$freq)) + ggtitle("NSF DMS funding trends @ mathtrends.ssk.im") + ylab("occurrences per 100 N-Grams")
  return(queryplot)
}

# check for validity of the query
check_query <- function(q,tdm_s) {
  queries <- strsplit(q, ',\\s*')[[1]]
  for (i in 1:length(queries)) { 
    splits <- strsplit(queries[[i]], '\\s*\\+\\s*')[[1]]
    for (j in 1:length(splits)) { 
      if (sapply(gregexpr("[[:alpha:]]+", splits[[j]]), function(x) sum(x > 0)) > 3) {
        return("Please limit to N-Grams of length N <= 3.")
      }
      splits[[j]] <- str_trim(splits[[j]], side="both")
      if (length(try(tdm_s[splits[[j]],], silent=TRUE)) == 1) {
        return(paste("No occurrences of '", splits[[j]], "'", sep=''))
      }
    }
  }
  return(NULL)
}


shinyServer(
  function(input, output) {
    v <- reactiveValues(data = NULL)
    
    # search button
    observeEvent(input$search, {
      v$query <- tolower(input$query)
      v$query <- gsub("\\s+"," ", v$query)
      v$query <- gsub("^\\s+|\\s+$", "", v$query)
    })
    
    # plot rendering
    output$history <- renderPlot({
      if (is.null(v$query)) return()
      validate( need(v$query != "", "Please enter a query.") )
      validate( check_query(v$query, tdm_sparse) )
      
      queryplot <- make_plot(v$query, tdm_sparse)
      return(queryplot)
    })
    
    # download plot
    output$dl <- downloadHandler(
      filename = function() { paste(v$query, '.png', sep='') },
      content = function(file) {
        queryplot <- make_plot(v$query, tdm_sparse)
        ggsave(file, plot = queryplot, device = "png")
      }
    )
  }
)