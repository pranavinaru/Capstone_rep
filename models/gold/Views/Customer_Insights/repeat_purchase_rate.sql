{{ config(materialized='view') }}
 
WITH customer_orders AS (
 
SELECT
customerkey,
COUNT(DISTINCT order_id) AS order_count
FROM {{ ref('Fact_sales') }}
GROUP BY customerkey
 
)
 
SELECT
 
COUNT(CASE WHEN order_count > 1 THEN 1 END) * 100.0
/
COUNT(*) AS repeat_purchase_rate
 
FROM customer_orders