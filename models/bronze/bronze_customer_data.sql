SELECT
    f.value:customer_id::STRING            AS customer_id,
    f.value:first_name::STRING             AS first_name,
    f.value:last_name::STRING              AS last_name,
    f.value:email::STRING                  AS email,
    f.value:phone::STRING                  AS phone,
 
    -- flexible date conversion
    COALESCE(
        TRY_TO_DATE(f.value:birth_date::STRING,'DD-MM-YYYY'),
        TRY_TO_DATE(f.value:birth_date::STRING,'YYYY-MM-DD')
    ) AS birth_date,
 
    TRY_TO_DATE(f.value:registration_date::STRING)      AS registration_date,
    TRY_TO_DATE(f.value:last_purchase_date::STRING)     AS last_purchase_date,
    TRY_TO_DATE(f.value:last_modified_date::STRING)     AS last_modified_date,
 
    f.value:income_bracket::STRING         AS income_bracket,
    f.value:loyalty_tier::STRING           AS loyalty_tier,
    f.value:occupation::STRING             AS occupation,
    f.value:preferred_communication::STRING AS preferred_communication,
    f.value:preferred_payment_method::STRING AS preferred_payment_method,
 
    f.value:total_purchases::NUMBER        AS total_purchases,
    f.value:total_spend::FLOAT             AS total_spend,
 
    -- nested address fields
    f.value:address.city::STRING           AS city,
    f.value:address.state::STRING          AS state,
    f.value:address.country::STRING        AS country,
    f.value:address.street::STRING         AS street,
    f.value:address.zip_code::STRING       AS zip_code
 
FROM {{ source('bronze','ext_customer_data') }},
LATERAL FLATTEN(input => VALUE:customers_data) f