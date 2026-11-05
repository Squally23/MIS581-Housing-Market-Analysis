-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- VERBATIM PG_GET_VIEWDEF SOURCE, WRAPPED IN CREATE OR REPLACE VIEW
-- Object: analytics.vw_housing_market_annual
-- Prerequisite: warehouse dimensions and fact tables must already exist.
-- This script has not been rerun; source definition was exported from the existing live view.

CREATE OR REPLACE VIEW analytics.vw_housing_market_annual AS
SELECT m.cbsa,
    m.metro_name,
    y.year,
    h.annual_hpi,
    h.hpi_annual_change_pct,
    p.permits_total,
    p.units_1,
    p.units_2,
    p.units_3_4,
    p.units_5_plus,
    p.structures_5_plus,
    l.unemployment_rate_annual,
    l.months_reported,
    r.mortgage_rate_30yr_annual,
    r.weeks_reported,
    d.population,
    d.median_household_income
   FROM warehouse.dim_metro m
     CROSS JOIN warehouse.dim_year y
     LEFT JOIN warehouse.fact_housing_annual h ON m.cbsa = h.cbsa AND y.year = h.year
     LEFT JOIN warehouse.fact_permits_annual p ON m.cbsa = p.cbsa AND y.year = p.year
     LEFT JOIN warehouse.fact_labor_annual l ON m.cbsa = l.cbsa AND y.year = l.year
     LEFT JOIN warehouse.fact_mortgage_annual r ON y.year = r.year
     LEFT JOIN warehouse.fact_demographics_annual d ON m.cbsa = d.cbsa AND y.year = d.year;
