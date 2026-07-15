{{ config(materialized='table') }}
{{ config(unique_key=["territory_sk"]) }}

select

    territory_sk,
    territory_id,
    territory_name,
    country_region_code,
    territory_group,
    sales_ytd,
    sales_last_year,
    cost_ytd,
    cost_last_year

from {{ ref('vw_elt_staging_sales_dim_salesterritory') }}