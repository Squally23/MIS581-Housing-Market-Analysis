-- MIS581 Housing Market Analysis | PostgreSQL 18.x
-- Source provenance: executed step archives / exported live view definitions.
-- Use an empty, dedicated capstone database for a clean setup.

-- ORIGINAL execution: database created in pgAdmin GUI. Connect to it first.
-- No CREATE DATABASE command is included.
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS warehouse;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS warehouse.dim_metro (
    cbsa CHAR(5) PRIMARY KEY,
    metro_name VARCHAR(150) NOT NULL
);

INSERT INTO warehouse.dim_metro (cbsa, metro_name) VALUES
('16700','Charleston-North Charleston, SC'),
('19100','Dallas-Fort Worth-Arlington, TX'),
('28140','Kansas City, MO-KS'),
('29820','Las Vegas-Henderson-Paradise, NV'),
('34980','Nashville-Davidson--Murfreesboro--Franklin, TN'),
('35620','New York-Newark-Jersey City, NY-NJ-PA'),
('41860','San Francisco-Oakland-Berkeley, CA')
ON CONFLICT (cbsa) DO NOTHING;

CREATE TABLE IF NOT EXISTS warehouse.dim_year (
    year INTEGER PRIMARY KEY CHECK (year BETWEEN 2005 AND 2024)
);

INSERT INTO warehouse.dim_year (year)
SELECT generate_series(2005, 2024)
ON CONFLICT (year) DO NOTHING;
