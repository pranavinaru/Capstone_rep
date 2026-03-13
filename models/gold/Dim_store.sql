SELECT
 
 
ROW_NUMBER() OVER (ORDER BY store_id, dbt_valid_from) AS StoreKey,
 
store_id,
store_name,
 
city,
state,
country,
region,
 
store_type,
opening_date,
 
store_size_category,
 
FROM {{ ref('silver_store_data') }}