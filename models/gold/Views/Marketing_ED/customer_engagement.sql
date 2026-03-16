{{ config(materialized='view') }}
 
SELECT c.campaign_name,
       SUM(f.new_customers_acquired) AS new_customers, 
       AVG(f.repeat_purchase_rate) AS avg_repeat_purchase_rate
FROM {{ ref('Fact_marketing_performance') }} f
JOIN {{ ref('Dim_campaign')}} c
ON f.campaignkey = c.campaignkey
GROUP BY c.campaign_name
ORDER BY new_customers DESC
 