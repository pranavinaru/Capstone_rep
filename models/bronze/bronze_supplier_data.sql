SELECT
 
s.value:supplier_id::STRING        AS supplier_id,
s.value:supplier_name::STRING      AS supplier_name,
s.value:supplier_type::STRING      AS supplier_type,
s.value:tax_id::STRING             AS tax_id,
s.value:website::STRING            AS website,
s.value:year_established::NUMBER   AS year_established,
 
s.value:credit_rating::STRING      AS credit_rating,
s.value:is_active::BOOLEAN         AS is_active,
 
TO_DATE(s.value:last_modified_date::STRING,'YYYY-MM-DD') AS last_modified_date,
TO_DATE(s.value:last_order_date::STRING,'YYYY-MM-DD') AS last_order_date,
 
s.value:lead_time_days::NUMBER     AS lead_time_days,
s.value:minimum_order_quantity::NUMBER AS minimum_order_quantity,
 
s.value:payment_terms::STRING      AS payment_terms,
s.value:preferred_carrier::STRING  AS preferred_carrier,
 
-- categories array
ARRAY_TO_STRING(s.value:categories_supplied, ', ') AS categories_supplied,
 
-- contact information
s.value:contact_information.address::STRING       AS address,
s.value:contact_information.contact_person::STRING AS contact_person,
s.value:contact_information.email::STRING         AS contact_email,
s.value:contact_information.phone::STRING         AS contact_phone,
 
-- contract details
s.value:contract_details.contract_id::STRING AS contract_id,
 
TO_DATE(s.value:contract_details.start_date::STRING,'YYYY-MM-DD') AS contract_start_date,
TO_DATE(s.value:contract_details.end_date::STRING,'YYYY-MM-DD') AS contract_end_date,
 
s.value:contract_details.exclusivity::BOOLEAN AS exclusivity,
s.value:contract_details.renewal_option::BOOLEAN AS renewal_option,
 
-- performance metrics
s.value:performance_metrics.average_delay_days::FLOAT AS average_delay_days,
s.value:performance_metrics.defect_rate::FLOAT AS defect_rate,
s.value:performance_metrics.on_time_delivery_rate::FLOAT AS on_time_delivery_rate,
 
s.value:performance_metrics.quality_rating::STRING AS quality_rating,
 
s.value:performance_metrics.response_time_hours::NUMBER AS response_time_hours,
s.value:performance_metrics.returns_percentage::FLOAT AS returns_percentage
 
FROM {{ source('bronze','ext_supplier_data') }},
LATERAL FLATTEN(input => VALUE:suppliers_data) s