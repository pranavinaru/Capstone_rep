WITH source_data AS (
    SELECT *
    FROM {{ ref('snp_campaign_data') }}
    WHERE dbt_valid_to IS NULL
),

cleaned AS (
    SELECT
        TRIM(campaign_id) AS campaign_id,

        INITCAP(TRIM(campaign_name)) AS campaign_name,
        UPPER(TRIM(campaign_type)) AS campaign_type,
        UPPER(TRIM(channel)) AS channel,
        INITCAP(TRIM(description)) AS description,

        TRY_TO_DATE(start_date) AS start_date,
        TRY_TO_DATE(end_date) AS end_date,
        TRY_TO_DATE(last_modified_date) AS last_modified_date,

        CASE
            WHEN TRY_TO_DATE(start_date) IS NOT NULL
                 AND TRY_TO_DATE(end_date) IS NOT NULL
            THEN DATEDIFF(day, TRY_TO_DATE(start_date), TRY_TO_DATE(end_date))
            ELSE NULL
        END AS campaign_duration_days,

        INITCAP(TRIM(target_audience)) AS target_audience,

        CASE
            WHEN LOWER(target_audience) LIKE '%young%' THEN 'Young Audience'
            WHEN LOWER(target_audience) LIKE '%professional%' THEN 'Working Professionals'
            WHEN LOWER(target_audience) LIKE '%senior%' THEN 'Senior Audience'
            ELSE 'General'
        END AS audience_segment,

        TRY_TO_NUMBER(REGEXP_REPLACE(budget,'[^0-9.]','')) AS budget,
        TRY_TO_NUMBER(REGEXP_REPLACE(total_cost,'[^0-9.]','')) AS total_cost,
        TRY_TO_NUMBER(REGEXP_REPLACE(total_revenue,'[^0-9.]','')) AS total_revenue,

        CASE
            WHEN TRY_TO_NUMBER(REGEXP_REPLACE(total_cost,'[^0-9.]','')) > 0
            THEN (
                TRY_TO_NUMBER(REGEXP_REPLACE(total_revenue,'[^0-9.]','')) -
                TRY_TO_NUMBER(REGEXP_REPLACE(total_cost,'[^0-9.]',''))
            )
            / NULLIF(TRY_TO_NUMBER(REGEXP_REPLACE(total_cost,'[^0-9.]','')),0)
            ELSE NULL
        END AS expected_roi,

        TRY_TO_NUMBER(roi_calculation) AS roi_calculation,

        CASE
            WHEN TRY_TO_NUMBER(roi_calculation) IS NULL THEN 'Missing ROI'
            WHEN ABS(
                TRY_TO_NUMBER(roi_calculation) -
                (
                    (
                        TRY_TO_NUMBER(REGEXP_REPLACE(total_revenue,'[^0-9.]','')) -
                        TRY_TO_NUMBER(REGEXP_REPLACE(total_cost,'[^0-9.]',''))
                    )
                    / NULLIF(TRY_TO_NUMBER(REGEXP_REPLACE(total_cost,'[^0-9.]','')),0)
                )
            ) < 0.01
            THEN 'Valid'
            ELSE 'Mismatch'
        END AS roi_validation_status,

        dbt_valid_from,
        dbt_valid_to,
        dbt_updated_at

    FROM source_data
)

SELECT *
FROM cleaned