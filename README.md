# Economic, Financing, and Housing-Supply Factors Associated with Housing-Price Changes Across U.S. Metropolitan Areas

**MIS581 Capstone | M.S. in Data Analytics | Colorado State University Global**  
**Study period:** 2005–2024 | **Geographic scope:** Seven U.S. metropolitan statistical areas (MSAs)  
**Tools:** Python, pandas, PostgreSQL, Jupyter Notebook, Tableau

## Project overview

This quantitative, observational study examines how national mortgage rates, metropolitan unemployment, changes in inflation-adjusted median household income, and residential building-permit activity are **associated with annual changes in the Federal Housing Finance Agency (FHFA) House Price Index (HPI)**. The analysis compares seven metropolitan housing markets over 20 years, including the 2008 financial crisis and the COVID-19 period.

The purpose is to assess historical statistical relationships and how their interpretation changes after controlling for metropolitan characteristics and shared calendar-year conditions. **The analysis does not establish causation or provide validated housing-price forecasts.**

### Metropolitan areas

- Charleston–North Charleston, South Carolina
- Dallas–Fort Worth–Arlington, Texas
- Kansas City, Missouri–Kansas
- Las Vegas, Nevada
- Nashville, Tennessee
- New York metropolitan area, New York–New Jersey–Pennsylvania
- San Francisco Bay Area, California

## Research question

> What economic, financing, and housing-supply factors are associated with annual changes in housing prices across seven selected U.S. metropolitan statistical areas from 2005 through 2024?

Four **nondirectional** hypotheses evaluate whether statistically significant associations exist between annual HPI changes and (1) national 30-year mortgage rates, (2) metropolitan median household income / real-income growth, (3) metropolitan unemployment, and (4) residential building permits.

## Data and analytical design

| Measure | Operationalization | Primary source |
|---|---|---|
| Housing-price change (outcome) | Annual percentage change in the quarterly FHFA All-Transactions HPI, after annual averaging | [FHFA](https://www.fhfa.gov/reports/house-price-index) |
| Mortgage rates | Annual mean of national weekly 30-year fixed rates | [Freddie Mac](https://www.freddiemac.com/pmms) |
| Unemployment | Annual mean of metropolitan monthly unemployment rates | [BLS LAUS](https://www.bls.gov/lau/) |
| Household income | ACS median household income adjusted to 2024 dollars using annual national CPI-U; modeled primarily as consecutive-year real-income growth | [U.S. Census Bureau ACS](https://www.census.gov/programs-surveys/acs) and [FRED CPI-U](https://fred.stlouisfed.org/series/CPIAUCNS) |
| Housing-supply activity | Authorized residential housing units (building permits) per 1,000 metropolitan residents | [U.S. Census Bureau Building Permits Survey](https://www.census.gov/construction/bps/) |

Python was used to obtain, inspect, clean, align, and annualize the source datasets. Five-digit CBSA identifiers and calendar years were used to integrate the data in a PostgreSQL warehouse with `staging`, `warehouse`, and `analytics` schemas. Tableau was used for interactive historical market comparisons.

The full analytical panel comprises **140 MSA-year observations (7 MSAs × 20 years)**. Standard **2020 ACS one-year estimates were unavailable**; population and income were not interpolated. Because real-income growth also requires an observed preceding year, the **primary complete-case regression sample contains 119 observations** (excluding 2005, 2020, and 2021). A reduced-predictor sensitivity analysis uses **133 observations** after omitting income growth and recovering 2005 and 2021; 2020 remains excluded because population is required to normalize permits.

## Statistical methods

The study used descriptive statistics, Pearson correlations, and three multivariable specifications:

1. **Pooled ordinary least squares (OLS):** associations across pooled metropolitan-year observations.
2. **Metropolitan fixed effects (Metro FE):** adds MSA indicators for persistent differences between markets.
3. **Two-way fixed effects (Two-Way FE):** adds both metropolitan and calendar-year indicators; the preferred interpretive specification for metropolitan-level predictors in this study.

Primary reported inference uses HC3 heteroskedasticity-consistent standard errors at **α = 0.05**. Diagnostics include variance inflation factors, residual dependence indicators, and metropolitan-clustered standard-error sensitivity checks. These do not fully resolve within-MSA serial dependence or the limitations of inference with only seven clusters.

## Principal findings

- Across the full 140-observation panel, mean annual HPI change was **4.70%** (median **4.93%**; standard deviation **8.14 percentage points**). Observed annual changes ranged from **−26.50% to +23.82%**.
- In **pooled OLS** (n = 119), mortgage rates (**β = −1.5918; p = .0006**) and unemployment (**β = −1.5696; p = .0011**) had statistically significant negative conditional associations with annual HPI change. Permits per 1,000 residents had a significant positive association (**β = .4488; p = .0242**); real-income growth was not significant (**p = .4126**).
- In **Metro FE** (n = 119), mortgage rates (**β = −1.7353; p = .0001**) and unemployment (**β = −1.7319; p = .0003**) remained significant, while permits and real-income growth did not.
- In **Two-Way FE** (n = 119), unemployment (**p = .6901**), permits (**p = .7145**), and real-income growth (**p = .0575**) were **not statistically significant** at α = .05. The national mortgage-rate coefficient **cannot be separately identified** when year fixed effects are included because the rate is the same across all seven MSAs in a given year.
- In the reduced-predictor sensitivity analysis, expanding the sample from **119 to 133** observations changed the Metro FE permit result from **β = .5517, p = .1579** to **β = .8489, p = .0001**. The comparable Two-Way FE significance conclusions remained unchanged.

**Interpretation:** Associations found in less restrictive models should not be presented as robust causal effects. Results depend on model specification, observation coverage, common annual conditions, and statistical uncertainty.

## Project workflow

```text
Public economic and housing sources
              |
              v
 Python / Jupyter: acquisition, cleaning, annual alignment
              |
              v
 PostgreSQL: staging -> warehouse -> analytics views
              |                         |
              |                         +--> Tableau historical dashboards
              v
 Python: descriptive analysis, regressions, diagnostics,
         sensitivity analysis, and research figures
```

## Repository contents

| Directory | Contents |
|---|---|
| [`notebooks/`](notebooks/) | Eight reviewed Jupyter notebooks covering exploration, preparation, PostgreSQL integration, modeling, and sensitivity analysis; historical outputs are retained. |
| [`sql/`](sql/) | Nine curated SQL files and execution documentation for schemas, staging, warehouse facts, analytical views, and validation. |
| [`python/`](python/) | Documentation and planned reusable Python-script publication. |
| [`tableau/`](tableau/) | Dashboard documentation; packaged Tableau workbook to be added after review. |
| [`results/`](results/) | Documentation for statistical tables and figures; validated exports to be added. |
| [`docs/`](docs/) | Supporting methodology and reproducibility documentation. |

**Publication status:** The `sql/` and `notebooks/` sections contain curated code. Other directories currently provide documentation or planned locations for additional deliverables; the Tableau workbook, source datasets, and standalone Python scripts should not be presumed present until uploaded.

## Reproducibility and security notes

- **Read the execution instructions in [`sql/README.md`](sql/README.md) and [`notebooks/README.md`](notebooks/README.md) before running code.** Python-generated, processed annual files must populate the PostgreSQL staging tables before warehouse fact loads. The CPI reference table requires its annual CPI data prior to creating the Tableau view.
- The notebooks are sanitized publication copies of the original research notebooks, **not freshly executed end-to-end runs**. Historical successful outputs are retained; some troubleshooting outputs were removed.
- Local datasets are **not included**. Relative paths assume locally obtained raw/processed source data under an appropriate `data/` directory; consult the notebooks for expected file structures. Review each source's usage and redistribution terms before sharing data.
- Configure Census API access using a local `CENSUS_API_KEY` environment variable, where applicable. Database credentials should remain local and must not be committed.
- SQL scripts consolidate recorded and user-confirmed development steps, with the analytical and Tableau view definitions retrieved from the working PostgreSQL database. **The combined SQL workflow has not been independently tested as a new end-to-end installation.**

## Limitations

The seven MSAs were selected purposively and do not represent a random national sample. Metropolitan boundaries and definitions can change over time. National mortgage rates do not capture local financing terms; building permits measure authorized construction rather than completed inventory. Annual averaging may obscure shorter-term changes or lagged effects, and missing ACS observations constrain coverage. Residual persistence and few-cluster inference limit the strength of significance testing. Reverse causality, omitted factors, and common shocks remain plausible explanations. **These findings are descriptive and associational, not investment or lending recommendations.**

## Original academic work

*Concilio, P. (2026). Economic, financing, and housing-supply factors associated with housing-price changes across U.S. metropolitan areas.* MIS581 Capstone, Colorado State University Global. Final paper dated October 31, 2026.

The source paper contains the full literature review, detailed model comparisons, diagnostics, sensitivity analysis, references, and three Python-generated figures: (1) a seven-MSA HPI trend panel, (2) a Pearson correlation heatmap, and (3) regression coefficient comparisons with 95% HC3 confidence intervals.

---

*Research and implementation: Pasquale Concilio. Prepared as an academic data analytics capstone.*
