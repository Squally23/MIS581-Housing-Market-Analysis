-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- IMPORTANT: run only AFTER the five staging tables have been populated and validated
-- by the Python/Notebook 08 workflow. Upserts are intentional; they overwrite matching
-- keys with the current staged values. These commands do not ingest raw source files.
-- Previously executed in pgAdmin; consolidated order here is newly curated.
-- Residential units authorized
INSERT INTO warehouse.fact_permits_annual (cbsa,year,permits_total,units_1,units_2,units_3_4,units_5_plus,structures_5_plus)
SELECT cbsa,year,permits_total,units_1,units_2,units_3_4,units_5_plus,structures_5_plus
FROM staging.building_permits
ON CONFLICT (cbsa,year) DO UPDATE SET
permits_total=EXCLUDED.permits_total,units_1=EXCLUDED.units_1,units_2=EXCLUDED.units_2,
units_3_4=EXCLUDED.units_3_4,units_5_plus=EXCLUDED.units_5_plus,structures_5_plus=EXCLUDED.structures_5_plus;

-- FHFA HPI
INSERT INTO warehouse.fact_housing_annual(cbsa,year,annual_hpi,hpi_annual_change_pct)
SELECT cbsa,year,annual_hpi,hpi_annual_change_pct FROM staging.fhfa_hpi_annual
ON CONFLICT(cbsa,year) DO UPDATE SET annual_hpi=EXCLUDED.annual_hpi,
hpi_annual_change_pct=EXCLUDED.hpi_annual_change_pct;

-- BLS unemployment
INSERT INTO warehouse.fact_labor_annual(cbsa,year,unemployment_rate_annual,months_reported)
SELECT cbsa,year,unemployment_rate_annual,months_reported FROM staging.bls_unemployment_annual
ON CONFLICT(cbsa,year) DO UPDATE SET unemployment_rate_annual=EXCLUDED.unemployment_rate_annual,
months_reported=EXCLUDED.months_reported;

-- Freddie Mac national mortgage rates
INSERT INTO warehouse.fact_mortgage_annual (
    year, mortgage_rate_30yr_annual, weeks_reported
)
SELECT year, mortgage_rate_30yr_annual, weeks_reported
FROM staging.freddie_mac_annual
ON CONFLICT (year)
DO UPDATE SET
    mortgage_rate_30yr_annual = EXCLUDED.mortgage_rate_30yr_annual,
    weeks_reported = EXCLUDED.weeks_reported;

-- Census ACS population and income
INSERT INTO warehouse.fact_demographics_annual (
    cbsa, year, population, median_household_income
)
SELECT cbsa, year, population, median_household_income
FROM staging.census_acs_annual
ON CONFLICT (cbsa, year)
DO UPDATE SET
    population = EXCLUDED.population,
    median_household_income = EXCLUDED.median_household_income;
