{{ config(materialized='view') }}
 
SELECT c.campaign_type,
       AVG(f.roi_percentage) AS avg_roi_percentage 
FROM {{ ref('Fact_marketing_performance') }} f
JOIN {{ ref('Dim_campaign') }} c
ON f.campaignkey = c.campaignkey
GROUP BY c.campaign_type
ORDER BY avg_roi_percentage DESC