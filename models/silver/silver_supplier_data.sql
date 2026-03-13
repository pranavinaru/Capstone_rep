WITH source_data AS (
    SELECT *
    FROM {{ ref('snp_supplier_data') }}
    WHERE dbt_valid_to IS NULL
),
 
cleaned_birthdate AS (
    SELECT
        TRIM(supplier_id) AS supplier_id,
        INITCAP(TRIM(supplier_name)) AS supplier_name,
        UPPER(TRIM(supplier_type)) AS supplier_type,
        TRIM(tax_id) AS tax_id,
        LOWER(TRIM(website)) AS website,
        TRY_TO_NUMBER(year_established) AS year_established,
        UPPER(TRIM(credit_rating)) AS credit_rating,
        TRY_TO_BOOLEAN(is_active) AS is_active,
        TRY_TO_DATE(last_modified_date) AS last_modified_date,
        TRY_TO_DATE(last_order_date) AS last_order_date,
        TRY_TO_NUMBER(lead_time_days) AS lead_time_days,
        COALESCE(TRY_TO_NUMBER(minimum_order_quantity),0) AS minimum_order_quantity,
        UPPER(TRIM(payment_terms)) AS payment_terms,
        INITCAP(TRIM(preferred_carrier)) AS preferred_carrier,
        LOWER(TRIM(categories_supplied)) AS categories_supplied,
        INITCAP(TRIM(address)) AS address,
        INITCAP(TRIM(contact_person)) AS contact_person,
        LOWER(TRIM(contact_email)) AS contact_email,
 
        CASE
            WHEN LOWER(TRIM(contact_email))
                 RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            THEN LOWER(TRIM(contact_email))
            ELSE NULL
        END AS valid_contact_email,
 
        REGEXP_REPLACE(contact_phone,'[^0-9]','') AS phone_number,
 
        CASE
            -- 11-digit number starting with 1 → strip leading 1
            WHEN LENGTH(REGEXP_REPLACE(contact_phone,'[^0-9]','')) = 11
                 AND LEFT(REGEXP_REPLACE(contact_phone,'[^0-9]',''),1) = '1'
            THEN SUBSTRING(REGEXP_REPLACE(contact_phone,'[^0-9]',''),2)
 
            -- 10-digit number starting with 1 → invalid
            WHEN LENGTH(REGEXP_REPLACE(contact_phone,'[^0-9]','')) = 10
                 AND LEFT(REGEXP_REPLACE(contact_phone,'[^0-9]',''),1) = '1'
            THEN NULL
 
            -- 10-digit number → keep as-is
            WHEN LENGTH(REGEXP_REPLACE(contact_phone,'[^0-9]','')) = 10
            THEN REGEXP_REPLACE(contact_phone,'[^0-9]','')
 
            ELSE NULL
        END AS valid_phone,
 
        TRIM(contract_id) AS contract_id,
        TRY_TO_DATE(contract_start_date) AS contract_start_date,
        TRY_TO_DATE(contract_end_date) AS contract_end_date,
        TRY_TO_BOOLEAN(exclusivity) AS exclusivity,
        TRY_TO_BOOLEAN(renewal_option) AS renewal_option,
        TRY_TO_NUMBER(average_delay_days) AS average_delay_days,
        TRY_TO_NUMBER(defect_rate) AS defect_rate,
        TRY_TO_NUMBER(on_time_delivery_rate) AS on_time_delivery_rate,
        INITCAP(TRIM(quality_rating)) AS quality_rating,
        TRY_TO_NUMBER(response_time_hours) AS response_time_hours,
        TRY_TO_NUMBER(returns_percentage) AS returns_percentage,
 
        dbt_scd_id,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to
    FROM source_data
),
 
final_cleaned AS (
    SELECT *
    FROM cleaned_birthdate
)
 
SELECT *
FROM final_cleaned