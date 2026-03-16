{{ config(materialized='view') }}
 
SELECT e.role,
       SUM(f.total_sales_amount) AS total_sales,
       COUNT(DISTINCT f.order_id) AS total_orders
FROM {{ ref('Fact_sales') }} f
JOIN {{ ref('Dim_employee') }} e
ON f.employeekey = e.employeekey
GROUP BY e.role
ORDER BY total_sales DESC