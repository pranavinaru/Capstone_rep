{% snapshot snp_customer_data %}
 
{{
config(
target_database='capstone',
target_schema='bronze',
unique_key='customer_id',
strategy='timestamp',
updated_at='last_modified_date'
)
}}
 
SELECT *
FROM {{ ref('bronze_customer_data') }}
QUALIFY ROW_NUMBER() OVER(
PARTITION BY customer_id
ORDER BY last_modified_date DESC
)=1
 
{% endsnapshot %}