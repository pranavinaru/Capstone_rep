{{ config(materialized='view') }}
 
SELECT p.product_name,
       SUM(f.inventoryvalue) AS total_inventory_value
FROM {{ ref('Fact_inventoryy') }} f
JOIN {{ ref('Dim_product') }} p
ON f.productkey = p.productkey
GROUP BY p.product_name
ORDER BY total_inventory_value DESC