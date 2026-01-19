# app.R
# Shiny app: build sentences -> dfm -> cosine similarity -> 3D vectors

library(shiny)
library(DT)
library(plotly)

WORDS <- c("big", "cat", "red")
BLANK <- "__BLANK__"
CHOICES <- c("(blank)" = BLANK, "big" = "big", "cat" = "cat", "red" = "red")

# ---- helpers ----
make_sentence <- function(tokens) {
  tokens <- tokens[tokens != BLANK]
  if (length(tokens) == 0) return(NA_character_)
  paste(tokens, collapse = " ")
}

dfm_from_sentences <- function(sentences, vocab = WORDS) {
  n <- length(sentences)
  X <- matrix(0L, nrow = n, ncol = length(vocab))
  colnames(X) <- vocab
  
  for (i in seq_len(n)) {
    toks <- unlist(strsplit(sentences[i], "\\s+"), use.names = FALSE)
    if (length(toks) == 0) next
    tab <- table(toks)
    for (w in vocab) {
      if (w %in% names(tab)) X[i, w] <- as.integer(tab[[w]])
    }
  }
  X
}

cosine_sim <- function(a, b) {
  na <- sqrt(sum(a^2))
  nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(NA_real_)
  sum(a * b) / (na * nb)
}

cosine_matrix <- function(X) {
  n <- nrow(X)
  S <- matrix(NA_real_, n, n)
  for (i in seq_len(n)) {
    for (j in seq_len(n)) {
      S[i, j] <- cosine_sim(X[i, ], X[j, ])
    }
  }
  rownames(S) <- rownames(X)
  colnames(S) <- rownames(X)
  S
}

# ---- UI ----
ui <- fluidPage(
  tags$head(tags$style(HTML("
    /* Center the bottom plot and make it a bit bigger */
    .plotly-centered {
      display: flex;
      justify-content: center;
      align-items: center;
    }
  "))),
  titlePanel("Build Sentences → DFM → Cosine Similarity → 3D Vectors"),
  p("Each row is a sentence with 4 slots. Choose big/cat/red or (blank)."),
  actionButton("go", "GO!", class = "btn-primary"),
  tags$hr(),
  
  tags$h4("Sentence builder"),
  fluidRow(
    column(2, tags$b("Sentence 1")),
    column(2, selectInput("s1w1", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s1w2", label = "", choices = CHOICES, selected = "big")),
    column(2, selectInput("s1w3", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s1w4", label = "", choices = CHOICES, selected = "cat"))
  ),
  fluidRow(
    column(2, tags$b("Sentence 2")),
    column(2, selectInput("s2w1", label = "", choices = CHOICES, selected = "red")),
    column(2, selectInput("s2w2", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s2w3", label = "", choices = CHOICES, selected = "cat")),
    column(2, selectInput("s2w4", label = "", choices = CHOICES, selected = "cat"))
  ),
  fluidRow(
    column(2, tags$b("Sentence 3")),
    column(2, selectInput("s3w1", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s3w2", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s3w3", label = "", choices = CHOICES, selected = "big")),
    column(2, selectInput("s3w4", label = "", choices = CHOICES, selected = "red"))
  ),
  fluidRow(
    column(2, tags$b("Sentence 4")),
    column(2, selectInput("s4w1", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s4w2", label = "", choices = CHOICES, selected = "red")),
    column(2, selectInput("s4w3", label = "", choices = CHOICES, selected = BLANK)),
    column(2, selectInput("s4w4", label = "", choices = CHOICES, selected = "big"))
  ),
  
  tags$hr(),
  
  fluidRow(
    column(
      6,
      tags$h4("Sentences used"),
      verbatimTextOutput("sentences_used"),
      tags$h4("Document-feature matrix (dfm)"),
      DTOutput("dfm_table")
    ),
    column(
      6,
      tags$h4("Cosine similarity matrix"),
      DTOutput("cos_table")
    )
  ),
  
  tags$hr(),
  
  tags$h4("3D vectors (big, cat, red)", style = "text-align:center;"),
  div(class = "plotly-centered",
      plotlyOutput("vec3d", height = "560px", width = "75%")
  )
)

# ---- Server ----
server <- function(input, output, session) {
  
  computed <- eventReactive(input$go, {
    rows <- list(
      c(input$s1w1, input$s1w2, input$s1w3, input$s1w4),
      c(input$s2w1, input$s2w2, input$s2w3, input$s2w4),
      c(input$s3w1, input$s3w2, input$s3w3, input$s3w4),
      c(input$s4w1, input$s4w2, input$s4w3, input$s4w4)
    )
    
    sentences <- vapply(rows, make_sentence, FUN.VALUE = character(1))
    keep <- !is.na(sentences)
    kept_ids <- which(keep)
    sentences_kept <- sentences[keep]
    
    if (length(sentences_kept) == 0) {
      X <- matrix(0L, nrow = 0, ncol = length(WORDS))
      colnames(X) <- WORDS
      return(list(sentences = character(0), X = X, S = matrix(numeric(0), 0, 0), kept_ids = integer(0)))
    }
    
    X <- dfm_from_sentences(sentences_kept, vocab = WORDS)
    rownames(X) <- paste0("Sentence ", kept_ids)
    
    S <- cosine_matrix(X)
    
    list(sentences = sentences_kept, X = X, S = S, kept_ids = kept_ids)
  }, ignoreInit = TRUE)
  
  output$sentences_used <- renderPrint({
    res <- computed()
    if (is.null(res)) {
      cat("Click GO! to compute outputs.")
    } else if (length(res$sentences) == 0) {
      cat("No sentences selected (all blank).")
    } else {
      for (i in seq_along(res$sentences)) {
        cat(sprintf("Sentence %d: %s\n", res$kept_ids[i], res$sentences[i]))
      }
    }
  })
  
  output$dfm_table <- renderDT({
    res <- computed()
    if (is.null(res)) {
      return(datatable(data.frame(Message = "Click GO! to compute outputs."), options = list(dom = "t"), rownames = FALSE))
    }
    X <- res$X
    if (nrow(X) == 0) {
      return(datatable(data.frame(Message = "No sentences to display (all blank)."), options = list(dom = "t"), rownames = FALSE))
    }
    datatable(as.data.frame(X), options = list(dom = "t", paging = FALSE), rownames = TRUE)
  })
  
  output$cos_table <- renderDT({
    res <- computed()
    if (is.null(res)) {
      return(datatable(data.frame(Message = "Click GO! to compute outputs."), options = list(dom = "t"), rownames = FALSE))
    }
    S <- res$S
    if (nrow(S) == 0) {
      return(datatable(
        data.frame(Message = "No cosine matrix (need at least 1 non-empty sentence)."),
        options = list(dom = "t"),
        rownames = FALSE
      ))
    }
    datatable(round(as.data.frame(S), 3), options = list(dom = "t", paging = FALSE), rownames = TRUE)
  })
  
  output$vec3d <- renderPlotly({
    res <- computed()
    if (is.null(res)) {
      return(plotly_empty(type = "scatter3d") %>% layout(title = "Click GO! to compute outputs."))
    }
    X <- res$X
    if (nrow(X) == 0) {
      return(plotly_empty(type = "scatter3d") %>% layout(title = "Nothing to plot (all blank)."))
    }
    
    df <- as.data.frame(X)
    df$label <- rownames(X)
    
    plot_ly(
      data = df,
      x = ~big, y = ~cat, z = ~red,
      type = "scatter3d",
      mode = "markers+text",
      text = ~label,
      textposition = "top center",
      marker = list(size = 7)
    ) %>%
      layout(
        margin = list(l = 0, r = 0, b = 0, t = 0),
        scene = list(
          xaxis = list(title = "big (count)"),
          yaxis = list(title = "cat (count)"),
          zaxis = list(title = "red (count)")
        )
      )
  })
}

shinyApp(ui, server)
