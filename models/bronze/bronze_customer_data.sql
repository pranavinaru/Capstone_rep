SELECT
 
f.value:customer_id::STRING AS customer_id,
f.value:first_name::STRING AS first_name,
f.value:last_name::STRING AS last_name,
f.value:email::STRING AS email,
f.value:phone::STRING AS phone,
 
-- Dates kept as STRING
f.value:birth_date::STRING AS birth_date,
f.value:registration_date::STRING AS registration_date,
f.value:last_purchase_date::STRING AS last_purchase_date,
f.value:last_modified_date::STRING AS last_modified_date,
 
-- Other attributes
f.value:income_bracket::STRING AS income_bracket,
f.value:loyalty_tier::STRING AS loyalty_tier,
f.value:occupation::STRING AS occupation,
f.value:preferred_communication::STRING AS preferred_communication,
f.value:preferred_payment_method::STRING AS preferred_payment_method,
f.value:marketing_opt_in::STRING AS marketing_opt_in,
 
-- Numeric values also stored as STRING in Bronze
f.value:total_purchases::STRING AS total_purchases,
f.value:total_spend::STRING AS total_spend,
 
-- Nested address fields
f.value:address.city::STRING AS city,
f.value:address.state::STRING AS state,
f.value:address.country::STRING AS country,
f.value:address.street::STRING AS street,
f.value:address.zip_code::STRING AS zip_code
 
FROM {{ source('bronze','ext_customer_data') }},
LATERAL FLATTEN(input => VALUE:customers_data) f