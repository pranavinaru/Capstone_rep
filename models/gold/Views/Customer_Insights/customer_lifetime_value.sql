{{ config(materialized='view') }}
 
SELECT c.customerkey,
       c.full_name,
       SUM(f.total_sales_amount) AS customer_lifetime_value,
       COUNT(DISTINCT f.order_id) AS total_orders
FROM {{ ref('Fact_sales') }} f
JOIN {{ ref('Dim_customer') }} c
ON f.customerkey = c.customerkey
GROUP BY c.customerkey,c.full_name 
ORDER BY customer_lifetime_value DESC