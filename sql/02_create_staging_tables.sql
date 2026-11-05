-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- Python/Jupyter populates staging before running 04_load_warehouse_facts.sql.
-- See notebooks/ and README; these CREATE statements alone do not load data.
CREATE TABLE IF NOT EXISTS staging.building_permits (
 year INTEGER, cbsa VARCHAR(5), metro_name TEXT,
 permits_total INTEGER, units_1 INTEGER, units_2 INTEGER,
 units_3_4 INTEGER, units_5_plus INTEGER, structures_5_plus INTEGER
);

CREATE TABLE IF NOT EXISTS staging.fhfa_hpi_annual (
cbsa VARCHAR(5),year INTEGER,annual_hpi DOUBLE PRECISION,hpi_annual_change_pct DOUBLE PRECISION);

CREATE TABLE IF NOT EXISTS staging.bls_unemployment_annual (
cbsa VARCHAR(5),year INTEGER,unemployment_rate_annual DOUBLE PRECISION,months_reported INTEGER);

CREATE TABLE IF NOT EXISTS staging.freddie_mac_annual (
    year INTEGER,
    mortgage_rate_30yr_annual DOUBLE PRECISION,
    weeks_reported INTEGER
);

CREATE TABLE IF NOT EXISTS staging.census_acs_annual (
    cbsa VARCHAR(5),
    year INTEGER,
    metro TEXT,
    population BIGINT,
    median_household_income BIGINT
);
