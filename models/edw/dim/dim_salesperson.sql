{{ config(materialized='table') }}
{{ config(unique_key=["salesperson_sk"]) }}

select
    salesperson_sk,
    business_entity_id,
    territory_id,
    first_name,
    middle_name,
    last_name,
    full_name,
    job_title,
    sales_quota,
    bonus,
    commission_pct,
    sales_ytd,
    sales_last_year,
    territory_name,
    territory_group

from {{ ref('vw_elt_staging_sales_dim_salesperson') }}