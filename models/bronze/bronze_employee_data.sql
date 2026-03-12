SELECT
 
e.value:employee_id::STRING AS employee_id,
e.value:first_name::STRING AS first_name,
e.value:last_name::STRING AS last_name,
e.value:email::STRING AS email,
e.value:phone::STRING AS phone,
 
e.value:department::STRING AS department,
e.value:role::STRING AS role,
e.value:manager_id::STRING AS manager_id,
e.value:employment_status::STRING AS employment_status,
 
-- Dates kept as STRING
e.value:hire_date::STRING AS hire_date,
e.value:date_of_birth::STRING AS date_of_birth,
e.value:last_modified_date::STRING AS last_modified_date,
 
-- Numeric values stored as STRING
e.value:salary::STRING AS salary,
e.value:performance_rating::STRING AS performance_rating,
e.value:sales_target::STRING AS sales_target,
e.value:current_sales::STRING AS current_sales,
 
e.value:education::STRING AS education,
e.value:work_location::STRING AS work_location,
 
-- address fields
e.value:address.city::STRING AS city,
e.value:address.state::STRING AS state,
e.value:address.street::STRING AS street,
e.value:address.zip_code::STRING AS zip_code,
 
-- certifications array converted to STRING
ARRAY_TO_STRING(e.value:certifications, ', ') AS certifications
 
FROM {{ source('bronze','ext_employee_data') }},
LATERAL FLATTEN(input => VALUE:employees_data) e