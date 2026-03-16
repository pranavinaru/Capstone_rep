SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id','dbt_valid_from']) }} AS customerkey,
    customer_id,
    first_name || ' ' || last_name AS full_name,
    valid_email AS email,
    valid_phone AS phone,
    city,
    state,
    country,
    birth_date,
    customer_age,
    customer_segment,
    registration_date,
    dbt_valid_from AS start_date,
    dbt_valid_to AS end_date,
    CASE
        WHEN dbt_valid_to IS NULL THEN TRUE
        ELSE FALSE
    END AS is_current
FROM {{ ref('silver_customer_data') }}