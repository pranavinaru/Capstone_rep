WITH order_items AS (
 
SELECT *
FROM {{ ref('silver_orders_items') }}
 
),
 
orders AS (
 
SELECT *
FROM {{ ref('silver_orders_data') }}
 
),
 
sales AS (
 
SELECT
 
/* Surrogate Key */
ROW_NUMBER() OVER (ORDER BY oi.order_id) AS saleskey,
 
/* Business Key */
oi.order_id,
 
/* Dimension Keys */
 
c.customerkey,
p.productkey,
s.storekey,
d.datekey,
e.employeekey,
mc.campaignkey,
 
/* Measures */
 
oi.quantity AS quantity_sold,
 
oi.item_total_amount / NULLIF(oi.quantity,0) AS unit_price,
 
oi.item_total_amount AS total_sales_amount,
 
oi.item_cost AS cost_amount,
 
oi.discount_amount,
 
o.shipping_cost,
 
/* Profit */
 
(
oi.item_total_amount
- oi.item_cost
- oi.discount_amount
- o.shipping_cost
) AS profit_amount,
 
/* Region */
 
s.region,
 
/* Sales Channel */
 
CASE
WHEN LOWER(o.order_source) LIKE '%online%' THEN 'Online'
ELSE 'In-Store'
END AS sales_channel,
 
/* Customer Segment */
 
c.customer_segment AS customer_segment_impact
 
FROM order_items oi
 
LEFT JOIN orders o
ON oi.order_id = o.order_id
 
LEFT JOIN {{ ref('Dim_customer') }} c
ON o.customer_id = c.customer_id
 
LEFT JOIN {{ ref('Dim_product') }} p
ON oi.product_id = p.product_id
 
LEFT JOIN {{ ref('Dim_store') }} s
ON o.store_id = s.store_id
 
LEFT JOIN {{ ref('Dim_employee') }} e
ON o.employee_id = e.employeeid
 
LEFT JOIN {{ ref('Dim_campaign') }} mc
ON o.campaign_id = mc.campaignid
 
LEFT JOIN {{ ref('Dim_Date') }} d
ON DATE(o.order_date) = d.full_date
 
)
 
SELECT *
FROM sales
 