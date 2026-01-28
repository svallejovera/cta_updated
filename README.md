# PS9594: Computational Text Analysis

This repo contains teaching materials for the "Computational Text Analysis" (PS9594) course at Western University. The book includes code, exercises, and slides for each week.

This will be the main resource we use throughout the course. You can access all of these materials, as well as the course overview by following [this link](https://svallejovera.github.io/cta_updated/). I will continue to update the site throughout the semester(s).

## Course Topics

| Week | Topic | Key Methods |
|------|-------|-------------|
| 1 | A Primer on Using Text as Data | Word-length distributions, Project Gutenberg |
| 2 | Tokenization and Word Frequency | Text cleaning, quanteda DFM, TF-IDF |
| 3 | Dictionary-Based Approaches | Sentiment analysis (AFINN, Bing), custom dictionaries |
| 4 | Complexity and Similarity | String distances, cosine similarity |
| 5 | Scaling Techniques (Unsupervised I) | Wordfish |
| 6 | Topic Modeling (Unsupervised II) | K-means, Structural Topic Models (STM) |
| 7 | Supervised Learning | Wordscores |
| 8-11 | Advanced Topics | Word embeddings, LLMs, Transformers (R + Python) |

## Interactive Shiny Apps

The course includes three interactive Shiny apps for building intuition:

- [K-means Clustering](https://ci1yq0-sebastian0vallejo.shinyapps.io/k-means/) - Step-by-step visualization of the k-means algorithm
- [Cosine Similarity (Vectors)](https://ci1yq0-sebastian0vallejo.shinyapps.io/cosinesimA/) - 2D vector visualization with polar/Cartesian inputs
- [Cosine Similarity (Text)](https://ci1yq0-sebastian0vallejo.shinyapps.io/cosinesimilarityTEXT/) - Build sentences, create DFM, visualize as 3D vectors

## Building the Book Locally

```r
# Install required packages
install.packages(c("bookdown", "tidyverse", "tidytext", "quanteda",
                   "quanteda.textstats", "quanteda.textplots",
                   "stm", "gutenbergr", "wesanderson", "kableExtra"))

# Build the complete book (output in docs/)
bookdown::render_book()

# Live preview with auto-rebuild
bookdown::serve_book()
```

## Repository Structure

```
.
├── index.Rmd                 # Course homepage
├── 01-readings.Rmd           # Reading list
├── 02-assignments.Rmd        # Graded worksheets
├── 03-replication.Rmd        # Replication exercise
├── 04-final_project.Rmd      # Final paper instructions
├── 05-week1.Rmd ... 11-week7.Rmd  # Weekly lessons
├── data/                     # Course datasets
├── slides/                   # PowerPoint lectures
├── images/                   # Figures
├── k-means/                  # Shiny app: k-means
├── cosinesimA/               # Shiny app: cosine similarity (vectors)
├── cosinesimilarityTEXT/     # Shiny app: cosine similarity (text)
└── docs/                     # Built book output
```

## Note on the use of LLM for this course/site 

A bit of inception-meta-commentary, while this course teaches about LLMs, I am also using LLMs in different capacities. For transparency, this is where I have used GPT or Claude for the construction of the course (I will update this list if/when it grows):
  1. I have LLMs annotate my code: I do not like annotating code and I am not particularly good at it. I let LLMs do that, especially at the beginning of the course, when students are less familiar with some of the libraries and functions. 
  2. I have LLMs check for spelling, typos, grammar, and clarity of the text on the website (not the slides): English is hard; typing is hard, RSTudio and VSCode do not come with a spelling checker.
  3. I have Claude map this repo and perform commit/push/pull tasks of minor adjustments to the site. You can check the map of this repo in the CLAUDE.md.
