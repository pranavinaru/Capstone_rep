WITH source_data AS (

    SELECT *
    FROM {{ ref('snp_product_data') }}
    WHERE dbt_valid_to IS NULL

),

clean_product AS (

    SELECT

    TRIM(product_id) AS product_id,

    INITCAP(TRIM(product_name)) AS product_name,
    INITCAP(TRIM(brand)) AS brand,

    INITCAP(TRIM(category)) AS category,
    INITCAP(TRIM(subcategory)) AS subcategory,
    INITCAP(TRIM(product_line)) AS product_line,

    TRIM(supplier_id) AS supplier_id,

    INITCAP(TRIM(color)) AS color,
    UPPER(TRIM(size)) AS size,
    TRIM(dimensions) AS dimensions,
    TRIM(weight) AS weight,

    TRIM(short_description) AS short_description,
    TRIM(technical_specs) AS technical_specs,

    CONCAT(
        INITCAP(TRIM(product_name)),
        ' - ',
        TRIM(short_description),
        ' - ',
        TRIM(technical_specs)
    ) AS product_full_description,

    COALESCE(cost_price::NUMBER,0) AS cost_price,
    COALESCE(unit_price::NUMBER,0) AS unit_price,
    COALESCE(stock_quantity::NUMBER,0) AS stock_quantity,
    COALESCE(reorder_level::NUMBER,0) AS reorder_level,

    TRY_TO_BOOLEAN(is_featured) AS is_featured,

    launch_date::DATE AS launch_date,
    last_modified_date AS last_modified_date,

    TRIM(warranty_period) AS warranty_period,

    dbt_valid_from,
    dbt_valid_to,
    dbt_updated_at

    FROM source_data

)

SELECT
*,

CASE
    WHEN unit_price > 0
    THEN ((unit_price - cost_price) / unit_price) * 100
    ELSE NULL
END AS profit_margin_percentage,

CASE
    WHEN stock_quantity < reorder_level
    THEN TRUE
    ELSE FALSE
END AS low_stock_flag

FROM clean_product