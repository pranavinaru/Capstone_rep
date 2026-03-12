WITH source_data AS (
 
SELECT *
FROM {{ ref('snp_customer_data') }}
WHERE dbt_valid_to IS NULL
 
),
 
cleaned AS (
 
SELECT
 
/* ======================
KEY
====================== */
 
TRIM(customer_id) AS customer_id,
 
 
/* ======================
NAME STANDARDIZATION
====================== */
 
INITCAP(TRIM(first_name)) AS first_name,
INITCAP(TRIM(last_name)) AS last_name,
 
INITCAP(TRIM(first_name)) || ' ' || INITCAP(TRIM(last_name))
    AS full_name,
 
 
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
 
REGEXP_REPLACE(phone,'[^0-9]','') AS phone_number,
 
CASE
    WHEN LENGTH(REGEXP_REPLACE(phone,'[^0-9]','')) BETWEEN 10 AND 15
    THEN REGEXP_REPLACE(phone,'[^0-9]','')
    ELSE NULL
END AS valid_phone,
 
 
/* ======================
DATE STANDARDIZATION
====================== */
 
TRY_TO_DATE(birth_date) AS birth_date,
TRY_TO_DATE(registration_date) AS registration_date,
TRY_TO_DATE(last_purchase_date) AS last_purchase_date,
TRY_TO_DATE(last_modified_date) AS last_modified_date,
 
 
/* ======================
CUSTOMER AGE
====================== */
 
CASE
    WHEN TRY_TO_DATE(birth_date) IS NOT NULL
    THEN DATEDIFF(year, TRY_TO_DATE(birth_date), CURRENT_DATE)
    ELSE NULL
END AS customer_age,
 
 
/* ======================
CUSTOMER SEGMENT
====================== */
 
CASE
WHEN TRY_TO_DATE(birth_date) IS NULL
    THEN 'Unknown'
 
WHEN DATEDIFF(year, TRY_TO_DATE(birth_date), CURRENT_DATE) BETWEEN 18 AND 35
    THEN 'Young'
 
WHEN DATEDIFF(year, TRY_TO_DATE(birth_date), CURRENT_DATE) BETWEEN 36 AND 55
    THEN 'Middle-aged'
 
WHEN DATEDIFF(year, TRY_TO_DATE(birth_date), CURRENT_DATE) > 55
    THEN 'Senior'
 
ELSE 'Unknown'
 
END AS customer_segment,
 
 
/* ======================
NUMERIC VALIDATION
====================== */
 
COALESCE(TRY_TO_NUMBER(total_purchases),0) AS total_purchases,
COALESCE(TRY_TO_NUMBER(total_spend),0) AS total_spend,
 
 
/* ======================
CATEGORICAL STANDARDIZATION
====================== */
 
UPPER(TRIM(income_bracket)) AS income_bracket,
UPPER(TRIM(loyalty_tier)) AS loyalty_tier,
 
TRY_TO_BOOLEAN(marketing_opt_in) AS marketing_opt_in,
 
 
/* ======================
OCCUPATION
====================== */
 
INITCAP(TRIM(occupation)) AS occupation,
 
 
/* ======================
PAYMENT & COMMUNICATION
====================== */
 
INITCAP(TRIM(preferred_payment_method)) AS preferred_payment_method,
UPPER(TRIM(preferred_communication)) AS preferred_communication,
 
 
/* ======================
ADDRESS STANDARDIZATION
====================== */
 
INITCAP(TRIM(street)) AS street,
INITCAP(TRIM(city)) AS city,
UPPER(TRIM(state)) AS state,
TRIM(zip_code) AS zip_code,
UPPER(TRIM(country)) AS country,
 
 
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