WITH source_data AS (
 
SELECT *
FROM {{ ref('snp_product_data') }}
WHERE dbt_valid_to IS NULL
 
),
 
product_data AS (
 
SELECT
 
/* =========================
KEY
========================= */
 
TRIM(product_id) AS product_id,
 
/* =========================
NAME STANDARDIZATION
========================= */
 
INITCAP(TRIM(product_name)) AS product_name,
INITCAP(TRIM(brand)) AS brand,
 
/* =========================
CATEGORY STANDARDIZATION
========================= */
 
INITCAP(TRIM(category)) AS category,
INITCAP(TRIM(subcategory)) AS subcategory,
INITCAP(TRIM(product_line)) AS product_line,
 
/* =========================
FULL PRODUCT DESCRIPTION
========================= */
 
CONCAT(
INITCAP(TRIM(product_name)),
' - ',
COALESCE(TRIM(short_description),''),
' ',
COALESCE(TRIM(technical_specs),'')
) AS full_product_description,
 
/* =========================
OTHER ATTRIBUTES
========================= */
 
INITCAP(TRIM(color)) AS color,
INITCAP(TRIM(size)) AS size,
TRIM(dimensions) AS dimensions,
TRIM(technical_specs) AS technical_specs,
 
/* =========================
DATE STANDARDIZATION
========================= */
 
TRY_TO_DATE(launch_date) AS launch_date,
TRY_TO_DATE(last_modified_date) AS last_modified_date,
 
/* =========================
NUMERIC VALIDATION
========================= */
 
COALESCE(TRY_TO_NUMBER(cost_price),0) AS cost_price,
COALESCE(TRY_TO_NUMBER(unit_price),0) AS unit_price,
 
COALESCE(TRY_TO_NUMBER(stock_quantity),0) AS stock_quantity,
COALESCE(TRY_TO_NUMBER(reorder_level),0) AS reorder_level,
 
/* =========================
PROFIT MARGIN
========================= */
 
CASE
WHEN TRY_TO_NUMBER(unit_price) > 0
THEN ((TRY_TO_NUMBER(unit_price) - TRY_TO_NUMBER(cost_price)) / TRY_TO_NUMBER(unit_price)) * 100
ELSE NULL
END AS profit_margin_percentage,
 
/* =========================
LOW STOCK FLAG
========================= */
 
CASE
WHEN TRY_TO_NUMBER(stock_quantity) < TRY_TO_NUMBER(reorder_level)
THEN TRUE
ELSE FALSE
END AS low_stock_flag,
 
/* =========================
BOOLEAN STANDARDIZATION
========================= */
 
TRY_TO_BOOLEAN(is_featured) AS is_featured,
 
/* =========================
TEXT CLEANING
========================= */
 
TRIM(warranty_period) AS warranty_period,
TRIM(weight) AS weight,
TRIM(short_description) AS short_description,
 
/* =========================
SNAPSHOT METADATA
========================= */
 
dbt_valid_from,
dbt_valid_to,
dbt_updated_at
 
FROM source_data
 
)
 
SELECT *
FROM product_data