# Datasets

All datasets are count outcomes with many zeros, overdispersion and correlated predictors.

---

## 1. `fish.csv` — Wildlife Fish data (paper Section 4.1)

250 groups of visitors to a state park. Response: number of fish caught. **56.8% zeros.**

| Variable | Type | Description |
|---|---|---|
| `count` | count (0–149) | **Response.** Number of fish caught |
| `nofish` | binary (0/1) | 1 = the trip was not only for fishing |
| `livebait` | binary (0/1) | 1 = live bait was used |
| `camper` | binary (0/1) | 1 = the group brought a camper |
| `persons` | integer (1–4) | Number of people in the group |
| `child` | integer (0–3) | Number of children in the group |
| `xb` | continuous | Linear-predictor covariate supplied with the dataset |
| `zg` | continuous | Zero-part covariate supplied with the dataset |

`code/02_application_fish.R` uses all seven predictors above.

---

## 2. `NMES1988.csv` — Medical Care data, original version (paper Section 4.2)

4,406 people aged 66 and older covered by Medicare, from the U.S. National Medical Expenditure Survey 1987–1988 (Deb & Trivedi, 1997). This is the `NMES1988` dataset distributed with the R package **AER**. Categorical variables are stored as text labels.

| Variable | Type | Description |
|---|---|---|
| `visits` | count | Physician office visits |
| `nvisits` | count | Non-physician office visits |
| `ovisits` | count | Physician hospital outpatient visits |
| `novisits` | count | Non-physician hospital outpatient visits |
| `emergency` | count | Emergency room visits |
| `hospital` | count | Number of hospital stays |
| `health` | factor | Self-perceived health: `poor`, `average`, `excellent` |
| `chronic` | count | Number of chronic conditions |
| `adl` | factor | Activities of daily living: `normal`, `limited` |
| `region` | factor | `northeast`, `midwest`, `west`, `other` |
| `age` | numeric | Age in years divided by 10 |
| `afam` | factor | African American: `yes` / `no` |
| `gender` | factor | `male` / `female` |
| `married` | factor | `yes` / `no` |
| `school` | integer | Years of education |
| `income` | numeric | Family income in USD 10,000 |
| `employed` | factor | `yes` / `no` |
| `insurance` | factor | Private insurance: `yes` / `no` |
| `medicaid` | factor | Medicaid coverage: `yes` / `no` |

---

## 3. `NMES1988_new.csv` — Medical Care data, coded version used by the code

The same 4,406 people as `NMES1988.csv`, with the variables `visits`, `nvisits` and `ovisits` removed and every factor converted to numbers. Response: **`novisits`** (83.8% zeros). The other 15 columns are the predictors.

Numeric codes:

| Variable | Coding |
|---|---|
| `health` | 1 = poor, 2 = average, 3 = excellent |
| `adl` | 1 = limited, 2 = normal |
| `region` | 1 = midwest, 2 = northeast, 3 = other, 4 = west |
| `gender` | 1 = female, 2 = male |
| `afam`, `married`, `employed`, `insurance`, `medicaid` | 0 = no, 1 = yes |

`code/03_application_NMES1988.R` reads this file.

---

## 4. `bioChemists.csv` — Article production by biochemistry PhD students (extra)

915 PhD students in biochemistry (Long, 1990). This is the `bioChemists` dataset from the R package **pscl**. **30.1% zeros.** It is **not used in the paper** and is included as an additional zero-inflated example.

| Variable | Type | Description |
|---|---|---|
| `art` | count (0–19) | **Response.** Articles published in the last 3 years of the PhD |
| `fem` | factor | `Men` / `Women` |
| `mar` | factor | `Married` / `Single` |
| `kid5` | integer | Number of children aged 5 or younger |
| `phd` | numeric | Prestige of the PhD department |
| `ment` | integer | Articles published by the mentor in the last 3 years |

---

## Sources

- Deb, P.; Trivedi, P.K. (1997). Demand for medical care by the elderly: A finite mixture approach. *Journal of Applied Econometrics*, 12, 313–336.
- Long, J.S. (1990). The origins of sex differences in science. *Social Forces*, 68, 1297–1316.
- Zeileis, A.; Kleiber, C.; Jackman, S. (2008). Regression models for count data in R. *Journal of Statistical Software*, 27(8), 1–25.
