WITH source_data AS (
    SELECT *
    FROM {{ ref('snp_employee_data') }}
    WHERE dbt_valid_to IS NULL
),

clean_employee AS (
    SELECT
        TRIM(employee_id) AS employee_id,

        INITCAP(TRIM(first_name)) AS first_name,
        INITCAP(TRIM(last_name)) AS last_name,
        INITCAP(TRIM(first_name)) || ' ' || INITCAP(TRIM(last_name)) AS full_name,

        INITCAP(TRIM(department)) AS department,
        INITCAP(TRIM(role)) AS role,
        TRIM(manager_id) AS manager_id,
        INITCAP(TRIM(employment_status)) AS employment_status,

        TRY_TO_DATE(hire_date) AS hire_date,

        COALESCE(
            TRY_TO_DATE(date_of_birth,'DD-MM-YYYY'),
            TRY_TO_DATE(date_of_birth,'YYYY-MM-DD'),
            TRY_TO_DATE(date_of_birth,'MM/DD/YYYY')
        ) AS date_of_birth,

        TRY_TO_DATE(last_modified_date) AS last_modified_date,

        DATEDIFF(year, TRY_TO_DATE(hire_date), CURRENT_DATE) AS tenure_years,

        COALESCE(TRY_TO_NUMBER(salary),0) AS salary,
        performance_rating,
        TRY_TO_NUMBER(sales_target) AS sales_target,
        TRY_TO_NUMBER(current_sales) AS current_sales,

        INITCAP(TRIM(education)) AS education,
        INITCAP(TRIM(work_location)) AS work_location,

        INITCAP(TRIM(city)) AS city,
        UPPER(TRIM(state)) AS state,
        INITCAP(TRIM(street)) AS street,
        TRIM(zip_code) AS zip_code,

        certifications,

        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at,

        CASE
            WHEN LOWER(role) LIKE '%sales associate%' THEN 'Associate'
            WHEN LOWER(role) LIKE '%store manager%' THEN 'Manager'
            WHEN LOWER(role) LIKE '%senior manager%' THEN 'Senior Manager'
            ELSE INITCAP(TRIM(role))
        END AS standardized_role,

        LOWER(TRIM(email)) AS email,

        CASE
            WHEN LOWER(TRIM(email)) RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            THEN LOWER(TRIM(email))
            ELSE NULL
        END AS valid_email,

        REGEXP_REPLACE(phone,'[^0-9]','') AS phone_number,

        '+1' || REGEXP_REPLACE(
            REGEXP_REPLACE(phone,'[^0-9]',''),
            '^1555',''
        ) AS valid_phone

    FROM source_data
),

employee_sales AS (
    SELECT
        employee_id,
        COUNT(order_id) AS orders_processed,
        SUM(total_amount) AS total_sales_amount
    FROM {{ ref('silver_orders_data') }}
    GROUP BY employee_id
),

employee_final AS (
    SELECT
        e.*,
        s.orders_processed,
        s.total_sales_amount,
        CASE
            WHEN e.sales_target > 0
            THEN (s.total_sales_amount / e.sales_target) * 100
            ELSE NULL
        END AS target_achievement_percentage
    FROM clean_employee e
    LEFT JOIN employee_sales s
        ON e.employee_id = s.employee_id
)

SELECT *
FROM employee_final