-- P1 – THE DATA ARCHITECT



/* SECTION A – EXTRACT & INSPECT*/


/* 1. CREATE STAGING TABLES */
 

DROP TABLE IF EXISTS covid_19_india_staging;

CREATE TABLE covid_19_india_staging (
    sno TEXT,
    date TEXT,
    time TEXT,
    state_unionterritory TEXT,
    confirmedindiannational TEXT,
    confirmedforeignnational TEXT,
    cured TEXT,
    deaths TEXT,
    confirmed TEXT
);

DROP TABLE IF EXISTS covid_vaccine_statewise_staging;

CREATE TABLE covid_vaccine_statewise_staging (
    updated_on TEXT,
    state TEXT,
    total_doses_administered TEXT,
    sessions TEXT,
    sites TEXT,
    first_dose_administered TEXT,
    second_dose_administered TEXT,
    male_doses_administered TEXT,
    female_doses_administered TEXT,
    transgender_doses_administered TEXT,
    covaxin_doses TEXT,
    covishield_doses TEXT,
    sputnik_v_doses TEXT,
    aefi TEXT,
    dose_18_44 TEXT,
    dose_45_60 TEXT,
    dose_60_plus TEXT,
    ind_18_44 TEXT,
    ind_45_60 TEXT,
    ind_60_plus TEXT,
    male_ind TEXT,
    female_ind TEXT,
    transgender_ind TEXT,
    total_individuals_vaccinated TEXT
);

DROP TABLE IF EXISTS statewisetestingdetails_staging;

CREATE TABLE statewisetestingdetails_staging (
    date TEXT,
    state TEXT,
    totalsamples TEXT,
    negative TEXT,
    positive TEXT
);


/*2. CREATE FINAL PRODUCTION TABLES*/

DROP TABLE IF EXISTS covid_19_india;

CREATE TABLE covid_19_india (
    sno INT,
    date DATE,
    time VARCHAR(20),
    state_unionterritory VARCHAR(100),
    confirmedindiannational INT,
    confirmedforeignnational INT,
    cured INT,
    deaths INT,
    confirmed INT
);

DROP TABLE IF EXISTS covid_vaccine_statewise;

CREATE TABLE covid_vaccine_statewise (
    updated_on DATE,
    state VARCHAR(100),
    total_doses_administered BIGINT,
    sessions BIGINT,
    sites BIGINT,
    first_dose_administered BIGINT,
    second_dose_administered BIGINT,
    total_individuals_vaccinated BIGINT
);

DROP TABLE IF EXISTS statewisetestingdetails;

CREATE TABLE statewisetestingdetails (
    date DATE,
    state VARCHAR(100),
    totalsamples BIGINT,
    negative BIGINT,
    positive BIGINT
);


/*3. LOAD DATA FROM STAGING → FINAL TABLES*/

-- Cases Table
INSERT INTO covid_19_india
SELECT
    NULLIF(sno,'')::INT,
    CASE 
        WHEN date LIKE '%/%' THEN TO_DATE(date,'MM/DD/YYYY')
        WHEN date LIKE '%-%' THEN date::DATE
        ELSE NULL
    END,
    time,
    TRIM(state_unionterritory),
    NULLIF(NULLIF(confirmedindiannational,'-'),'')::INT,
    NULLIF(NULLIF(confirmedforeignnational,'-'),'')::INT,
    NULLIF(NULLIF(cured,'-'),'')::INT,
    NULLIF(NULLIF(deaths,'-'),'')::INT,
    NULLIF(NULLIF(confirmed,'-'),'')::INT
FROM covid_19_india_staging;


-- Testing Table
INSERT INTO statewisetestingdetails
SELECT
    CASE 
        WHEN date LIKE '%/%' THEN TO_DATE(date,'MM/DD/YYYY')
        WHEN date LIKE '%-%' THEN date::DATE
        ELSE NULL
    END,
    TRIM(state),
    NULLIF(NULLIF(TRIM(totalsamples),'-'),'')::NUMERIC::BIGINT,
    NULLIF(NULLIF(TRIM(negative),'-'),'')::NUMERIC::BIGINT,
    NULLIF(NULLIF(TRIM(positive),'-'),'')::NUMERIC::BIGINT
FROM statewisetestingdetails_staging;


-- Vaccine Table
INSERT INTO covid_vaccine_statewise
SELECT
    CASE 
        WHEN updated_on LIKE '%/%' 
            THEN TO_DATE(updated_on,'DD/MM/YYYY')
        WHEN updated_on LIKE '%-%' 
            THEN updated_on::DATE
        ELSE NULL
    END,
    TRIM(state),
    NULLIF(NULLIF(TRIM(total_doses_administered),'-'),'')::NUMERIC::BIGINT,
    NULLIF(NULLIF(TRIM(first_dose_administered),'-'),'')::NUMERIC::BIGINT,
    NULLIF(NULLIF(TRIM(second_dose_administered),'-'),'')::NUMERIC::BIGINT
FROM covid_vaccine_statewise_staging;


/*4. VALIDATE RECORD COUNTS*/

SELECT 
    (SELECT COUNT(*) FROM covid_19_india) AS cases_count,
    (SELECT COUNT(*) FROM statewisetestingdetails) AS testing_count,
    (SELECT COUNT(*) FROM covid_vaccine_statewise) AS vaccine_count;


SELECT COUNT(*) AS cases_count FROM covid_19_india;
SELECT COUNT(*) AS testing_count FROM statewisetestingdetails;
SELECT COUNT(*) AS vaccine_count FROM covid_vaccine_statewise;


/*5. PREVIEW SAMPLE RECORDS*/

SELECT * FROM covid_19_india LIMIT 10;
SELECT * FROM statewisetestingdetails LIMIT 10;
SELECT * FROM covid_vaccine_statewise LIMIT 10;


/*6. DATA QUALITY CHECK – STATE CONSISTENCY*/

SELECT DISTINCT state_unionterritory FROM covid_19_india ORDER BY state_unionterritory;
SELECT DISTINCT state FROM statewisetestingdetails ORDER BY state;
SELECT DISTINCT state FROM covid_vaccine_statewise ORDER BY state;



/*7. STANDARDIZE STATE NAMES*/

UPDATE covid_19_india
SET state_unionterritory = 'Karnataka'
WHERE state_unionterritory = 'Karanataka';

UPDATE covid_19_india
SET state_unionterritory = 'Himachal Pradesh'
WHERE state_unionterritory = 'Himanchal Pradesh';

UPDATE covid_19_india
SET state_unionterritory = 'Telangana'
WHERE state_unionterritory = 'Telengana';

UPDATE covid_19_india
SET state_unionterritory = 'Bihar'
WHERE state_unionterritory LIKE 'Bihar%';

UPDATE covid_19_india
SET state_unionterritory = 'Madhya Pradesh'
WHERE state_unionterritory LIKE 'Madhya Pradesh%';

UPDATE covid_19_india
SET state_unionterritory = 'Maharashtra'
WHERE state_unionterritory LIKE 'Maharashtra%';

UPDATE covid_19_india
SET state_unionterritory = 'Dadra and Nagar Haveli and Daman and Diu'
WHERE state_unionterritory IN ('Dadra and Nagar Haveli','Daman & Diu');

DELETE FROM covid_19_india
WHERE state_unionterritory IN 
('Cases being reassigned to states','Unassigned');

DELETE FROM covid_vaccine_statewise
WHERE state = 'India';

SELECT date FROM covid_19_india LIMIT 10;


/*8. NULL CHECK – CRITICAL COLUMNS*/

SELECT 
    (SELECT COUNT(*) FILTER (WHERE confirmed IS NULL) 
     FROM covid_19_india) AS null_confirmed,

    (SELECT COUNT(*) FILTER (WHERE deaths IS NULL) 
     FROM covid_19_india) AS null_deaths,

    (SELECT COUNT(*) FILTER (WHERE totalsamples IS NULL) 
     FROM statewisetestingdetails) AS null_totalsamples;

    /*(SELECT COUNT(*) FILTER (WHERE total_doses_administered IS NULL) 
     FROM covid_vaccine_statewise) AS null_total_doses*/






/*9. MISSING DATA PATTERN ANALYSIS*/

SELECT 
    state,
    COUNT(*) AS null_rows,
    MIN(updated_on) AS first_null_date,
    MAX(updated_on) AS last_null_date
FROM covid_vaccine_statewise
WHERE total_doses_administered IS NULL
GROUP BY state
ORDER BY null_rows DESC;


SELECT state, COUNT(*) AS null_rows
FROM covid_vaccine_statewise
WHERE total_doses_administered IS NULL
GROUP BY state
ORDER BY null_rows DESC;

SELECT MIN(updated_on), MAX(updated_on)
FROM covid_vaccine_statewise
WHERE total_doses_administered IS NULL;


-- Preview cases
SELECT * FROM covid_19_india LIMIT 10;

-- Preview testing data
SELECT * FROM statewisetestingdetails LIMIT 10;

-- Preview vaccine data
SELECT * FROM covid_vaccine_statewise LIMIT 10;

-- P2: The Logic Engineer (SQL Transformation)
-- Drop intermediate tables
DROP TABLE IF EXISTS covid_summary_base;
DROP TABLE IF EXISTS covid_summary_with_testing;
DROP TABLE IF EXISTS covid_summary_with_vaccine;

-- Drop final table
DROP TABLE IF EXISTS covid_summary_final;


-- STEP 1: Create base table with unified confirmed and daily new cases
WITH cases_combined AS (
    SELECT
        state_unionterritory AS state,
        date,
        confirmedindiannational + confirmedforeignnational AS total_confirmed,
        confirmed,
        deaths,
        cured
    FROM covid_19_india
),
daily_cases AS (
    SELECT
        state,
        date,
        confirmed,
        deaths,
        cured,
        total_confirmed,
        -- Daily new cases = today's confirmed - yesterday's confirmed
        confirmed - LAG(confirmed, 1, 0) OVER (PARTITION BY state ORDER BY date) AS daily_new_cases
    FROM cases_combined
)
SELECT *
INTO covid_summary_base
FROM daily_cases;

SELECT * 
FROM covid_summary_base
ORDER BY state, date
LIMIT 50;

-- STEP 2: Join with testing data (forward-fill missing values)

WITH summary_with_testing AS (
    SELECT
        c.state,
        c.date,
        c.confirmed,
        c.deaths,
        c.cured,
        c.daily_new_cases,
        -- Forward-fill totalsamples and positive using MAX over range
        MAX(t.totalsamples) OVER (PARTITION BY c.state ORDER BY c.date
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS totalsamples,
        MAX(t.positive) OVER (PARTITION BY c.state ORDER BY c.date
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS positive,
        -- Positivity rate
        CASE 
            WHEN MAX(t.totalsamples) OVER (PARTITION BY c.state ORDER BY c.date
                                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 0 THEN 0
            ELSE (MAX(t.positive) OVER (PARTITION BY c.state ORDER BY c.date
                                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::NUMERIC
                  / MAX(t.totalsamples) OVER (PARTITION BY c.state ORDER BY c.date
                                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)::NUMERIC) * 100
        END AS positive_test_rate
    FROM covid_summary_base c
    LEFT JOIN statewisetestingdetails t
    ON c.state = t.state AND c.date = t.date
)
SELECT *
INTO covid_summary_with_testing
FROM summary_with_testing;

SELECT *
FROM covid_summary_with_testing
ORDER BY state, date
LIMIT 50;

SELECT 
    state,
    date,
    positive,
    totalsamples,
    positive_test_rate
FROM covid_summary_with_testing
ORDER BY state, date
LIMIT 50;



-- STEP 3: Join with vaccine data and compute Vaccination Rate (forward-fill)
-- STEP 3: Join with vaccine data and compute Vaccination Rate (forward-fill)

WITH state_population AS (
    SELECT 'Andhra Pradesh' AS state, 49577103 AS population UNION ALL
    SELECT 'Arunachal Pradesh', 1504000 UNION ALL
    SELECT 'Assam', 35607039 UNION ALL
    SELECT 'Bihar', 124799926 UNION ALL
    SELECT 'Chhattisgarh', 29436231 UNION ALL
    SELECT 'Goa', 1586250 UNION ALL
    SELECT 'Gujarat', 67936000 UNION ALL
    SELECT 'Haryana', 29260000 UNION ALL
    SELECT 'Himachal Pradesh', 7400000 UNION ALL
    SELECT 'Jharkhand', 38593948 UNION ALL
    SELECT 'Karnataka', 69144000 UNION ALL
    SELECT 'Kerala', 35699443 UNION ALL
    SELECT 'Madhya Pradesh', 85358965 UNION ALL
    SELECT 'Maharashtra', 123144223 UNION ALL
    SELECT 'Manipur', 3070000 UNION ALL
    SELECT 'Meghalaya', 3366710 UNION ALL
    SELECT 'Mizoram', 1239244 UNION ALL
    SELECT 'Nagaland', 2249695 UNION ALL
    SELECT 'Odisha', 46356334 UNION ALL
    SELECT 'Punjab', 30141373 UNION ALL
    SELECT 'Rajasthan', 81032689 UNION ALL
    SELECT 'Sikkim', 690251 UNION ALL
    SELECT 'Tamil Nadu', 77841267 UNION ALL
    SELECT 'Telangana', 35003674 UNION ALL
    SELECT 'Tripura', 4169794 UNION ALL
    SELECT 'Uttar Pradesh', 241066874 UNION ALL
    SELECT 'Uttarakhand', 11840895 UNION ALL
    SELECT 'West Bengal', 99609303 UNION ALL
    SELECT 'Andaman and Nicobar Islands', 380581 UNION ALL
    SELECT 'Chandigarh', 1158473 UNION ALL
    SELECT 'Dadra and Nagar Haveli and Daman and Diu', 586956 UNION ALL
    SELECT 'Delhi', 19814000 UNION ALL
    SELECT 'Jammu and Kashmir', 13800000 UNION ALL
    SELECT 'Ladakh', 293000 UNION ALL
    SELECT 'Lakshadweep', 64473 UNION ALL
    SELECT 'Puducherry', 1413542   -- ✅ Added here
)

SELECT
    s.*,
    MAX(v.total_doses_administered) OVER (
        PARTITION BY s.state 
        ORDER BY s.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS total_doses_administered,

    p.population,

    CASE 
        WHEN p.population IS NULL THEN 0
        ELSE (
            MAX(v.total_doses_administered) OVER (
                PARTITION BY s.state 
                ORDER BY s.date
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )::NUMERIC
            / p.population::NUMERIC
        ) * 100
    END AS vaccination_rate

INTO covid_summary_with_vaccine

FROM covid_summary_with_testing s
LEFT JOIN covid_vaccine_statewise v
    ON s.state = v.state 
   AND s.date = v.updated_on
LEFT JOIN state_population p
    ON s.state = p.state
ORDER BY s.state, s.date;

SELECT 
    state,
    date,
    total_doses_administered,
    population,
    vaccination_rate
FROM covid_summary_with_vaccine
ORDER BY state, date;


-- STEP 4: Calculate Case Fatality Rate and Risk Level

SELECT
    *,
    -- Case Fatality Rate (%) – safe from division by zero
    CASE 
        WHEN confirmed IS NULL OR confirmed = 0 THEN 0
        ELSE (deaths::NUMERIC / confirmed::NUMERIC) * 100
    END AS case_fatality_rate,
    
    -- Risk Level Classification
    CASE 
        WHEN (confirmed IS NOT NULL AND confirmed <> 0 AND (deaths::NUMERIC / confirmed::NUMERIC) * 100 > 2)
             AND (positive_test_rate IS NOT NULL AND positive_test_rate > 10) THEN 'High Risk'
        WHEN (confirmed IS NOT NULL AND confirmed <> 0 AND (deaths::NUMERIC / confirmed::NUMERIC) * 100 > 2)
             OR (positive_test_rate IS NOT NULL AND positive_test_rate > 10) THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
INTO covid_summary_final
FROM covid_summary_with_vaccine
ORDER BY state, date;

SELECT * FROM covid_summary_final;

SELECT
    state,
    date,
    confirmed,
    deaths,
    case_fatality_rate
FROM covid_summary_final
ORDER BY state, date;


select current_user;
