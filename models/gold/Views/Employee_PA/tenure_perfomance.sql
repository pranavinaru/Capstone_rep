{{ config(materialized='view') }}
 
SELECT e.full_name AS employee_name,
       DATEDIFF(year, e.hire_date, CURRENT_DATE) AS tenure_years,
       SUM(f.total_sales_amount) AS total_sales,
       COUNT(DISTINCT f.order_id) AS total_orders
FROM {{ ref('Fact_sales') }} f
JOIN {{ ref('Dim_employee') }} e
ON f.employeekey = e.employeekey
GROUP BY e.full_name,e.hire_date
ORDER BY total_sales DESC