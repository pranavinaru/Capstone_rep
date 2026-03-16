{{ config(materialized='view') }}
 
SELECT p.product_name,
       SUM(f.quantity_sold) AS total_units_sold,
       SUM(f.total_sales_amount) AS total_sales
FROM {{ ref('Fact_sales') }} f
JOIN {{ ref('Dim_product') }} p
ON f.productkey = p.productkey
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 10