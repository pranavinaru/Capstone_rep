WITH source_data AS (
 
    SELECT *
    FROM {{ ref('snp_product_data') }}
    WHERE dbt_valid_to IS NULL
 
),
 
clean_product AS (
 
    SELECT
 
    /* PRIMARY KEY */
    TRIM(product_id) AS product_id,
 
    /* PRODUCT NAME */
    INITCAP(TRIM(product_name)) AS product_name,
    INITCAP(TRIM(brand)) AS brand,
 
    /* CATEGORY */
    INITCAP(TRIM(category)) AS category,
    INITCAP(TRIM(subcategory)) AS subcategory,
    INITCAP(TRIM(product_line)) AS product_line,
 
    /* SUPPLIER */
    TRIM(supplier_id) AS supplier_id,
 
    /* ATTRIBUTES */
    INITCAP(TRIM(color)) AS color,
    UPPER(TRIM(size)) AS size,
    TRIM(dimensions) AS dimensions,
    TRIM(weight) AS weight,
 
    /* DESCRIPTION */
    TRIM(short_description) AS short_description,
    TRIM(technical_specs) AS technical_specs,
 
    CONCAT(
        INITCAP(TRIM(product_name)),
        ' - ',
        TRIM(short_description),
        ' - ',
        TRIM(technical_specs)
    ) AS product_full_description,
 
    /* NUMERIC FIELDS */
    COALESCE(cost_price::NUMBER,0) AS cost_price,
    COALESCE(unit_price::NUMBER,0) AS unit_price,
    COALESCE(stock_quantity::NUMBER,0) AS stock_quantity,
    COALESCE(reorder_level::NUMBER,0) AS reorder_level,
 
    /* BOOLEAN */
    TRY_TO_BOOLEAN(is_featured) AS is_featured,
 
    /* DATE STANDARDIZATION */
    launch_date::DATE AS launch_date,
    last_modified_date AS last_modified_date,
 
    /* OTHER */
    TRIM(warranty_period) AS warranty_period,
 
    /* SNAPSHOT META */
    dbt_valid_from,
    dbt_valid_to,
    dbt_updated_at
 
    FROM source_data
 
)
 
SELECT
*,
 
/* PROFIT MARGIN */
CASE
    WHEN unit_price > 0
    THEN ((unit_price - cost_price) / unit_price) * 100
    ELSE NULL
END AS profit_margin_percentage,
 
/* LOW STOCK FLAG */
CASE
    WHEN stock_quantity < reorder_level
    THEN TRUE
    ELSE FALSE
END AS low_stock_flag
 
FROM clean_product