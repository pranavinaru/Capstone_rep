SELECT
    ROW_NUMBER() OVER (ORDER BY supplier_id, dbt_valid_from) AS SupplierKey,
    supplier_id AS SupplierID,
    supplier_name AS SupplierName,
    valid_contact_email AS Contact_Email,
    valid_phone AS Contact_Phone,
    payment_terms AS Payment_Terms,
    supplier_type AS Supplier_Type
FROM {{ ref('silver_supplier_data') }}