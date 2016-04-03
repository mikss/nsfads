# FILE: ui.R
# DESC: user interface file for Shiny app

shinyUI(fluidPage(
  titlePanel("nsfads: funding fads in NSF Division of Mathematical Sciences"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("query", label = h3("N-Gram input"), value = ""),
      actionButton("search", label = "Search"),
      helpText("Use ',' to separate queries, and '+' to combine queries. E.g., querying 'a, b' will search for both 'a' and 'b'; querying 'a + b' will combine occurrences of 'a' and 'b'. All excess whitespace is stripped, and queries are case-insensitive. "),
      helpText(   a("About",     href="https://github.com/mikss/nsfads/blob/master/README.md", target="_blank")
      )
    ),
    
    mainPanel(
      plotOutput("history"),
      downloadLink("dl", label = "Download Plot")
    )
  )
))