# Jupyter Notebooks — MIS581 Capstone

These are **sanitized copies** of the eight original research notebooks, not fresh executions.

## Workflow

1. `01_fhfa_exploration.ipynb` — FHFA index exploration.
2. `02_bls_exploration.ipynb` — BLS unemployment source examination.
3. `03_census_exploration_copy.ipynb` — ACS API proof of concept.
4. `04_building_permits_exploration.ipynb` — permit-data exploration.
5. `05_freddie_mac_exploration.ipynb` — Freddie Mac mortgage-rate source examination.
6. `06_census_historical_income.ipynb` — historical ACS data acquisition.
7. `07_building_permits_historical.ipynb` — historical permits preparation.
8. `08_postgresql_data_warehouse.ipynb` — PostgreSQL integration, analytical preparation, diagnostics, and final model workflows.

**Security and portability:** Original Windows absolute paths were replaced with relative paths, assuming notebooks live in `notebooks/` and local data is stored under `data/`. The data directory is not included in this package; place raw/processed datasets in the expected folders before executing. Census API access reads `CENSUS_API_KEY` from the environment where applicable. Database password prompts use `getpass`; use local PostgreSQL configuration.

**Provenance:** Saved successful outputs are retained; three saved historical error outputs were removed. Files were structurally parsed and scanned, but **not end-to-end rerun**. The copied notebooks should not be represented as independently reproducible without providing data/dependencies and validating execution on a fresh environment.
