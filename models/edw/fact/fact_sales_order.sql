{{ config(materialized='table') }}
{{ config(unique_key=["sales_fact_sk"]) }}

select *

from {{ ref('vw_elt_staging_fact_sales') }}