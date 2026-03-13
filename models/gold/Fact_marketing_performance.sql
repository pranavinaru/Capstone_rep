WITH campaign_sales AS (
 
SELECT
 
c.campaignkey,
d.datekey,
f.customerkey,
 
SUM(f.total_sales_amount) AS total_sales_influenced
 
FROM {{ ref('Fact_sales') }} f
 
JOIN {{ ref('Dim_campaign') }} c
ON f.campaignkey = c.campaignkey
 
JOIN {{ ref('Dim_Date') }} d
ON f.datekey = d.datekey
 
WHERE d.full_date BETWEEN c.start_date AND c.end_date
 
GROUP BY
c.campaignkey,
d.datekey,
f.customerkey
 
),
 
first_purchase AS (
 
SELECT
customerkey,
MIN(datekey) AS first_purchase_date
FROM {{ ref('Fact_sales') }}
GROUP BY customerkey
 
),
 
new_customers AS (
 
SELECT
 
cs.campaignkey,
cs.datekey,
 
COUNT(DISTINCT cs.customerkey) AS new_customers_acquired
 
FROM campaign_sales cs
 
JOIN first_purchase fp
ON cs.customerkey = fp.customerkey
 
WHERE cs.datekey = fp.first_purchase_date
 
GROUP BY
cs.campaignkey,
cs.datekey
 
),
 
repeat_purchase AS (
 
SELECT
 
campaignkey,
datekey,
 
COUNT(DISTINCT customerkey) AS repeat_customers
 
FROM campaign_sales
 
GROUP BY campaignkey, datekey
 
),
 
final_marketing AS (
 
SELECT

cs.customerkey,
cs.campaignkey,
cs.datekey,
 
SUM(cs.total_sales_influenced) AS total_sales_influenced,
 
COALESCE(nc.new_customers_acquired,0) AS new_customers_acquired,
 
CASE
WHEN COUNT(DISTINCT cs.customerkey) > 0
THEN (COALESCE(rp.repeat_customers,0) * 100.0) / COUNT(DISTINCT cs.customerkey)
ELSE NULL
END AS repeat_purchase_rate,
 
/* ROI */
 
CASE
WHEN c.budget > 0
THEN ((SUM(cs.total_sales_influenced) - c.budget) / c.budget) * 100
ELSE NULL
END AS roi_percentage
 
FROM campaign_sales cs
 
LEFT JOIN new_customers nc
ON cs.campaignkey = nc.campaignkey
AND cs.datekey = nc.datekey
 
LEFT JOIN repeat_purchase rp
ON cs.campaignkey = rp.campaignkey
AND cs.datekey = rp.datekey
 
JOIN {{ ref('Dim_campaign') }} c
ON cs.campaignkey = c.campaignkey
 
GROUP BY
cs.campaignkey,
cs.customerkey,
cs.datekey,
nc.new_customers_acquired,
rp.repeat_customers,
c.budget
 
)
 
SELECT *
FROM final_marketing