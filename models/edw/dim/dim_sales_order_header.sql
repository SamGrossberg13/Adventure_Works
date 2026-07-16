{{ config(materialized='table') }}
{{ config(unique_key=["sales_order_header_sk"]) }}

select *

from {{ ref('vw_elt_staging_sales_dim_sales_order_header') }}