-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- READ ONLY; execute after loading CPI and creating both views.
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT cbsa) AS metro_count,
 COUNT(DISTINCT year) AS year_count,
 COUNT(DISTINCT (cbsa,year)) AS unique_metro_years,
 COUNT(*) FILTER (WHERE population IS NULL) AS missing_population,
 COUNT(*) FILTER (WHERE real_median_household_income IS NULL) AS missing_real_income,
 COUNT(*) FILTER (WHERE permits_per_1000 IS NULL) AS missing_permits_per_1000,
 COUNT(*) FILTER (WHERE real_income_growth_pct IS NULL) AS missing_income_growth
FROM analytics.vw_tableau_housing_market;
-- Expected: 140,7,20,140,7,7,7,21.

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT year) AS unique_years,
 MIN(year) AS first_year, MAX(year) AS last_year,
 COUNT(*) FILTER (WHERE months_reported <> 12) AS incomplete_years,
 COUNT(*) FILTER (WHERE cpi_annual IS NULL) AS missing_cpi
FROM analytics.ref_cpi_annual;
-- Expected: 20,20,2005,2024,0,0.

SELECT year, cpi_annual, ROUND(cpi_annual::numeric,3) AS cpi_rounded
FROM analytics.ref_cpi_annual WHERE year=2024;
-- Expected rounded 313.689 (source annual average stored at full precision).

-- Source/view consistency checks, grouped by source family.
SELECT COUNT(*) AS view_rows,
 COUNT(*) FILTER (WHERE v.annual_hpi IS DISTINCT FROM h.annual_hpi OR v.hpi_annual_change_pct IS DISTINCT FROM h.hpi_annual_change_pct) AS hpi_mismatches,
 COUNT(*) FILTER (WHERE v.permits_total IS DISTINCT FROM p.permits_total) AS permits_mismatches,
 COUNT(*) FILTER (WHERE v.unemployment_rate_annual IS DISTINCT FROM l.unemployment_rate_annual) AS labor_mismatches,
 COUNT(*) FILTER (WHERE v.mortgage_rate_30yr_annual IS DISTINCT FROM r.mortgage_rate_30yr_annual) AS mortgage_mismatches,
 COUNT(*) FILTER (WHERE v.population IS DISTINCT FROM d.population OR v.median_household_income IS DISTINCT FROM d.median_household_income) AS demographics_mismatches
FROM analytics.vw_housing_market_annual v
LEFT JOIN warehouse.fact_housing_annual h ON h.cbsa=v.cbsa AND h.year=v.year
LEFT JOIN warehouse.fact_permits_annual p ON p.cbsa=v.cbsa AND p.year=v.year
LEFT JOIN warehouse.fact_labor_annual l ON l.cbsa=v.cbsa AND l.year=v.year
LEFT JOIN warehouse.fact_mortgage_annual r ON r.year=v.year
LEFT JOIN warehouse.fact_demographics_annual d ON d.cbsa=v.cbsa AND d.year=v.year;
-- Expected: 140 rows, zero mismatches in every category.

-- Targeted Charleston calculation sample previously reconciled with Python
-- at displayed precision (7 years x 3 measures); a full 140-row cross-system
-- numeric comparison was NOT completed.
SELECT cbsa, year,
 ROUND(permits_per_1000::numeric,4) AS permits_per_1000,
 ROUND(real_median_household_income::numeric,2) AS real_income_2024_usd,
 ROUND(real_income_growth_pct::numeric,4) AS real_income_growth_pct
FROM analytics.vw_tableau_housing_market
WHERE cbsa='16700' AND year IN (2005,2006,2019,2020,2021,2022,2024)
ORDER BY year;
