SELECT
    f.value:campaign_id::STRING        AS campaign_id,
    f.value:campaign_name::STRING      AS campaign_name,
    f.value:campaign_type::STRING      AS campaign_type,
    f.value:channel::STRING            AS channel,
    f.value:description::STRING        AS description,
    f.value:start_date::TIMESTAMP      AS start_date,
    f.value:end_date::TIMESTAMP        AS end_date,
    f.value:last_modified_date::DATE   AS last_modified_date,
    f.value:roi_calculation::FLOAT     AS roi_calculation,
    f.value:target_audience::STRING    AS target_audience,
    f.value:budget::STRING             AS budget,
    f.value:total_cost::STRING         AS total_cost,
    f.value:total_revenue::STRING      AS total_revenue
FROM {{ source('bronze','ext_campaign_data') }},
LATERAL FLATTEN(input => VALUE:campaigns_data) f