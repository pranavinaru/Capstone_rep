WITH dates AS (
    SELECT DISTINCT
        DATE(order_date) AS full_date
    FROM {{ ref('silver_orders_data') }}
)

SELECT
    TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS datekey,
    full_date,
    YEAR(full_date) AS year,
    QUARTER(full_date) AS quarter,
    MONTH(full_date) AS month,
    WEEK(full_date) AS week,
    DAYNAME(full_date) AS day_of_week,
    CASE
        WHEN TO_CHAR(full_date, 'MM-DD') IN ('01-01', '07-04', '12-25') THEN TRUE
        ELSE FALSE
    END AS holiday_flag,
    CASE
        WHEN MONTH(full_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(full_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(full_date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season
FROM dates