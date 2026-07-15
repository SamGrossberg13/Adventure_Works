{{ config(materialized='table') }}
{{ config(unique_key=["special_offer_sk"]) }}

select

    special_offer_sk,
    special_offer_id,
    offer_description,
    discount_pct,
    offer_type,
    offer_category,
    offer_start_date,
    offer_end_date,
    min_quantity,
    max_quantity

from {{ ref('vw_elt_staging_sales_dim_special_offer') }}