WITH source_data AS (

SELECT *
FROM {{ ref('snp_customer_data') }}
WHERE dbt_valid_to IS NULL

),

cleaned_birthdate AS (

SELECT

TRIM(customer_id) AS customer_id,

INITCAP(TRIM(first_name)) AS first_name,
INITCAP(TRIM(last_name)) AS last_name,

INITCAP(TRIM(first_name)) || ' ' || INITCAP(TRIM(last_name)) AS full_name,

LOWER(TRIM(email)) AS email,

CASE
    WHEN LOWER(TRIM(email)) RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    THEN LOWER(TRIM(email))
    ELSE NULL
END AS valid_email,

REGEXP_REPLACE(phone,'[^0-9]','') AS phone_number,

CASE
    WHEN LENGTH(phone_number) = 11 AND LEFT(phone_number,1) = '1'
    THEN SUBSTRING(phone_number,2)

    WHEN LENGTH(phone_number) = 10 AND LEFT(phone_number,1) = '1'
    THEN NULL

    WHEN LENGTH(phone_number) = 10
    THEN phone_number

    ELSE NULL
END AS valid_phone,


COALESCE(
    TRY_TO_DATE(birth_date,'DD-MM-YYYY'),
    TRY_TO_DATE(birth_date,'YYYY-MM-DD'),
    TRY_TO_DATE(birth_date,'MM/DD/YYYY')
) AS birth_date,

TRY_TO_DATE(registration_date) AS registration_date,
TRY_TO_DATE(last_purchase_date) AS last_purchase_date,
TRY_TO_DATE(last_modified_date) AS last_modified_date,

COALESCE(TRY_TO_NUMBER(total_purchases),0) AS total_purchases,
COALESCE(TRY_TO_NUMBER(total_spend),0) AS total_spend,

UPPER(TRIM(income_bracket)) AS income_bracket,
UPPER(TRIM(loyalty_tier)) AS loyalty_tier,

TRY_TO_BOOLEAN(marketing_opt_in) AS marketing_opt_in,

INITCAP(TRIM(occupation)) AS occupation,

INITCAP(TRIM(preferred_payment_method)) AS preferred_payment_method,
UPPER(TRIM(preferred_communication)) AS preferred_communication,

INITCAP(TRIM(street)) AS street,
INITCAP(TRIM(city)) AS city,
UPPER(TRIM(state)) AS state,
TRIM(zip_code) AS zip_code,
UPPER(TRIM(country)) AS country,
dbt_scd_id,
dbt_valid_from,
dbt_valid_to,
dbt_updated_at

FROM source_data

),

final_cleaned AS (

SELECT
*,

CASE
    WHEN birth_date IS NOT NULL
    THEN DATEDIFF(year, birth_date, CURRENT_DATE)
    ELSE NULL
END AS customer_age,

CASE
WHEN birth_date IS NULL
    THEN 'Unknown'

WHEN DATEDIFF(year, birth_date, CURRENT_DATE) BETWEEN 18 AND 35
    THEN 'Young'

WHEN DATEDIFF(year, birth_date, CURRENT_DATE) BETWEEN 36 AND 55
    THEN 'Middle-aged'

WHEN DATEDIFF(year, birth_date, CURRENT_DATE) > 55
    THEN 'Senior'

ELSE 'Unknown'

END AS customer_segment

FROM cleaned_birthdate

)

SELECT *
FROM final_cleaned