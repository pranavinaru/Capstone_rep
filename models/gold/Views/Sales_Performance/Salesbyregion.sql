{{ config(materialized='view') }}
 
SELECT d.year,
       d.month,
       s.region,
       SUM(f.total_sales_amount) AS total_sales
FROM {{ ref('Fact_sales') }} f
JOIN {{ ref('Dim_store') }} s
ON f.storekey = s.storekey
JOIN {{ ref('Dim_Date') }} d
ON f.datekey = d.datekey
GROUP BY d.year,d.month,s.region
ORDER BY d.year,d.month