{{ config(materialized='view') }}
 
SELECT p.category,
       SUM(f.total_sales_amount) AS total_sales
FROM {{ ref('Fact_sales') }} f
JOIN {{ ref('Dim_product') }} p
ON f.productkey = p.productkey
GROUP BY p.category
ORDER BY total_sales DESC