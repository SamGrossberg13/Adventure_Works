{{ config(materialized='table') }}
{{ config(unique_key=["purchase_order_sk"]) }}

select *

from {{ ref('vw_elt_staging_fact_purchase') }}