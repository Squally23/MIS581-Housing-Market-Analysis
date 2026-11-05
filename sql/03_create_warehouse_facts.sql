-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- Primary / foreign keys and CHECK constraints mirror the archived executed DDL.
CREATE TABLE IF NOT EXISTS warehouse.fact_permits_annual (
 cbsa CHAR(5) NOT NULL, year INTEGER NOT NULL,
 permits_total INTEGER NOT NULL, units_1 INTEGER NOT NULL, units_2 INTEGER NOT NULL,
 units_3_4 INTEGER NOT NULL, units_5_plus INTEGER NOT NULL, structures_5_plus INTEGER NOT NULL,
 CONSTRAINT pk_fact_permits_annual PRIMARY KEY (cbsa,year),
 CONSTRAINT fk_permits_metro FOREIGN KEY (cbsa) REFERENCES warehouse.dim_metro(cbsa),
 CONSTRAINT fk_permits_year FOREIGN KEY (year) REFERENCES warehouse.dim_year(year),
 CONSTRAINT chk_permits_nonnegative CHECK (permits_total>=0 AND units_1>=0 AND units_2>=0
 AND units_3_4>=0 AND units_5_plus>=0 AND structures_5_plus>=0),
 CONSTRAINT chk_permits_total CHECK (permits_total=units_1+units_2+units_3_4+units_5_plus)
);

CREATE TABLE IF NOT EXISTS warehouse.fact_housing_annual (
cbsa CHAR(5) NOT NULL,year INTEGER NOT NULL,
annual_hpi DOUBLE PRECISION NOT NULL,hpi_annual_change_pct DOUBLE PRECISION NOT NULL,
CONSTRAINT pk_fact_housing_annual PRIMARY KEY(cbsa,year),
CONSTRAINT fk_housing_metro FOREIGN KEY(cbsa) REFERENCES warehouse.dim_metro(cbsa),
CONSTRAINT fk_housing_year FOREIGN KEY(year) REFERENCES warehouse.dim_year(year),
CONSTRAINT chk_housing_hpi_positive CHECK(annual_hpi>0 AND annual_hpi NOT IN
('NaN'::DOUBLE PRECISION,'Infinity'::DOUBLE PRECISION,'-Infinity'::DOUBLE PRECISION)),
CONSTRAINT chk_housing_growth_valid CHECK(hpi_annual_change_pct NOT IN
('NaN'::DOUBLE PRECISION,'Infinity'::DOUBLE PRECISION,'-Infinity'::DOUBLE PRECISION)));

CREATE TABLE IF NOT EXISTS warehouse.fact_labor_annual (
cbsa CHAR(5) NOT NULL,year INTEGER NOT NULL,
unemployment_rate_annual DOUBLE PRECISION NOT NULL,months_reported INTEGER NOT NULL,
CONSTRAINT pk_fact_labor_annual PRIMARY KEY(cbsa,year),
CONSTRAINT fk_labor_metro FOREIGN KEY(cbsa) REFERENCES warehouse.dim_metro(cbsa),
CONSTRAINT fk_labor_year FOREIGN KEY(year) REFERENCES warehouse.dim_year(year),
CONSTRAINT chk_labor_unemployment_rate CHECK(unemployment_rate_annual BETWEEN 0 AND 100
AND unemployment_rate_annual NOT IN ('NaN'::DOUBLE PRECISION,'Infinity'::DOUBLE PRECISION,'-Infinity'::DOUBLE PRECISION)),
CONSTRAINT chk_labor_months_reported CHECK(months_reported BETWEEN 1 AND 12));

CREATE TABLE IF NOT EXISTS warehouse.fact_mortgage_annual (
    year INTEGER NOT NULL,
    mortgage_rate_30yr_annual DOUBLE PRECISION NOT NULL,
    weeks_reported INTEGER NOT NULL,
    CONSTRAINT pk_fact_mortgage_annual PRIMARY KEY (year),
    CONSTRAINT fk_mortgage_year FOREIGN KEY (year)
        REFERENCES warehouse.dim_year(year),
    CONSTRAINT chk_mortgage_rate_valid CHECK (
        mortgage_rate_30yr_annual BETWEEN 0 AND 100
        AND mortgage_rate_30yr_annual NOT IN (
            'NaN'::DOUBLE PRECISION,
            'Infinity'::DOUBLE PRECISION,
            '-Infinity'::DOUBLE PRECISION
        )
    ),
    CONSTRAINT chk_mortgage_weeks_reported
        CHECK (weeks_reported BETWEEN 52 AND 53)
);

CREATE TABLE IF NOT EXISTS warehouse.fact_demographics_annual (
    cbsa CHAR(5) NOT NULL,
    year INTEGER NOT NULL,
    population BIGINT NOT NULL,
    median_household_income BIGINT NOT NULL,
    CONSTRAINT pk_fact_demographics_annual PRIMARY KEY (cbsa, year),
    CONSTRAINT fk_demographics_metro FOREIGN KEY (cbsa)
        REFERENCES warehouse.dim_metro(cbsa),
    CONSTRAINT fk_demographics_year FOREIGN KEY (year)
        REFERENCES warehouse.dim_year(year),
    CONSTRAINT chk_demographics_population CHECK (population > 0),
    CONSTRAINT chk_demographics_income CHECK (median_household_income > 0)
);
