{{ config(materialized='table') }}
{{ config(unique_key=["product_category_sk"]) }}

select *

from {{ ref('vw_elt_staging_production_dim_product_category') }}