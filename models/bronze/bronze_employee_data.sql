SELECT
    f.value:employee_id::STRING            AS employee_id,
    f.value:first_name::STRING             AS first_name,
    f.value:last_name::STRING              AS last_name,
    f.value:email::STRING                  AS email,
    f.value:phone::STRING                  AS phone,

    -- flexible date conversion
    COALESCE(
        TRY_TO_DATE(f.value:date_of_birth::STRING,'YYYY-MM-DD'),
        TRY_TO_DATE(f.value:date_of_birth::STRING,'DD-MM-YYYY')
    ) AS date_of_birth,

    TRY_TO_DATE(f.value:hire_date::STRING)           AS hire_date,
    TRY_TO_DATE(f.value:last_modified_date::STRING)  AS last_modified_date,

    f.value:department::STRING           AS department,
    f.value:role::STRING                 AS role,
    f.value:education::STRING            AS education,
    f.value:employment_status::STRING    AS employment_status,
    f.value:manager_id::STRING           AS manager_id,
    f.value:work_location::STRING        AS work_location,

    f.value:salary::FLOAT                AS salary,
    f.value:performance_rating::FLOAT    AS performance_rating,
    f.value:current_sales::FLOAT         AS current_sales,
    f.value:sales_target::FLOAT          AS sales_target,

    -- nested address fields
    f.value:address.city::STRING         AS city,
    f.value:address.state::STRING        AS state,
    f.value:address.street::STRING       AS street,
    f.value:address.zip_code::STRING     AS zip_code,

    -- array field
    f.value:certifications               AS certifications

FROM {{ source('bronze','ext_employee_data') }},
LATERAL FLATTEN(input => VALUE:employees_data) f