SELECT
 
p.value:product_id::STRING        AS product_id,
p.value:name::STRING              AS product_name,
p.value:brand::STRING             AS brand,
p.value:category::STRING          AS category,
p.value:subcategory::STRING       AS subcategory,
p.value:product_line::STRING      AS product_line,
p.value:supplier_id::STRING       AS supplier_id,
 
p.value:color::STRING             AS color,
p.value:size::STRING              AS size,
p.value:dimensions::STRING        AS dimensions,
p.value:technical_specs::STRING   AS technical_specs,
 
p.value:cost_price::STRING        AS cost_price,
p.value:unit_price::STRING        AS unit_price,
 
p.value:stock_quantity::STRING   AS stock_quantity,
p.value:reorder_level::STRING     AS reorder_level,
 
p.value:is_featured::STRING     AS is_featured,
 
p.value:launch_date::STRING AS launch_date,
p.value:last_modified_date::STRING AS last_modified_date,
 
p.value:warranty_period::STRING   AS warranty_period,
p.value:weight::STRING            AS weight,
p.value:short_description::STRING AS short_description
 
FROM {{ source('bronze','ext_product_data') }},
LATERAL FLATTEN(input => VALUE:products_data) p