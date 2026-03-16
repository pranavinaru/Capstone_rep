{{ config(materialized='view') }}
 
SELECT p.product_name,AVG(f.stockturnoverratio) AS avg_stock_turnover
FROM {{ ref('Fact_inventoryy') }} f
JOIN {{ ref('Dim_product') }} p
ON f.productkey = p.productkey
GROUP BY p.product_name 