WITH source_data AS (
 
SELECT *
FROM {{ ref('bronze_orders_data') }}
 
),
 
/* ===============================
DATA TYPE STANDARDIZATION
================================ */
 
clean_orders AS (
 
SELECT
 
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
 
TRY_TO_NUMBER(quantity) AS quantity,
TRY_TO_NUMBER(unit_price) AS unit_price,
TRY_TO_NUMBER(cost_price) AS cost_price,
TRY_TO_NUMBER(item_discount) AS discount_amount,
 
TRY_TO_NUMBER(tax_amount) AS tax_amount,
TRY_TO_NUMBER(shipping_cost) AS shipping_cost,
TRY_TO_NUMBER(order_discount) AS order_discount,
TRY_TO_NUMBER(total_amount) AS total_amount,
 
INITCAP(TRIM(billing_city)) AS billing_city,
INITCAP(TRIM(billing_state)) AS billing_state,
TRIM(billing_street) AS billing_street,
TRIM(billing_zip_code) AS billing_zip_code,
 
INITCAP(TRIM(shipping_city)) AS shipping_city,
INITCAP(TRIM(shipping_state)) AS shipping_state,
TRIM(shipping_street) AS shipping_street,
TRIM(shipping_zip_code) AS shipping_zip_code,
 
product_id
 
FROM source_data
 
),
 
/* ===============================
AGGREGATE ORDER ITEMS
================================ */
 
order_items_agg AS (
 
SELECT
 
order_id,
 
COUNT(product_id) AS total_items,
 
SUM(quantity) AS total_quantity,
 
SUM(quantity * unit_price) AS calculated_total_amount,
 
SUM(quantity * cost_price) AS total_cost,
 
SUM(discount_amount) AS total_discount
 
FROM clean_orders
 
GROUP BY order_id
 
),
 
/* ===============================
JOIN BACK ORDER DATA
================================ */
 
orders_enriched AS (
 
SELECT
 
c.*,
a.total_items,
a.total_quantity,
a.calculated_total_amount,
a.total_cost,
a.total_discount
 
FROM clean_orders c
LEFT JOIN order_items_agg a
ON c.order_id = a.order_id
 
),
 
/* ===============================
PROFIT CALCULATION
================================ */
 
orders_profit AS (
 
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
 
FROM orders_enriched
 
),
 
/* ===============================
ORDER TIME OF DAY
================================ */
 
orders_time AS (
 
SELECT
 
*,
 
CASE
WHEN DATE_PART(hour, order_date) BETWEEN 5 AND 11 THEN 'Morning'
WHEN DATE_PART(hour, order_date) BETWEEN 12 AND 16 THEN 'Afternoon'
WHEN DATE_PART(hour, order_date) BETWEEN 17 AND 21 THEN 'Evening'
ELSE 'Night'
END AS order_time_of_day
 
FROM orders_profit
 
),
 
/* ===============================
DATE DIMENSIONS
================================ */
 
orders_date_parts AS (
 
SELECT
 
*,
 
DATE_PART(week, order_date) AS order_week,
DATE_PART(month, order_date) AS order_month,
DATE_PART(quarter, order_date) AS order_quarter,
DATE_PART(year, order_date) AS order_year
 
FROM orders_time
 
),
 
/* ===============================
SHIPPING METRICS
================================ */
 
orders_shipping AS (
 
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
 
FROM orders_date_parts
 
)
 
SELECT *
FROM orders_shipping