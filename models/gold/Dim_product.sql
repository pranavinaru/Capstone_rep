SELECT
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS productkey,
    product_id,
    product_name,
    category,
    subcategory,
    reorder_level,
    brand,
    color,
    size,
    unit_price,
    cost_price,
    supplier_id,
    stock_quantity
FROM {{ ref('silver_product_data') }}

