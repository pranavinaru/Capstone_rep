SELECT
    {{ dbt_utils.generate_surrogate_key(['store_id','dbt_valid_from']) }} AS Storekey,
    store_id,
    store_name,
    city,
    state,
    country,
    region,
    store_type,
    opening_date,
    store_size_category
FROM {{ ref('silver_store_data') }}