-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- VERBATIM PG_GET_VIEWDEF SOURCE, WRAPPED IN CREATE OR REPLACE VIEW
-- Object: analytics.vw_tableau_housing_market
-- Prerequisite: analytics.vw_housing_market_annual and populated analytics.ref_cpi_annual are required.
-- This script has not been rerun; source definition was exported from the existing live view.

CREATE OR REPLACE VIEW analytics.vw_tableau_housing_market AS
WITH base_data AS (
         SELECT h.cbsa,
            h.metro_name,
            h.year,
            h.annual_hpi,
            h.hpi_annual_change_pct,
            h.permits_total,
            h.units_1,
            h.units_2,
            h.units_3_4,
            h.units_5_plus,
            h.structures_5_plus,
            h.unemployment_rate_annual,
            h.months_reported,
            h.mortgage_rate_30yr_annual,
            h.weeks_reported,
            h.population,
            h.median_household_income,
            c.cpi_annual,
                CASE
                    WHEN h.median_household_income IS NOT NULL AND c.cpi_annual > 0::double precision THEN h.median_household_income::double precision * (313.688833333333::double precision / c.cpi_annual)
                    ELSE NULL::double precision
                END AS real_median_household_income,
                CASE
                    WHEN h.population > 0 THEN h.permits_total::numeric * 1000.0 / h.population::numeric
                    ELSE NULL::numeric
                END AS permits_per_1000
           FROM analytics.vw_housing_market_annual h
             LEFT JOIN analytics.ref_cpi_annual c ON h.year = c.year
        ), income_growth AS (
         SELECT b.cbsa,
            b.metro_name,
            b.year,
            b.annual_hpi,
            b.hpi_annual_change_pct,
            b.permits_total,
            b.units_1,
            b.units_2,
            b.units_3_4,
            b.units_5_plus,
            b.structures_5_plus,
            b.unemployment_rate_annual,
            b.months_reported,
            b.mortgage_rate_30yr_annual,
            b.weeks_reported,
            b.population,
            b.median_household_income,
            b.cpi_annual,
            b.real_median_household_income,
            b.permits_per_1000,
            lag(b.real_median_household_income) OVER (PARTITION BY b.cbsa ORDER BY b.year) AS previous_real_income,
            lag(b.year) OVER (PARTITION BY b.cbsa ORDER BY b.year) AS previous_year
           FROM base_data b
        )
 SELECT cbsa,
    metro_name,
    year,
    annual_hpi,
    hpi_annual_change_pct,
    permits_total,
    units_1,
    units_2,
    units_3_4,
    units_5_plus,
    structures_5_plus,
    unemployment_rate_annual,
    months_reported,
    mortgage_rate_30yr_annual,
    weeks_reported,
    population,
    median_household_income,
    cpi_annual,
    real_median_household_income,
    permits_per_1000,
        CASE
            WHEN previous_year = (year - 1) AND previous_real_income > 0::double precision AND real_median_household_income IS NOT NULL THEN (real_median_household_income / previous_real_income - 1::double precision) * 100.0::double precision
            ELSE NULL::double precision
        END AS real_income_growth_pct
   FROM income_growth;
