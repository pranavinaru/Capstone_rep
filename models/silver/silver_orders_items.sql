WITH source_data AS (
 
SELECT *
FROM {{ ref('bronze_orders_data')}}
 
),
 
clean_items AS (
 
SELECT
 
TRIM(order_id) AS order_id,
TRIM(product_id) AS product_id,
 
TRY_TO_NUMBER(quantity) AS quantity,
TRY_TO_NUMBER(unit_price) AS unit_price,
TRY_TO_NUMBER(cost_price) AS cost_price,
 
TRY_TO_NUMBER(item_discount) AS discount_amount,
 
quantity * unit_price AS item_total_amount,
quantity * cost_price AS item_cost
 
FROM source_data
 
)
 
SELECT *
FROM clean_items