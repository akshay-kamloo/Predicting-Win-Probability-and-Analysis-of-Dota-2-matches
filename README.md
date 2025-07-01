# Dota 2 Match Analytics 🎮📊

Predicting **win probability** at the 15‑minute mark and analysing whether the **team that destroys the first barracks** ultimately wins the game.

> **Dataset:** Kaggle — [Dota 2 Matches](https://www.kaggle.com/devinanzelmo/dota-2-matches)  

The project is implemented fully in **R** and comprises two standalone scripts plus accompanying visualisations.

---

## Table of Contents
1. [Project Overview](#project-overview)  
2. [Requirements](#requirements)  
3. [Quick Start](#quick-start)  
4. [Project Structure](#project-structure)  
5. [Methodology](#methodology)  
6. [Sample Results](#sample-results)  
7. [Limitations & Future Work](#limitations--future-work)  
8. [License](#license)  

---

## Project Overview

| Script | What it does |
|--------|--------------|
| **`match_prediction.R`** | Builds a **Random Forest** classifier to predict the *Radiant* win probability using team **Gold** and **XP** advantages captured at 15 minutes. |
| **`match_analysis(barracks).R`** | Exploratory data analysis to test the hypothesis: *“The team that destroys the first barracks wins the match.”* Generates summary tables and `Rplot*.png` charts. |

All plots (`Rplot.png`, `Rplot01.png`, `Rplot02.png`) are saved automatically when the scripts finish.

---

## Requirements

- **R ≥ 4.2**  
- CRAN packages:  

```r
install.packages(c(
  "ggplot2",
  "readr",
  "dplyr",
  "matrixStats",
  "randomForest",
  "ROCR"
))
```

---

## Quick Start

```bash
# 1  Clone the repository
git clone https://github.com/akshay-kamloo/Predicting-Win-Probability-and-Analysis-of-Dota-2-matches.git
cd Predicting-Win-Probability-and-Analysis-of-Dota-2-matches

# 2  Download and unzip the Kaggle dataset
#    Place the CSV files in a folder of your choice (e.g. data/)

# 3  Open R or RStudio
Rscript match_prediction.R          # trains the model & writes dotapredict.csv
Rscript "match_analysis(barracks).R"   # runs the barracks‑first analysis
```

> **Important 🔧**  
> Update the hard‑coded file paths inside both R scripts (currently `E:/dota-2-matches/…`) so they point to your **local** Kaggle dataset location before running.

---

## Project Structure

```
Predicting-Win-Probability-and-Analysis-of-Dota-2-matches/
│
├── match_prediction.R
├── match_analysis(barracks).R
├── Rplot.png
├── Rplot01.png
├── Rplot02.png
└── README.md   ← you are here
```

---

## Methodology

### 1. Feature Engineering (`match_prediction.R`)
* Calculates **team‑level aggregates** at each timestamp:  
  - Radiant / Dire Gold totals, **Gold Advantage**, **Gold SD**, **Gold MAD**  
  - Radiant / Dire XP totals, **XP Advantage**, **XP SD**, **XP MAD**
* Filters to **game mode 22** (captains‑mode), retains the **15‑minute snapshot** (`times == 900`).
* Trains a **Random Forest** (100 trees) with six engineered features to predict `radiant_win`.
* Evaluates with **AUC‑ROC** (via `ROCR`) and class‑error plots.

### 2. Barracks Hypothesis (`match_analysis(barracks).R`)
* Merges match‑level data with objective events to flag the team that **destroys the first barracks**.
* Crosstabs the event against the final outcome to compute **win percentages**.
* Generates bar‑plots and cumulative distribution charts saved as `Rplot*.png`.

---

## Sample Results

| Model | Metric | Score |
|-------|--------|-------|
| Random Forest (15‑min snapshot) | **AUC‑ROC** | ~0.78 |
| First Barracks Destruction | **Win Rate** | Radiant ≃ 73 % • Dire ≃ 71 % |

*(Exact numbers will vary depending on dataset version and filtering.)*

---

## Limitations & Future Work
- File paths are hard‑coded; refactor to **command‑line arguments** or `here::here()`.  
- Investigate **time‑series models** (LSTM, XGBoost TS) for dynamic win‑probability curves.  
- Extend features: hero picks, item timings, ward placements.  
- Package as an **Shiny** dashboard for live match‑tracking.

---

## License

Released under the **MIT License**. See `LICENSE` for details.  
*Feel free to fork and build on this analysis!* 🎯
