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

## References

[1] Cameron, A.C.; Trivedi, P.K. Regression Analysis of Count Data, 2nd ed.; Cambridge University Press: Cambridge, UK, 2013.

[2] Schober, P.; Vetter, T.R. Count data in medical research: Poisson regression and negative binomial regression. Anesth. Analg. 2021, 132, 1378–1379. https://doi.org/10.1213/ANE.0000000000005398

[3] Akram, M.N.; Abonazel, M.R.; Amin, M.; Kibria, B.G.; Afzal, N. A new Stein estimator for the zero-inflated negative binomial regression model. Concurr. Comput. Pract. Exp. 2022, 34, e7045. https://doi.org/10.1002/cpe.7045

[4] Lambert, D. Zero-inflated Poisson regression, with an application to defects in manufacturing. Technometrics 1992, 34, 1–14. https://doi.org/10.2307/1269547

[5] Ridout, M.; Demétrio, C.G.; Hinde, J. Models for count data with many zeros. In Proceedings of the International Biometric Conference, 1998; pp. 179–192.

[6] Greene, W.H. Accounting for Excess Zeros and Sample Selection in Poisson and Negative Binomial Regression Models; NYU Working Paper; New York University: New York, NY, USA, 1994.

[7] Amalia, R.N.; Sadik, K.; Notodiputro, K.A. A study of ZIP and ZINB regression modeling for count data with excess zeros. J. Phys. Conf. Ser. 2021, 1863, 012022. https://doi.org/10.1088/1742-6596/1863/1/012022

[8] Lord, D.; Mannering, F. The statistical analysis of crash-frequency data: A review and assessment of methodological alternatives. Transp. Res. A 2010, 44, 291–305. https://doi.org/10.1016/j.tra.2010.02.001

[9] Deb, P.; Trivedi, P.K. Demand for medical care by the elderly: A finite mixture approach. J. Appl. Econ. 1997, 12, 313–336. https://doi.org/10.1002/(SICI)1099-1255(199705)12:3<313::AID-JAE440>3.0.CO;2-G

[10] Abonazel, M.R.; El-Sayed, S.M.; Saber, O.M. Performance of robust count regression estimators in the case of overdispersion, zero inflated, and outliers: Simulation study and application to German health data. Commun. Math. Biol. Neurosci. 2021, 2021, 55. https://doi.org/10.28919/cmbn/5658

[11] Rose, C.E.; Martin, S.W.; Wannemuehler, K.A.; Plikaytis, B.D. On the use of zero-inflated and hurdle models for modeling vaccine adverse event count data. J. Biopharm. Stat. 2006, 16, 463–481. https://doi.org/10.1080/10543400600719384

[12] Feng, C.X. A comparison of zero-inflated and hurdle models for modeling zero-inflated count data. J. Stat. Distrib. Appl. 2021, 8, 8. https://doi.org/10.1186/s40488-021-00121-4

[13] Mullahy, J. Specification and testing of some modified count data models. J. Econom. 1986, 33, 341–365. https://doi.org/10.1016/0304-4076(86)90002-3

[14] Cragg, J.G. Some statistical models for limited dependent variables with application to the demand for durable goods. Econometrica 1971, 39, 829–844. https://doi.org/10.2307/1909582

[15] Lee, J.; Mannering, F.L.; Kim, D.K. Statistical modeling of highway safety data: Hurdle models revisited. Anal. Methods Accid. Res. 2021, 30, 100165.

[16] Xu, L.; Paterson, A.D.; Turpin, W.; Xu, W. Assessment and selection of competing models for zero-inflated microbiome data. PLoS ONE 2015, 10, e0129606. https://doi.org/10.1371/journal.pone.0129606

[17] Min, Y.; Agresti, A. Random effect models for repeated measures of zero-inflated count data. Stat. Model. 2005, 5, 1–19. https://doi.org/10.1191/1471082X05st084oa

[18] Ghosh, P.; Mukerjee, R.; Chatterjee, S. Bayesian analysis of zero-inflated regression models. J. Stat. Plan. Inference 2012, 142, 1393–1403. https://doi.org/10.1016/j.jspi.2004.10.008

[19] Famoye, F.; Singh, K.P. Zero-inflated generalized Poisson regression model with an application to domestic violence data. J. Data Sci. 2006, 4, 117–130. https://doi.org/10.6339/JDS.2006.04(1).257

[20] Gurmu, S.; Trivedi, P.K. Excess zeros in count models for recreational trips. J. Appl. Econ. 1996, 11, 341–358. https://doi.org/10.1080/07350015.1996.10524676

[21] Winkelmann, R. Econometric Analysis of Count Data, 5th ed.; Springer: Berlin/Heidelberg, Germany, 2008.

[22] Hilbe, J.M. Negative Binomial Regression, 2nd ed.; Cambridge University Press: Cambridge, UK, 2011.

[23] Montgomery, D.C.; Peck, E.A.; Vining, G.G. Introduction to Linear Regression Analysis, 5th ed.; Wiley: Hoboken, NJ, USA, 2012.

[24] Dormann, C.F.; Elith, J.; Bacher, S.; Buchmann, C.; Carl, G.; Carré, G.; Marquéz, J.R.G.; Gruber, B.; Lafourcade, B.; Leitão, P.J.; et al. Collinearity: A review of methods to deal with it and a simulation study evaluating their performance. Ecography 2013, 36, 27–46. https://doi.org/10.1111/j.1600-0587.2012.07348.x

[25] Hoerl, A.E.; Kennard, R.W. Ridge regression: Biased estimation for nonorthogonal problems. Technometrics 1970, 12, 55–67. https://doi.org/10.1080/00401706.1970.10488634

[26] Kibria, B.M.G.; Månsson, K.; Shukur, G. A simulation study of some biasing parameters for the ridge type estimation of Poisson regression. Commun. Stat. Simul. Comput. 2015, 44, 943–957. https://doi.org/10.1080/03610918.2013.796981

[27] Khan, A.; Ullah, M.A.; Amin, M. Poisson regression diagnostics with ridge estimation. Commun. Stat. Simul. Comput. 2023, 52, 4174–4192. https://doi.org/10.1080/03610918.2021.1955262

[28] Rady, E.A.; Abonazel, M.R.; Taha, I.M. Ridge estimators for the negative binomial regression model with application. In Proceedings of the 53rd Annual Conference on Statistics, Computer Science, and Operation Research, 2018; pp. 3–5.

[29] Akram, M.N.; Afzal, N.; Amin, M.; Batool, A. Modified ridge-type estimator for the zero inflated negative binomial regression model. Commun. Stat. Simul. Comput. 2024, 53, 5305–5322. https://doi.org/10.1080/03610918.2023.2179070

[30] Zeeshan, M.; Khan, A.; Amanullah, M.; Bakr, M.E.; Alshangiti, A.M.; Balogun, O.S.; Yusuf, M. A new modified biased estimator for Zero inflated Poisson regression model. Heliyon 2024, 10, e24225. https://doi.org/10.1016/j.heliyon.2024.e24225

[31] McGough, S.F.; Incerti, D.; Lyalina, S.; Copping, R.; Narasimhan, B.; Tibshirani, R. Penalized regression for left-truncated and right-censored survival data. Stat. Med. 2021, 40, 5487–5500. https://doi.org/10.1002/sim.9136

[32] Friedman, J.; Hastie, T.; Tibshirani, R. Regularization paths for generalized linear models via coordinate descent. J. Stat. Softw. 2010, 33, 1–22. https://doi.org/10.18637/jss.v033.i01

[33] Kibria, B.M.G.; Månsson, K.; Shukur, G. A Ridge Regression Estimator for the Zero-Inflated Poisson Model; CESIS Working Paper; Royal Institute of Technology: Stockholm, Sweden, 2011.

[34] Kibria, B.M.G.; Månsson, K.; Shukur, G. Some ridge regression estimators for the zero-inflated Poisson model. J. Appl. Stat. 2013, 40, 721–735. https://doi.org/10.1080/02664763.2012.752448

[35] Yüzbaşı, B.; Asar, A. Ridge type estimation in the zero-inflated negative binomial regression. Econom. Methods Appl. 2018, 93.

[36] Qasim, M.; Månsson, K.; Amin, M.; Kibria, B.M.G.; Sjölander, P. Biased adjusted Poisson ridge estimators: Method and application. Iran. J. Sci. Technol. Trans. A Sci. 2020, 44, 1775–1789. https://doi.org/10.1007/s40995-020-00974-5

[37] Aladeitan, B.B.; Adebimpe, O.; Lukman, A.F.; Oludoun, O.; Abiodun, O.E. Modified Kibria–Lukman (MKL) estimator for the Poisson regression model: Application and simulation. F1000Research 2021, 10, 548. https://doi.org/10.12688/f1000research.53987.2

[38] Raihan, M.A.; Alluri, P.; Wu, W.; Gan, A. Estimation of bicycle crash modification factors (CMFs) on urban facilities using zero-inflated negative binomial models. Accid. Anal. Prev. 2019, 123, 303–313. https://doi.org/10.1016/j.aap.2018.12.009

[39] Bhaktha, N. Properties of Hurdle Negative Binomial Models for Zero-Inflated and Overdispersed Count Data. 2018.

[40] Park, M.Y.; Hastie, T. L1-regularization path algorithm for generalized linear models. J. R. Stat. Soc. B 2007, 69, 659–677. https://doi.org/10.1111/j.1467-9868.2007.00607.x

[41] Al-Taweel, Y.; Algamal, Z. Almost unbiased ridge estimator in the zero-inflated Poisson regression model. TWMS J. Appl. Eng. Math. 2022, 12, 235–246.

[42] Kibria, B.M.G. Performance of some new ridge regression estimators. Commun. Stat. Simul. Comput. 2003, 32, 419–435. https://doi.org/10.1081/SAC-120017499

[43] Hoque, M.A.; Kibria, B.M. Some one and two parameter estimators for the multicollinear Gaussian linear regression model: Simulations and applications. Surv. Math. Appl. 2023, 18, 183–221.

[44] Hoque, M.A.; Kibria, B.G. Performance of some estimators for the multicollinear logistic regression model: Theory, simulation, and applications. Res. Stat. 2024, 2, 2364747. https://doi.org/10.1080/27684520.2024.2364747

[45] Nayem, H.M.; Aziz, S.; Kibria, B.M.G. Comparison among ordinary least squares, ridge, lasso, and elastic net estimators in the presence of outliers: Simulation and application. Int. J. Stat. Sci. 2024, 24, 25–48. https://doi.org/10.3329/ijss.v24i20.78212

[46] Yasmin, N.; Kibria, B.M. Performance of some improved estimators and their robust versions in presence of multicollinearity and outliers. Sankhya B 2025, 87, 173–219. https://doi.org/10.1007/s13571-025-00352-4

[47] Fletcher, D.; MacKenzie, D.; Villouta, E. Modelling skewed data with many zeros: A simple approach combining ordinary and logistic regression. Environ. Ecol. Stat. 2005, 12, 45–54. https://doi.org/10.1007/s10651-005-6817-1

[48] Hua, H.; Tang, W.; Wang, W.; Paul, C. Structural zeroes and zero-inflated models. Shanghai Arch. Psychiatry 2014, 26, 236.

[49] Bertoli, W.; Conceição, K.S.; Andrade, M.G.; Louzada, F. A Bayesian approach for some zero-modified Poisson mixture models. Stat. Model. 2020, 20, 467–501. https://doi.org/10.1177/1471082X19841984

[50] Alheety, M.I.; Nayem, H.M.; Kibria, B.M.G. An unbiased convex estimator depending on prior information for the classical linear regression model. Stats 2025, 8, 16. https://doi.org/10.3390/stats8010016

[51] Nayem, H.M.; Aziz, S.; Kibria, B.M.G. Evaluating estimator performance under multicollinearity: A trade-off between MSE and accuracy in logistic, lasso, elastic net, and ridge regression with varying penalty parameters. Stats 2025, 8, 45. https://doi.org/10.3390/stats8020045

[52] Yu, Y.; Yang, L.; Shen, Y.; Wang, W.; Li, B.; Chen, Q. An iterative and shrinking generalized ridge regression for ill-conditioned geodetic observation equations. J. Geod. 2024, 98, 3. https://doi.org/10.1007/s00190-023-01795-1

[53] Patil, P.; Du, J.H.; Tibshirani, R.J. Optimal ridge regularization for out-of-distribution prediction. arXiv 2024. https://doi.org/10.48550/arXiv.2404.01233

[54] Seifollahi, S.; Bevrani, H.; Algamal, Z.Y. Shrinkage estimators in zero-inflated Bell regression model with application. J. Stat. Theory Pract. 2025, 19, 1. https://doi.org/10.1007/s42519-024-00415-1

[55] Zeileis, A.; Kleiber, C.; Jackman, S. Regression models for count data in R. J. Stat. Softw. 2008, 27, 1–25. https://doi.org/10.18637/jss.v027.i08

## Contact

**HM Nayem**, Department of Mathematics and Statistics, Florida International University, Miami, FL, USA
Email: hnayem@fiu.edu

Questions and suggestions are welcome. Please open an issue in this repository.
