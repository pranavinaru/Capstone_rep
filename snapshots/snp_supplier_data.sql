{% snapshot snp_supplier_data %}
 
{{
config(
target_database='capstone',
target_schema='bronze',
unique_key='supplier_id',
strategy='timestamp',
updated_at='last_modified_date'
)
}}
 
SELECT *
FROM {{ ref('bronze_supplier_data') }}
 
QUALIFY ROW_NUMBER() OVER(
PARTITION BY supplier_id
ORDER BY last_modified_date DESC
)=1
 
{% endsnapshot %}
