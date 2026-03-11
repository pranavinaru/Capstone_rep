{% snapshot snp_campaign_data %}
 
{{
config(
target_database='capstone',
target_schema='bronze',
unique_key='campaign_id',
strategy='timestamp',
updated_at='last_modified_date'
)
}}
 
SELECT *
FROM {{ ref('bronze_campaign_data') }}
 
QUALIFY ROW_NUMBER() OVER(
PARTITION BY campaign_id
ORDER BY last_modified_date DESC
)=1
 
{% endsnapshot %}