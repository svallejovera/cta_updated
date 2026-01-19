# app.R
# Single-file Shiny app to build intuition for cosine similarity

library(shiny)

# --- helpers ---
deg2rad <- function(deg) deg * pi / 180

cosine_sim <- function(a, b) {
  na <- sqrt(sum(a^2))
  nb <- sqrt(sum(b^2))
  if (na == 0 || nb == 0) return(NA_real_)
  sum(a * b) / (na * nb)
}

rand_len <- function() sample(1:5, 1)
rand_angle <- function() sample(0:359, 1)

rand_coord_pair <- function() {
  # avoid both zero
  x <- sample(-5:5, 1)
  y <- sample(-5:5, 1)
  if (x == 0 && y == 0) y <- sample(setdiff(-5:5, 0), 1)
  c(x, y)
}

interpret_cs <- function(cs) {
  if (is.na(cs)) return("One vector has zero length.")
  if (cs > 0.95)  return("Very similar (nearly same direction).")
  if (cs > 0.5)   return("Somewhat similar (acute angle).")
  if (cs > -0.5)  return("Weak/none (near orthogonal).")
  if (cs > -0.95) return("Opposing (obtuse angle).")
  "Very opposing (nearly opposite direction)."
}

# --- initial random values ---
init_lenA <- rand_len()
init_lenB <- rand_len()
init_ang  <- rand_angle()

initA_xy <- rand_coord_pair()
initB_xy <- rand_coord_pair()

# --- vector colors ---
colA <- "#AAABB8"
colB <- "#2C2C54"

ui <- fluidPage(
  tags$head(tags$style(HTML("
    .subtle { color: #444; }
  "))),
  
  titlePanel("Cosine Similarity Intuition: Two Vectors on a Plane"),
  
  fluidRow(
    column(
      4,
      wellPanel(
        actionButton("toggle_mode", "Switch to coordinate inputs"),
        
        tags$hr(),
        
        conditionalPanel(
          condition = "output.mode === 'polar'",
          h4("Polar-style inputs"),
          p(class="subtle", "Vector A is placed on the positive x-axis. Vector B is rotated by the chosen angle."),
          sliderInput("angle", "Angle between Vector A and Vector B (degrees)",
                      min = 0, max = 359, value = init_ang, step = 1),
          
          selectInput("lenA", "Length of Vector A", choices = 1:5, selected = init_lenA),
          selectInput("lenB", "Length of Vector B", choices = 1:5, selected = init_lenB)
        ),
        
        conditionalPanel(
          condition = "output.mode === 'cart'",
          h4("Coordinate inputs"),
          p(class="subtle", "Choose x/y coordinates for the endpoints of each vector (vectors start at the origin)."),
          fluidRow(
            column(6,
                   h5("Vector A"),
                   selectInput("Ax", "A: x", choices = -5:5, selected = initA_xy[1]),
                   selectInput("Ay", "A: y", choices = -5:5, selected = initA_xy[2])
            ),
            column(6,
                   h5("Vector B"),
                   selectInput("Bx", "B: x", choices = -5:5, selected = initB_xy[1]),
                   selectInput("By", "B: y", choices = -5:5, selected = initB_xy[2])
            )
          )
        )
      )
    ),
    
    column(
      8,
      plotOutput("vecPlot", height = "560px")
    )
  )
)

server <- function(input, output, session) {
  mode <- reactiveVal("polar")  # "polar" or "cart"
  
  output$mode <- reactive(mode())
  outputOptions(output, "mode", suspendWhenHidden = FALSE)
  
  observeEvent(input$toggle_mode, {
    if (mode() == "polar") {
      mode("cart")
      updateActionButton(session, "toggle_mode", label = "Switch to angle/length inputs")
    } else {
      mode("polar")
      updateActionButton(session, "toggle_mode", label = "Switch to coordinate inputs")
    }
  })
  
  vectors <- reactive({
    if (mode() == "polar") {
      theta <- deg2rad(input$angle %% 360)
      lenA <- as.numeric(input$lenA)
      lenB <- as.numeric(input$lenB)
      
      A <- c(lenA, 0)
      B <- c(lenB * cos(theta), lenB * sin(theta))
    } else {
      A <- c(as.numeric(input$Ax), as.numeric(input$Ay))
      B <- c(as.numeric(input$Bx), as.numeric(input$By))
    }
    list(A = A, B = B)
  })
  
  cosVal <- reactive({
    v <- vectors()
    cosine_sim(v$A, v$B)
  })
  
  impliedAngleDeg <- reactive({
    cs <- cosVal()
    if (is.na(cs)) return(NA_real_)
    cs <- max(-1, min(1, cs))  # clamp numeric noise
    acos(cs) * 180 / pi
  })
  
  output$vecPlot <- renderPlot({
    v <- vectors()
    A <- v$A; B <- v$B
    
    lim <- 5.5
    plot(NA,
         xlim = c(-lim, lim), ylim = c(-lim, lim),
         xlab = "x", ylab = "y", asp = 1,
         axes = FALSE)
    
    # grid (light), axes (black)
    abline(h = seq(-5, 5, by = 1), v = seq(-5, 5, by = 1), col = "grey90", lwd = 1)
    abline(h = 0, v = 0, col = "black", lwd = 2)
    
    axis(1, col = "black", col.axis = "black")
    axis(2, col = "black", col.axis = "black")
    box(col = "black")
    
    # Thinner vectors (reduced lwd)
    vec_lwd <- 2.2
    
    arrows(0, 0, A[1], A[2], col = colA, lwd = vec_lwd, length = 0.10)
    arrows(0, 0, B[1], B[2], col = colB, lwd = vec_lwd, length = 0.10)
    
    # endpoint labels
    text(A[1], A[2], labels = "A", pos = 4, col = colA, cex = 1.2, font = 2)
    text(B[1], B[2], labels = "B", pos = 4, col = colB, cex = 1.2, font = 2)
    
    # projection cue: projection of B onto A (subtle, neutral color)
    if (sum(A^2) > 0) {
      proj_scalar <- sum(A * B) / sum(A^2)
      proj <- proj_scalar * A
      segments(B[1], B[2], proj[1], proj[2], col = "grey60", lwd = 1.2, lty = 3)
      points(proj[1], proj[2], pch = 16, cex = 0.9, col = "grey40")
      text(proj[1], proj[2], labels = "proj(B on A)", pos = 2, cex = 0.9, col = "grey40")
    }
    
    # mtext with cosine similarity, implied angle, and interpretation
    cs <- cosVal()
    ang <- impliedAngleDeg()
    interp <- interpret_cs(cs)
    
    msg <- if (is.na(cs)) {
      sprintf("Cosine similarity: NA (a vector has zero length)   |   %s", interp)
    } else {
      sprintf("Cosine similarity = %.3f   |   implied angle = %.1f°  \n  %s", cs, ang, interp)
    }
    
    mtext(msg, side = 3, line = 0.8, font = 2, cex = 0.85)  # <-- smaller text
    
    legend("topright",
           legend = c("Vector A", "Vector B"),
           col = c(colA, colB),
           lty = c(1, 1),
           lwd = vec_lwd,
           bty = "n")
  }, res = 120)
}

shinyApp(ui, server)
