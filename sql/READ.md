# MIS581 Capstone — PostgreSQL Scripts

**Scope:** seven U.S. metropolitan statistical areas × 2005–2024 (140 metropolitan-year records). PostgreSQL 18.x.

This directory documents the SQL portion of an executed Python → PostgreSQL → Tableau workflow. **These are curated publication copies, not newly rerun migrations.** `06` and `08` contain view SQL recovered from the working database using `pg_get_viewdef`, wrapped in `CREATE OR REPLACE VIEW`. Table DDL and upserts are consolidated from user-confirmed executed development archives. The consolidated package has been statically checked but has **not been executed as an end-to-end installation**.

## Files and execution order

| File | Responsibility | Prerequisite |
|---|---|---|
| `01_create_schemas_dimensions.sql` | Set up schemas, 7 metros, 20 years | Empty dedicated database, connected through pgAdmin |
| `02_create_staging_tables.sql` | Define five source-specific staging tables | `01` |
| `03_create_warehouse_facts.sql` | Define fact tables and constraints | `01` |
| **Python / Notebook 08** | **Load processed annual CSVs into staging** | `02`; external to this SQL package |
| `04_load_warehouse_facts.sql` | Upsert validated staging records into facts | Populated and checked staging tables, `03` |
| `05_validate_warehouse.sql` | Counts and source/fact reconciliation (read only) | `04` |
| `06_create_analytical_view.sql` | Integrated 17-column annual panel | `03`, populated facts |
| `07_create_cpi_reference.sql` | Create annual CPI-U reference table | `01`; then **import CPI CSV** |
| **pgAdmin CSV import** | **Load 20 annual CPI records** into `analytics.ref_cpi_annual` | `07`; CSV from Notebook 08 |
| `08_create_tableau_view.sql` | Tableau 21-column reporting view | `06`, populated CPI table |
| `09_validate_tableau_view.sql` | Row counts, missingness and source matching (read only) | `08` |

**Do not execute everything against the existing populated research database.** Re-running staged upserts changes matching fact rows; `CREATE OR REPLACE VIEW` may alter deployed view definitions. The scripts are intended as a readable reproduction guide for a new database or as selectively executed maintenance code.

## Expected stored records

- `warehouse.fact_housing_annual`: 140; `warehouse.fact_permits_annual`: 140; `warehouse.fact_labor_annual`: 140.
- `warehouse.fact_mortgage_annual`: 20 (national yearly grain, not MSA-year grain).
- `warehouse.fact_demographics_annual`: 133 (ACS one-year values missing for 2020).
- Integrated analytical view: 140 MSA-year rows, with 7 missing ACS population/income records in 2020.
- Tableau view: 140 rows; missing population / real income / normalized permits = 7 each; missing real-income growth = 21 (2005, 2020, 2021 across all seven MSAs).

## Source and measurement cautions

- FHFA outcome: annual percentage change in *all-transactions HPI*, **not median sale price**. Annual HPI is averaged from four quarterly values; 2004 is used as the growth baseline for 2005.
- `permits_total` means **authorized residential housing units**, not permit documents, completed homes, or existing inventory.
- Freddie Mac rate is a **national annual mean of weekly 30-year fixed rates**. It varies by year and is not an independent MSA-level series.
- Household income in the warehouse is **nominal**; the Tableau view expresses it in **constant 2024 dollars** using CPI-U. It retains the observed 2024 CPI constant `313.688833333333` from the working view. The CPI dataset is derived from the FRED CPIAUCNS/BLS series.
- 2020 standard ACS one-year income/population estimates were unavailable. Missing observations are intentionally **not interpolated**. Real-income growth is only calculated from consecutive years.
- Geographic definitions and permit reporting universes changed over time; longitudinal measurement consistency is a limitation.
- These SQL scripts document data preparation and descriptive reporting. Regression modeling and HC3 sensitivity checks were performed in Python, not SQL.

## Reproducibility, privacy, and provenance

- Python loads the five processed annual source tables to `staging` via SQLAlchemy and a password prompt; the SQL archives do **not** contain that Python logic. Add and verify the sanitized source notebooks before claiming end-to-end reproducibility.
- The 20-row CPI reference CSV must be supplied separately; this SQL package intentionally omits hardcoded values.
- Keep the original SQL step archives and handoffs **private**. Do not publish database passwords, API keys, local connection strings, sensitive paths, or execution outputs containing secrets.
- The two view definitions were pulled from the user's working PostgreSQL database, not invented. The published scripts are reformatted, archived, and **not newly executed** in this environment.
- Source access, exact software dependencies and redistribution rights should be documented in the repository root README when those pieces are reviewed.
