-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- Previously created/populated with pgAdmin; DDL reproduced from executed work.
-- Populate using the 20-row CSV produced by Notebook 08:
-- data/processed/cpi_u_annual_2005_2024.csv
-- Header: year,cpi_annual,months_reported; load with pgAdmin Import/Export.
-- DO NOT duplicate an import into an already populated table.
-- This script intentionally does not hardcode 20 observed CPI values.
CREATE TABLE IF NOT EXISTS analytics.ref_cpi_annual (
 year INTEGER PRIMARY KEY,
 cpi_annual DOUBLE PRECISION NOT NULL,
 months_reported INTEGER NOT NULL,
 CONSTRAINT chk_cpi_positive CHECK (cpi_annual > 0),
 CONSTRAINT chk_cpi_months CHECK (months_reported BETWEEN 1 AND 12)
);
