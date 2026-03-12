WITH source_data AS (

SELECT *
FROM {{ ref('snp_store_data') }}
WHERE dbt_valid_to IS NULL

),

cleaned AS (

SELECT

/* ======================
KEY
====================== */

TRIM(store_id) AS store_id,
TRIM(manager_id) AS manager_id,


/* ======================
STORE STANDARDIZATION
====================== */

INITCAP(TRIM(store_name)) AS store_name,
INITCAP(TRIM(store_type)) AS store_type,
UPPER(TRIM(region)) AS region,


/* ======================
EMAIL CLEANING
====================== */

LOWER(TRIM(email)) AS email,

CASE
    WHEN LOWER(TRIM(email)) RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    THEN LOWER(TRIM(email))
    ELSE NULL
END AS valid_email,


/* ======================
PHONE NORMALIZATION
====================== */

REGEXP_REPLACE(phone_number,'[^0-9]','') AS phone_number,

CASE
    WHEN LENGTH(REGEXP_REPLACE(phone_number,'[^0-9]','')) BETWEEN 10 AND 15
    THEN REGEXP_REPLACE(phone_number,'[^0-9]','')
    ELSE NULL
END AS valid_phone,


/* ======================
NUMERIC STANDARDIZATION
====================== */

COALESCE(TRY_TO_NUMBER(employee_count),0) AS employee_count,
COALESCE(TRY_TO_NUMBER(size_sq_ft),0) AS size_sq_ft,

COALESCE(TRY_TO_NUMBER(current_sales),0) AS current_sales,
COALESCE(TRY_TO_NUMBER(sales_target),0) AS sales_target,
COALESCE(TRY_TO_NUMBER(monthly_rent),0) AS monthly_rent,

TRY_TO_BOOLEAN(is_active) AS is_active,


/* ======================
STORE SIZE CATEGORY
====================== */

CASE
    WHEN TRY_TO_NUMBER(size_sq_ft) < 5000 THEN 'Small'
    WHEN TRY_TO_NUMBER(size_sq_ft) BETWEEN 5000 AND 10000 THEN 'Medium'
    WHEN TRY_TO_NUMBER(size_sq_ft) > 10000 THEN 'Large'
    ELSE 'Unknown'
END AS store_size_category,


/* ======================
DATE STANDARDIZATION
====================== */

TRY_TO_DATE(opening_date) AS opening_date,
last_modified_date::DATE AS last_modified_date,


/* ======================
STORE AGE
====================== */

CASE
    WHEN TRY_TO_DATE(opening_date) IS NOT NULL
    THEN DATEDIFF(year, TRY_TO_DATE(opening_date), CURRENT_DATE)
    ELSE NULL
END AS store_age_years,


/* ======================
STORE PERFORMANCE METRICS
====================== */

CASE
    WHEN TRY_TO_NUMBER(sales_target) > 0
    THEN (TRY_TO_NUMBER(current_sales) / TRY_TO_NUMBER(sales_target)) * 100
    ELSE NULL
END AS sales_target_achievement_percentage,


CASE
    WHEN TRY_TO_NUMBER(size_sq_ft) > 0
    THEN TRY_TO_NUMBER(current_sales) / TRY_TO_NUMBER(size_sq_ft)
    ELSE NULL
END AS revenue_per_sq_ft,


CASE
    WHEN TRY_TO_NUMBER(employee_count) > 0
    THEN TRY_TO_NUMBER(current_sales) / TRY_TO_NUMBER(employee_count)
    ELSE NULL
END AS employee_efficiency,


/* ======================
PERFORMANCE FLAG
====================== */

CASE
    WHEN TRY_TO_NUMBER(sales_target) > 0
         AND (TRY_TO_NUMBER(current_sales) / TRY_TO_NUMBER(sales_target)) * 100 < 90
    THEN 'Underperforming'
    ELSE 'Normal'
END AS performance_flag,


/* ======================
OPERATING HOURS
====================== */

INITCAP(TRIM(weekday_hours)) AS weekday_hours,
INITCAP(TRIM(weekend_hours)) AS weekend_hours,
INITCAP(TRIM(holiday_hours)) AS holiday_hours,


/* ======================
SERVICES
====================== */

INITCAP(TRIM(services)) AS services,


/* ======================
ADDRESS STANDARDIZATION
====================== */

INITCAP(TRIM(street)) AS street,
INITCAP(TRIM(city)) AS city,
UPPER(TRIM(state)) AS state,
UPPER(TRIM(country)) AS country,
TRIM(zip_code) AS zip_code,


/* ======================
SNAPSHOT METADATA
====================== */

dbt_valid_from,
dbt_valid_to,
dbt_updated_at

FROM source_data

)

SELECT *
FROM cleaned