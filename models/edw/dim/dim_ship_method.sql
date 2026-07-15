{{ config(materialized='table') }}
{{ config(unique_key=["ship_method_sk"]) }}

select

    ship_method_sk,
    ship_method_id,
    ship_method_name,
    ship_base,
    ship_rate

from {{ ref('vw_elt_staging_purchasing_dim_ship_method') }}