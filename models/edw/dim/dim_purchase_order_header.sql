{{ config(materialized='table') }}
{{ config(unique_key=["purchase_order_header_sk"]) }}

select *

from {{ ref('vw_elt_staging_purchasing_dim_purchase_order_header') }}