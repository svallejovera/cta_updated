# app.R
# Single-file Shiny app to build intuition for K-means clustering (step-by-step)

library(shiny)
library(shinyjs)

# --- helpers ---------------------------------------------------------------

make_clustered_data <- function(n = 260, blobs = 4, seed = NULL,
                                spread_min = 1.4, spread_max = 2.6,
                                noise_prop = 0.18) {
  if (!is.null(seed)) set.seed(seed)
  
  # random blob centers (keep some separation, but not too extreme)
  centers <- data.frame(
    cx = runif(blobs, -5.5, 5.5),
    cy = runif(blobs, -5.5, 5.5),
    s  = runif(blobs, spread_min, spread_max)  # wider blobs -> harder K-means
  )
  
  # mixture: most points from blobs, some uniform noise
  n_noise <- round(n * noise_prop)
  n_blob  <- n - n_noise
  
  blob_id <- sample(seq_len(blobs), size = n_blob, replace = TRUE)
  
  x_blob <- rnorm(n_blob, mean = centers$cx[blob_id], sd = centers$s[blob_id])
  y_blob <- rnorm(n_blob, mean = centers$cy[blob_id], sd = centers$s[blob_id])
  
  # background noise points
  x_noise <- runif(n_noise, -8, 8)
  y_noise <- runif(n_noise, -8, 8)
  
  data.frame(
    x = c(x_blob, x_noise),
    y = c(y_blob, y_noise)
  )
}


assign_to_centroids <- function(dat, centroids) {
  # returns integer vector of cluster assignment (1..K)
  K <- nrow(centroids)
  # distance squared to each centroid
  d2 <- sapply(seq_len(K), function(k) {
    (dat$x - centroids$x[k])^2 + (dat$y - centroids$y[k])^2
  })
  max.col(-d2) # argmin
}

compute_wss <- function(dat, centroids, cl) {
  # within-cluster sum of squares (SSE)
  sum((dat$x - centroids$x[cl])^2 + (dat$y - centroids$y[cl])^2)
}

update_centroids <- function(dat, cl, K) {
  # recompute centroids as means; handle empty clusters by re-seeding
  centroids <- data.frame(x = numeric(K), y = numeric(K))
  for (k in seq_len(K)) {
    idx <- which(cl == k)
    if (length(idx) == 0) {
      # empty cluster: re-seed to a random point
      j <- sample(seq_len(nrow(dat)), 1)
      centroids$x[k] <- dat$x[j]
      centroids$y[k] <- dat$y[j]
    } else {
      centroids$x[k] <- mean(dat$x[idx])
      centroids$y[k] <- mean(dat$y[idx])
    }
  }
  centroids
}

# --- app -------------------------------------------------------------------

ui <- fluidPage(
  useShinyjs(),
  titlePanel("K-means, step by step (intuition builder)"),
  
  fluidRow(
    column(
      4,
      wellPanel(
        h4("Controls"),
        actionButton("gen", "1) Generate clustered observations", class = "btn-primary"),
        br(), br(),
        sliderInput("K", "Choose number of clusters (K):", min = 3, max = 5, value = 3, step = 1),
        br(),
        actionButton("step", "2) Run / Step K-means", class = "btn-success"),
        tags$div(style="margin-top:8px;",
                 "First click: random centroids appear + points assigned. ",
                 "Each next click: loss computed, centroids updated, points reassigned."
        ),
        br(), br(),
        actionButton("reset", "Reset (keep points, restart K-means)"),
        tags$hr(),
        h4("Status"),
        verbatimTextOutput("status", placeholder = TRUE),
        tags$hr(),
        h4("K-means summary"),
        tags$ol(
          tags$li("Specify K (chosen by the analyst)."),
          tags$li("Randomly select K observations as initial centroids."),
          tags$li("Assign each observation to its nearest centroid (Euclidean distance)."),
          tags$li("Update each centroid as the mean of points in that cluster."),
          tags$li("Repeat steps 3–4 until assignments stop changing (convergence).")
        )
      )
    ),
    column(
      8,
      plotOutput("plane", height = "650px"),
      tags$div(
        style="margin-top:6px; font-size: 0.95em;",
        tags$strong("Tip: "),
        "Try different K (3–5). Regenerate points to see when K-means succeeds or struggles."
      )
    )
  )
)

server <- function(input, output, session) {
  
  rv <- reactiveValues(
    dat = NULL,
    K = NULL,
    centroids = NULL,
    cl = NULL,
    iter = 0L,
    wss = NA_real_,
    converged = FALSE
  )
  
  # Initialize: generate data on startup
  observe({
    rv$dat <- make_clustered_data(n = 260, blobs = 4, noise_prop = 0.18)
    rv$K <- input$K
    rv$centroids <- NULL
    rv$cl <- NULL
    rv$iter <- 0L
    rv$wss <- NA_real_
    rv$converged <- FALSE
    enable("step")
  })
  
  # Generate new clustered observations
  observeEvent(input$gen, {
    rv$dat <- make_clustered_data(n = 260, blobs = 4, noise_prop = 0.18)
    rv$K <- input$K
    rv$centroids <- NULL
    rv$cl <- NULL
    rv$iter <- 0L
    rv$wss <- NA_real_
    rv$converged <- FALSE
    enable("step")
  })
  
  # Reset K-means but keep the same points
  observeEvent(input$reset, {
    rv$K <- input$K
    rv$centroids <- NULL
    rv$cl <- NULL
    rv$iter <- 0L
    rv$wss <- NA_real_
    rv$converged <- FALSE
    enable("step")
  })
  
  # If user changes K mid-run, treat it like a reset (keep points)
  observeEvent(input$K, {
    rv$K <- input$K
    rv$centroids <- NULL
    rv$cl <- NULL
    rv$iter <- 0L
    rv$wss <- NA_real_
    rv$converged <- FALSE
    enable("step")
  }, ignoreInit = TRUE)
  
  # Step button: initialize then iterate until convergence
  observeEvent(input$step, {
    req(rv$dat)
    if (rv$converged) return()
    
    K <- input$K
    n <- nrow(rv$dat)
    
    # First click: initialize centroids and assign points
    if (is.null(rv$centroids)) {
      idx <- sample(seq_len(n), K)
      rv$centroids <- data.frame(x = rv$dat$x[idx], y = rv$dat$y[idx])
      rv$cl <- assign_to_centroids(rv$dat, rv$centroids)
      rv$wss <- compute_wss(rv$dat, rv$centroids, rv$cl)
      rv$iter <- 1L
      return()
    }
    
    # Subsequent clicks: update centroids -> reassign -> compute loss -> check convergence
    old_cl <- rv$cl
    
    rv$centroids <- update_centroids(rv$dat, rv$cl, K)
    rv$cl <- assign_to_centroids(rv$dat, rv$centroids)
    rv$wss <- compute_wss(rv$dat, rv$centroids, rv$cl)
    rv$iter <- rv$iter + 1L
    
    if (identical(old_cl, rv$cl)) {
      rv$converged <- TRUE
      disable("step")
    }
  })
  
  output$status <- renderText({
    if (is.null(rv$dat)) return("No data yet.")
    K <- input$K
    
    lines <- c(
      sprintf("K (clusters chosen): %d", K),
      sprintf("Iteration: %d", rv$iter)
    )
    
    if (!is.null(rv$centroids)) {
      lines <- c(lines, sprintf("Within-cluster SSE (loss): %.3f", rv$wss))
    } else {
      lines <- c(lines, "Click “Run / Step K-means” to initialize random centroids.")
    }
    
    if (rv$converged) {
      lines <- c(lines, "", "✅ Converged: assignments stopped changing.", "Step button disabled. Regenerate points or change K to restart.")
    } else if (!is.null(rv$centroids)) {
      lines <- c(lines, "", "Not yet converged. Click again to update centroids and reassign points.")
    }
    
    paste(lines, collapse = "\n")
  })
  
  output$plane <- renderPlot({
    req(rv$dat)
    
    dat <- rv$dat
    K <- input$K
    
    # plot ranges with padding
    xr <- range(dat$x)
    yr <- range(dat$y)
    pad_x <- diff(xr) * 0.08
    pad_y <- diff(yr) * 0.08
    if (pad_x == 0) pad_x <- 1
    if (pad_y == 0) pad_y <- 1
    
    plot(
      NA, xlim = c(xr[1] - pad_x, xr[2] + pad_x),
      ylim = c(yr[1] - pad_y, yr[2] + pad_y),
      xlab = "x", ylab = "y",
      main = "Observations, cluster assignments, and centroids"
    )
    abline(h = 0, v = 0, lty = 3, col = "gray70")
    
    # before K-means starts
    if (is.null(rv$centroids) || is.null(rv$cl)) {
      points(dat$x, dat$y, pch = 16, cex = 0.8, col = "gray30")
      mtext("Generate points, choose K, then click “Run / Step K-means”.", side = 3, line = 0.5, cex = 0.9)
      return()
    }
    
    cols <- grDevices::hcl.colors(K, "Dark 3")
    points(dat$x, dat$y, pch = 16, cex = 0.85, col = cols[rv$cl])
    
    # centroids
    points(rv$centroids$x, rv$centroids$y, pch = 8, cex = 1.8, lwd = 2, col = cols)
    
    # label centroids
    text(rv$centroids$x, rv$centroids$y, labels = paste0("C", seq_len(K)),
         pos = 3, cex = 0.9, col = cols)
    
    # convergence banner
    if (rv$converged) {
      usr <- par("usr")
      rect(usr[1], usr[4] - 0.12*(usr[4]-usr[3]), usr[2], usr[4],
           col = rgb(0, 0, 0, 0.07), border = NA)
      text(mean(usr[1:2]), usr[4] - 0.06*(usr[4]-usr[3]),
           "CONVERGED ✅  (Change K or regenerate points to restart)",
           cex = 1.1, font = 2)
    }
  })
}

shinyApp(ui, server)
