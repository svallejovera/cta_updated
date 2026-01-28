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
- `index.Rmd` - Course overview and homepage
- `01-readings.Rmd` through `04-final_project.Rmd` - Course logistics
- `05-week1.Rmd` through `11-week7.Rmd` - Weekly lesson content with executable R code

**Configuration:**
- `_bookdown.yml` - Bookdown settings (output dir, book filename)
- `_output.yml` - Output format specs (themes, PDF/EPUB settings)
- `style.css` - Custom styling for HTML output
- `preamble.tex` - LaTeX preamble for PDF output

**Data and Assets:**
- `data/` - Course datasets (CSV, XLSX, Rdata files)
- `images/` - Figures referenced in content
- `slides/` - PowerPoint lecture slides

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

- Weeks 1-5: R-focused (tidyverse, tidytext, quanteda, STM)
- Weeks 6-11: Combined R and Python (word embeddings, LLMs, transformers)
