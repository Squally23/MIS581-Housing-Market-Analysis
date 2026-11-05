# MIS581 Housing Market Analysis — Data

This directory contains **project-specific processed datasets** derived from the public statistical sources cited in the capstone paper. The original downloaded agency workbooks are **not redistributed** in this repository. The processed CSV files are archived input snapshots from the completed 2005–2024 analysis, **not current agency releases**.

## Contents and expected observations

| File (under `processed/`) | Records | Purpose |
|---|---:|---|
| `building_permits_msa_2005_2024.csv` | 140 | Authorized residential units and structure categories by CBSA and year |
| `fhfa_hpi_msa_2005_2024.csv` | 140 | Annualized FHFA house price index and annual percentage changes |
| `bls_unemployment_msa_2005_2024.csv` | 140 | Annual average unemployment rates |
| `freddie_mac_30yr_2005_2024.csv` | 20 | National annual average 30-year mortgage rate |
| `census_acs_income_population_2005_2024.csv` | 133 | ACS population and median household income, no 2020 ACS 1-year observations |
| `cpi_u_annual_2005_2024.csv` | 20 | National annual-average CPI-U for inflation adjustment |
| `building_permits_validation_summary.csv` | 1 | Permit dataset integrity summary |
| `sensitivity_analysis/*.csv` | Varies | Derived statistical sensitivity comparison outputs; not source tables for warehouse loading |

The seven selected CBSAs are 16700, 19100, 28140, 29820, 34980, 35620, and 41860. The annual analytical spine has 7 × 20 = 140 combinations. The Census ACS dataset has 133 rows because standard 2020 ACS 1-year estimates were not available. The income-growth modeling sample excludes 2005, 2020, and 2021 (119 observations); the reduced-predictor sensitivity sample has 133 observations. Missing values were not silently imputed.

## How to use these files

1. Create a local PostgreSQL database named `mis581_capstone` and run `sql/01_create_schemas_dimensions.sql`, `sql/02_create_staging_tables.sql` and `sql/03_create_warehouse_facts.sql` from the repository root, in sequence.
2. Use the data-loading portions of `notebooks/08_postgresql_data_warehouse.ipynb` (or an equivalent local loader) to populate the five staging tables from the matching `data/processed/` CSV files. Building permits go into `staging.building_permits`; the other four sources each have their own staging tables.
3. Run `sql/04_load_warehouse_facts.sql` and `sql/05_validate_warehouse.sql` to load and reconcile facts. Create the integrated analytical view with `sql/06_create_analytical_view.sql`.
4. Create the CPI table using `sql/07_create_cpi_reference.sql`, then **import** `data/processed/cpi_u_annual_2005_2024.csv` into `analytics.ref_cpi_annual` before running `sql/08_create_tableau_view.sql` and `sql/09_validate_tableau_view.sql`.

**Important:** The SQL files are consolidated publication copies, not an independently executed end-to-end installation. Some historical notebooks expect particular relative paths, source files, or a local PostgreSQL configuration. Use the repository's notebook and SQL READMEs for prerequisites. No API keys, passwords, or `.env` files are included here.

## Original data sources (download upstream)

- FHFA All-Transactions House Price Index, metro series: https://www.fhfa.gov/data/hpi/datasets
- Bureau of Labor Statistics Local Area Unemployment Statistics: https://www.bls.gov/lau/
- U.S. Census Bureau Building Permits Survey: https://www.census.gov/construction/bps/index.html
- Census American Community Survey 1-year API: https://www.census.gov/data/developers/data-sets/acs-1year.html
- Freddie Mac Primary Mortgage Market Survey archive: https://www.freddiemac.com/pmms/pmms_archives
- FRED / BLS CPI-U series (`CPIAUCNS`): https://fred.stlouisfed.org/series/CPIAUCNS

Raw source workbooks can be downloaded from these providers (note that live upstream files may be revised after the research snapshot). Check each publisher's current terms before redistributing original files. The original project also used Census CBSA delineation tables and a historical permit extraction methodology, described in `building_permits_methodology_notes.md`.

## Caveats

- Census ACS 2020 standard 1-year missingness was preserved; permit normalization therefore also depends on available population data.
- Mortgage rates and CPI-U are *national* series, not MSA-specific.
- Annual aggregation, MSA boundary changes, permit survey changes, and historical data revisions affect comparisons.
- Data are for research and descriptive analysis; results do not establish causation or provide forecasts.
