SELECT
 
o.value:order_id::STRING AS order_id,
o.value:customer_id::STRING AS customer_id,
o.value:campaign_id::STRING AS campaign_id,
o.value:employee_id::STRING AS employee_id,
o.value:store_id::STRING AS store_id,
 
o.value:order_status::STRING AS order_status,
o.value:order_source::STRING AS order_source,
o.value:payment_method::STRING AS payment_method,
 
-- timestamps kept as STRING
o.value:order_date::STRING AS order_date,
o.value:created_at::STRING AS created_at,
o.value:delivery_date::STRING AS delivery_date,
o.value:estimated_delivery_date::STRING AS estimated_delivery_date,
o.value:shipping_date::STRING AS shipping_date,
 
-- financial values stored as STRING
o.value:tax_amount::STRING AS tax_amount,
o.value:shipping_cost::STRING AS shipping_cost,
o.value:discount_amount::STRING AS order_discount,
o.value:total_amount::STRING AS total_amount,
 
-- billing address
o.value:billing_address.city::STRING AS billing_city,
o.value:billing_address.state::STRING AS billing_state,
o.value:billing_address.street::STRING AS billing_street,
o.value:billing_address.zip_code::STRING AS billing_zip_code,
 
-- shipping address
o.value:shipping_address.city::STRING AS shipping_city,
o.value:shipping_address.state::STRING AS shipping_state,
o.value:shipping_address.street::STRING AS shipping_street,
o.value:shipping_address.zip_code::STRING AS shipping_zip_code,
 
-- order items
i.value:product_id::STRING AS product_id,
i.value:quantity::STRING AS quantity,
i.value:unit_price::STRING AS unit_price,
i.value:cost_price::STRING AS cost_price,
i.value:discount_amount::STRING AS item_discount
 
FROM {{ source('bronze','ext_orders_data') }},
LATERAL FLATTEN(input => VALUE:orders_data) o,
LATERAL FLATTEN(input => o.value:order_items) i