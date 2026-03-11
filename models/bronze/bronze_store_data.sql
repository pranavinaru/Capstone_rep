SELECT
 
s.value:store_id::STRING           AS store_id,
s.value:store_name::STRING         AS store_name,
s.value:store_type::STRING         AS store_type,
s.value:region::STRING             AS region,
s.value:manager_id::STRING         AS manager_id,
 
s.value:email::STRING              AS email,
s.value:phone_number::STRING       AS phone_number,
 
s.value:employee_count::NUMBER     AS employee_count,
s.value:size_sq_ft::NUMBER         AS size_sq_ft,
 
s.value:current_sales::FLOAT       AS current_sales,
s.value:sales_target::FLOAT        AS sales_target,
s.value:monthly_rent::FLOAT        AS monthly_rent,
 
s.value:is_active::BOOLEAN         AS is_active,
 
TO_DATE(s.value:opening_date::STRING,'YYYY-MM-DD') AS opening_date,
TO_DATE(s.value:last_modified_date::STRING,'YYYY-MM-DD') AS last_modified_date,
 
-- address
s.value:address.city::STRING       AS city,
s.value:address.state::STRING      AS state,
s.value:address.country::STRING    AS country,
s.value:address.street::STRING     AS street,
s.value:address.zip_code::STRING   AS zip_code,
 
-- operating hours
s.value:operating_hours.weekdays::STRING AS weekday_hours,
s.value:operating_hours.weekends::STRING AS weekend_hours,
s.value:operating_hours.holidays::STRING AS holiday_hours,
 
-- services array
ARRAY_TO_STRING(s.value:services, ', ') AS services
 
FROM {{ source('bronze','ext_store_data') }},
LATERAL FLATTEN(input => VALUE:stores_data) s