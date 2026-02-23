# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic course book for PS9594: "Computational Text Analysis" at Western University, built with R/Bookdown. It contains weekly teaching materials including code examples, exercises, and slides covering NLP and text-as-data methods.

## Build Commands

```r
# Build the complete book (renders all Rmd files to docs/)
bookdown::render_book()

# Live preview during development (auto-rebuilds on save)
bookdown::serve_book()
```

Build output goes to the `docs/` directory. The project supports multiple output formats: HTML (bs4_book), PDF, and EPUB.

## Architecture

**Content Structure:**

*Course Information:*
- `index.Rmd` - Course homepage with overview, syllabus link, and required R/Python packages
- `01-readings.Rmd` - Week-by-week reading list with academic references for each topic
- `02-assignments.Rmd` - Three graded worksheets with pair programming approach; submission guidelines and due dates
- `03-replication.Rmd` - Replication exercise instructions (30% of grade); students replicate a syllabus paper
- `04-final_project.Rmd` - Final paper requirements (4,000 words max); GitHub repo submission with data, code, and report

*Weekly Lessons (executable R code):*
- `05-week1.Rmd` - Primer on text-as-data; replicates Mendenhall's word-length analysis using Oscar Wilde plays from Project Gutenberg
- `06-week2.Rmd` - Tokenization and word frequency; uses song lyrics corpus to demonstrate text cleaning and quanteda DFM creation
- `07-week3.Rmd` - Dictionary-based sentiment analysis; applies AFINN/Bing lexicons to Ventura et al. debate chat data
- `08-week4.Rmd` - Text complexity and similarity; string distances (Levenshtein, Jaro), cosine similarity, TF-IDF weighting
- `09-week5.Rmd` - Unsupervised scaling with Wordfish; positions U.S. presidential inaugural speeches on ideological scale
- `10-week6.Rmd` - Structural Topic Models (STM); k-means intuition and topic modeling on inaugural speeches
- `11-week7.Rmd` - Supervised learning intro; Wordscores technique replicating Laver & Benoit (2003)

*Weeks 8-11 (planned, slides and readings exist but no Rmd files yet):*
- Week 8 - Introduction to Deep Learning and Word Embeddings
- Week 9 - The Transformers Architecture
- Week 10 - Encoder-Only LLMs
- Week 11 - Decoder-Only LLMs (Generative LLMs)

**Configuration:**
- `_bookdown.yml` - Bookdown settings (output dir, book filename)
- `_output.yml` - Output format specs (themes, PDF/EPUB settings)
- `style.css` - Custom styling for HTML output
- `preamble.tex` - LaTeX preamble for PDF output
- `cta_updated.Rproj` - RStudio project file (BuildType: Website)
- `book.bib` - Bibliography file for references
- `packages.bib` - Auto-generated bibliography for R packages
- `.nojekyll` - Jekyll bypass file for GitHub Pages hosting

**Data and Assets:**
- `data/` - Course datasets:
  - `lyrics_sample.xlsx` - Song lyrics corpus (Week 2)
  - `ventura_etal_df.Rdata` - Debate chat data from Ventura et al. (Week 3)
  - `inaugTexts.xlsx` - U.S. presidential inaugural speeches (Weeks 5-6)
  - `NRC-AffectIntensity-Lexicon.txt` - Sentiment lexicon
  - `candidate-tweets.csv`, `candidate-tweets_en.csv` - Political tweets data
  - `politics_sample.csv`, `book_blurbs.csv` - Additional text corpora
  - `anes_sample.Rdata` - American National Election Studies sample
- `images/` - Figures referenced in content
- `files/` - Course documents (syllabus PDF: `9594_Computational_Text_Analysis_2026.pdf`)
- `slides/` - PowerPoint lecture slides (Weeks 1-7 implemented, plus advanced topics 8-13)

**Shiny Apps:**
- `k-means/app.R` - K-means clustering step-by-step intuition builder (used in Week 6)
- `cosinesimA/app.R` - Cosine similarity intuition builder with 2D vectors (polar/Cartesian inputs) (used in Week 4)
- `cosinesimilarityTEXT/app.R` - Build sentences → DFM → cosine similarity → 3D vector visualization (used in Week 4)

**Shiny App References in Course Content:**
- `08-week4.Rmd` (line 148) - Links to both `cosinesimA` and `cosinesimilarityTEXT` apps for cosine similarity visualization
- `10-week6.Rmd` (line 9) - Links to `k-means` app for clustering intuition before STM content

## Key R Packages

The codebase relies on: `tidyverse`, `tidytext`, `quanteda` (with extensions: `quanteda.textstats`, `quanteda.textplots`, `quanteda.dictionaries`), `stm`, `gutenbergr`, `wesanderson`, `kableExtra`

## Course Content Split

- Weeks 1-7: R-focused (tidyverse, tidytext, quanteda, STM, Wordscores) - **implemented**
- Weeks 8-11: Deep learning and LLMs (word embeddings, transformers, encoder/decoder models) - **slides and readings exist, Rmd files not yet implemented**

Note: Python integration for weeks 8-11 is planned but not yet committed to the repository.
