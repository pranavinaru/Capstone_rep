SELECT
    ROW_NUMBER() OVER (ORDER BY employee_id, dbt_valid_from) AS EmployeeKey,
    employee_id AS EmployeeID,
    first_name || ' ' || last_name AS Full_Name,
    standardized_role AS Role,
    tenure_years AS Tenure,
    valid_email AS EmailID,
    valid_phone AS PhoneNumber,
    work_location AS Work_Location,
    sales_target AS Sales_Target,
    orders_processed AS Orders_Processed,
    total_sales_amount AS Total_Sales,
    target_achievement_percentage AS Taget_Achievement_Percentage
FROM {{ ref('silver_employee_data') }}