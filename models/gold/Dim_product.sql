SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS productkey,
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    color,
    size,
    unit_price,
    cost_price,
    supplier_id
FROM {{ ref('silver_product_data') }}