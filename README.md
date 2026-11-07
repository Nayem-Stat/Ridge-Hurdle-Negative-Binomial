# The Ridge-Hurdle Negative Binomial Regression Model

R code and data for the paper:

> **Nayem, H.M.; Kibria, B.M.G.** (2025). *The Ridge-Hurdle Negative Binomial Regression Model: A Novel Solution for Zero-Inflated Counts in the Presence of Multicollinearity.* **Stats**, 8(4), 102. https://doi.org/10.3390/stats8040102

The paper is open access (CC BY 4.0) and can be read at the DOI link above.

---

## Overview

Count data with many zeros often also show **overdispersion** and **strongly correlated predictors (multicollinearity)**. ZIP, ZINB and Hurdle models handle the extra zeros and overdispersion, but become unstable under multicollinearity.

The **Ridge-Hurdle Negative Binomial (RHNB)** model adds an L2 (ridge) penalty to the truncated negative binomial count part of the hurdle model, so it handles zero inflation, overdispersion and multicollinearity together.

Models compared in this repository:

| Abbreviation | Model |
|---|---|
| ZIP | Zero-Inflated Poisson |
| ZINB | Zero-Inflated Negative Binomial |
| HP | Hurdle Poisson |
| Hurdle NB | Hurdle Negative Binomial |
| Ridge ZIP | Ridge Zero-Inflated Poisson |
| Ridge ZINB | Ridge Zero-Inflated Negative Binomial |
| **RHNB** | **Ridge-Hurdle Negative Binomial (proposed)** |

## How the ridge estimators are computed

For each model, the maximum likelihood estimate (MLE) of the count coefficients is found first and then shrunk with the ridge projection

$$\hat\beta_{\text{Ridge}} = (X^\top X + \lambda I)^{-1} X^\top X \,\hat\beta_{\text{MLE}}$$

For RHNB, $\hat\beta_{\text{MLE}}$ is the NB fit to the **positive counts only** (the truncated part of the hurdle), and $X$ is the matching subset of rows.

The penalty $\lambda$ is chosen by 5-fold cross-validation over the grid $10^{-4},\dots,10^{2}$: squared error for the count part and log-loss for the logistic (zero) part.

## How MSE is computed

**Simulation study (Section 3).** The true coefficients are known, so

$$\text{MSE}(\hat\beta) = \frac{1}{N}\sum_{i=1}^{N} (\hat\beta_i - \beta)^\top(\hat\beta_i - \beta)$$

where $\beta$ is the normalized eigenvector of $X^\top X$ linked to its largest eigenvalue.

**Real data (Section 4).** The true coefficients are unknown, so each estimate is compared with a fixed **reference coefficient vector** $\beta_{\text{ref}}$:

$$\text{MSE} = \frac{1}{p}\sum_{j=1}^{p} (\hat\beta_j - \beta_{\text{ref},j})^2$$

- Fish data: $\beta_{\text{ref}} = (1, \dots, 1)$ (`code/02_application_fish.R`)
- NMES1988 data: $\beta_{\text{ref}}$ = normalized leading eigenvector of $X^\top X$ (`code/03_application_NMES1988.R`)

This is a coefficient-based criterion. It is **not** a prediction error (it does not compare $\hat y$ with $y$) and **not** a plug-in estimate of the theoretical MSE formula in Section 2.

## Repository structure

```
Ridge-Hurdle-Negative-Binomial/
├── README.md
├── CITATION.cff
├── LICENSE
├── code/
│   ├── 01_simulation_study.R        # Monte Carlo simulation (Section 3, Appendix A)
│   ├── 02_application_fish.R        # Wildlife Fish data (Section 4.1)
│   └── 03_application_NMES1988.R    # Medical Care / NMES1988 data (Section 4.2)
├── data/
│   ├── README.md                    # variable descriptions
│   ├── fish.csv
│   ├── NMES1988.csv                 # original data (factor labels)
│   ├── NMES1988_new.csv             # numerically coded version used by the code
│   └── bioChemists.csv              # extra zero-inflated dataset (not used in the paper)
└── results/                         # output files are written here
```

See [`data/README.md`](data/README.md) for a description of every variable.

## Requirements

R (≥ 4.0) and these packages:

```r
install.packages(c("MASS", "pscl", "dplyr", "openxlsx"))
```

## How to run

Run the scripts **from the repository root**, so the relative paths `data/` and `results/` work:

```r
setwd("path/to/Ridge-Hurdle-Negative-Binomial")
source("code/02_application_fish.R")       # fast
source("code/03_application_NMES1988.R")   # fast
source("code/01_simulation_study.R")       # slow: many scenarios x replications
```

Results are saved in `results/`.

The simulation is long. To test it first, set a small `nsim` (for example `nsim <- 50`) in the parameters section of `01_simulation_study.R`.

## Citation

If you use this code or the model, please cite:

```bibtex
@article{NayemKibria2025RHNB,
  author  = {Nayem, H. M. and Kibria, B. M. Golam},
  title   = {The Ridge-Hurdle Negative Binomial Regression Model: A Novel Solution
             for Zero-Inflated Counts in the Presence of Multicollinearity},
  journal = {Stats},
  year    = {2025},
  volume  = {8},
  number  = {4},
  pages   = {102},
  doi     = {10.3390/stats8040102}
}
```

## Contact

**HM Nayem**, Department of Mathematics and Statistics, Florida International University, Miami, FL, USA
Email: hnayem@fiu.edu

Questions and suggestions are welcome. Please open an issue in this repository.
