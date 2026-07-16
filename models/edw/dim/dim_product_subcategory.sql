{{ config(materialized='table') }}
{{ config(unique_key=["product_subcategory_sk"]) }}

select *

from {{ ref('vw_elt_staging_production_dim_product_subcategory') }}