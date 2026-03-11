{% macro create_external_tables(stage_name, base_path, tables) %}
 
{% for table in tables %}
 
{% set sql %}
 
CREATE OR REPLACE EXTERNAL TABLE BRONZE.ext_{{ table }}
WITH LOCATION = @{{ stage_name }}/{{ base_path }}/{{ table }}/
AUTO_REFRESH = FALSE
FILE_FORMAT = (TYPE = JSON);
 
{% endset %}
 
{{ log("Creating external table: ext_" ~ table, info=True) }}
 
{{ run_query(sql) }}
 
{% endfor %}
 
{% endmacro %}