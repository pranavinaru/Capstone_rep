WITH order_items AS (
 
SELECT *
FROM {{ ref('silver_orders_items') }}
 
),
 
order_items_agg AS (
 
SELECT
 
order_id,
 
COUNT(product_id) AS total_items,
SUM(quantity) AS total_quantity,
 
SUM(item_total_amount) AS calculated_total_amount,
SUM(item_cost) AS total_cost,
 
SUM(discount_amount) AS total_discount
 
FROM order_items
 
GROUP BY order_id
 
),
 
order_header AS (
 
SELECT DISTINCT
 
TRIM(order_id) AS order_id,
TRIM(customer_id) AS customer_id,
TRIM(employee_id) AS employee_id,
TRIM(store_id) AS store_id,
TRIM(campaign_id) AS campaign_id,
 
INITCAP(TRIM(order_status)) AS order_status,
INITCAP(TRIM(order_source)) AS order_source,
INITCAP(TRIM(payment_method)) AS payment_method,
 
TRY_TO_TIMESTAMP(order_date) AS order_date,
TRY_TO_TIMESTAMP(created_at) AS created_at,
 
TRY_TO_DATE(delivery_date) AS delivery_date,
TRY_TO_DATE(estimated_delivery_date) AS estimated_delivery_date,
TRY_TO_DATE(shipping_date) AS shipping_date,
 
TRY_TO_NUMBER(tax_amount) AS tax_amount,
TRY_TO_NUMBER(shipping_cost) AS shipping_cost,
TRY_TO_NUMBER(order_discount) AS order_discount,
TRY_TO_NUMBER(total_amount) AS total_amount
 
FROM {{ ref('bronze_orders_data') }}
 
),
 
orders_joined AS (
 
SELECT
 
h.*,
a.total_items,
a.total_quantity,
a.calculated_total_amount,
a.total_cost,
a.total_discount
 
FROM order_header h
LEFT JOIN order_items_agg a
ON h.order_id = a.order_id
 
),
 
profit_calc AS (
 
SELECT
 
*,
 
(total_amount
- total_cost
- total_discount
- shipping_cost
- tax_amount) AS profit_amount,
 
CASE
WHEN total_amount > 0
THEN
(total_amount
- total_cost
- total_discount
- shipping_cost
- tax_amount) / total_amount
END AS profit_margin_percentage
 
FROM orders_joined
 
),
 
order_time AS (
 
SELECT
 
*,
 
CASE
WHEN DATE_PART(hour, order_date) BETWEEN 5 AND 11 THEN 'Morning'
WHEN DATE_PART(hour, order_date) BETWEEN 12 AND 16 THEN 'Afternoon'
WHEN DATE_PART(hour, order_date) BETWEEN 17 AND 21 THEN 'Evening'
ELSE 'Night'
END AS order_time_of_day
 
FROM profit_calc
 
),
 
date_parts AS (
 
SELECT
 
*,
 
DATE_PART(week, order_date) AS order_week,
DATE_PART(month, order_date) AS order_month,
DATE_PART(quarter, order_date) AS order_quarter,
DATE_PART(year, order_date) AS order_year
 
FROM order_time
 
),
 
shipping_metrics AS (
 
SELECT
 
*,
 
DATEDIFF(day, order_date, shipping_date) AS processing_days,
DATEDIFF(day, shipping_date, delivery_date) AS shipping_days,
 
CASE
WHEN delivery_date IS NOT NULL
AND delivery_date <= estimated_delivery_date
THEN 'On Time'
 
WHEN delivery_date IS NOT NULL
AND delivery_date > estimated_delivery_date
THEN 'Delayed'
 
WHEN delivery_date IS NULL
AND CURRENT_DATE > estimated_delivery_date
THEN 'Potentially Delayed'
 
ELSE 'In Transit'
 
END AS delivery_status
 
FROM date_parts
 
)
 
SELECT *
FROM shipping_metrics