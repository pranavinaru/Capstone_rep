{{ config(materialized='view') }}
 
SELECT p.product_name,
       AVG(f.stockturnoverratio) AS turnover_ratio,
       CASE
        WHEN AVG(f.stockturnoverratio) >= 5 THEN 'Fast Moving'
        WHEN AVG(f.stockturnoverratio) >= 2 THEN 'Medium Moving'
        ELSE 'Slow Moving'
       END AS product_movement
FROM {{ ref('Fact_inventoryy') }} f
JOIN {{ ref('Dim_product') }} p
ON f.productkey = p.productkey
GROUP BY p.product_name
