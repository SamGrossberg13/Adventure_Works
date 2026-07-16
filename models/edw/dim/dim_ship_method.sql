{{ config(materialized='table') }}
{{ config(unique_key=["ship_method_sk"]) }}

select *

from {{ ref('vw_elt_staging_purchasing_dim_ship_method') }}