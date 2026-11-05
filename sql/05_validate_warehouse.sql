-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- READ ONLY: compare expected row counts and completeness after load.
WITH expected(object_name, expected_rows) AS (
 VALUES ('fact_permits_annual', 140), ('fact_housing_annual', 140),
 ('fact_labor_annual',140), ('fact_mortgage_annual',20),
 ('fact_demographics_annual',133)
), observed AS (
 SELECT 'fact_permits_annual' AS object_name, COUNT(*) AS actual_rows FROM warehouse.fact_permits_annual
 UNION ALL SELECT 'fact_housing_annual', COUNT(*) FROM warehouse.fact_housing_annual
 UNION ALL SELECT 'fact_labor_annual', COUNT(*) FROM warehouse.fact_labor_annual
 UNION ALL SELECT 'fact_mortgage_annual', COUNT(*) FROM warehouse.fact_mortgage_annual
 UNION ALL SELECT 'fact_demographics_annual', COUNT(*) FROM warehouse.fact_demographics_annual
)
SELECT e.object_name, e.expected_rows, o.actual_rows,
 (e.expected_rows = o.actual_rows) AS count_matches
FROM expected e JOIN observed o USING (object_name)
ORDER BY e.object_name;

-- Source-to-fact transfers were independently checked in the development archives.
-- This query is a consolidated publication check, not proof of source accuracy.
SELECT
 (SELECT COUNT(*) FROM warehouse.dim_metro) AS metro_count,
 (SELECT COUNT(*) FROM warehouse.dim_year) AS year_count,
 (SELECT COUNT(*) FROM warehouse.fact_demographics_annual WHERE year = 2020) AS acs_2020_rows,
 (SELECT COUNT(*) FROM warehouse.fact_permits_annual
   WHERE permits_total IS DISTINCT FROM units_1 + units_2 + units_3_4 + units_5_plus) AS permit_arithmetic_mismatches;

-- Targeted staging-to-fact reconciliation using NULL-safe comparisons.
SELECT COUNT(*) AS staged_rows, COUNT(w.cbsa) AS matched_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NULL) AS missing_fact_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NOT NULL AND
   (s.permits_total IS DISTINCT FROM w.permits_total OR
    s.units_1 IS DISTINCT FROM w.units_1 OR
    s.units_2 IS DISTINCT FROM w.units_2 OR
    s.units_3_4 IS DISTINCT FROM w.units_3_4 OR
    s.units_5_plus IS DISTINCT FROM w.units_5_plus OR
    s.structures_5_plus IS DISTINCT FROM w.structures_5_plus)) AS mismatches
FROM staging.building_permits s LEFT JOIN warehouse.fact_permits_annual w
ON s.cbsa=w.cbsa AND s.year=w.year;

SELECT COUNT(*) AS staged_rows, COUNT(w.cbsa) AS matched_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NULL) AS missing_fact_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NOT NULL AND
    (s.annual_hpi IS DISTINCT FROM w.annual_hpi OR
     s.hpi_annual_change_pct IS DISTINCT FROM w.hpi_annual_change_pct)) AS mismatches
FROM staging.fhfa_hpi_annual s LEFT JOIN warehouse.fact_housing_annual w
ON s.cbsa=w.cbsa AND s.year=w.year;

SELECT COUNT(*) AS staged_rows, COUNT(w.cbsa) AS matched_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NULL) AS missing_fact_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NOT NULL AND
    (s.unemployment_rate_annual IS DISTINCT FROM w.unemployment_rate_annual OR
     s.months_reported IS DISTINCT FROM w.months_reported)) AS mismatches
FROM staging.bls_unemployment_annual s LEFT JOIN warehouse.fact_labor_annual w
ON s.cbsa=w.cbsa AND s.year=w.year;

SELECT COUNT(*) AS staged_rows, COUNT(w.year) AS matched_rows,
 COUNT(*) FILTER (WHERE w.year IS NULL) AS missing_fact_rows,
 COUNT(*) FILTER (WHERE w.year IS NOT NULL AND
    (s.mortgage_rate_30yr_annual IS DISTINCT FROM w.mortgage_rate_30yr_annual OR
     s.weeks_reported IS DISTINCT FROM w.weeks_reported)) AS mismatches
FROM staging.freddie_mac_annual s LEFT JOIN warehouse.fact_mortgage_annual w
ON s.year=w.year;

SELECT COUNT(*) AS staged_rows, COUNT(w.cbsa) AS matched_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NULL) AS missing_fact_rows,
 COUNT(*) FILTER (WHERE w.cbsa IS NOT NULL AND
    (s.population IS DISTINCT FROM w.population OR
     s.median_household_income IS DISTINCT FROM w.median_household_income)) AS mismatches
FROM staging.census_acs_annual s LEFT JOIN warehouse.fact_demographics_annual w
ON s.cbsa=w.cbsa AND s.year=w.year;
