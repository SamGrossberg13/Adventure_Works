{{ config(materialized='table') }}
{{ config(unique_key=["vendor_sk"]) }}

select
    vendor_sk,
    business_entity_id,
    vendor_account_number,
    vendor_name,
    credit_rating,
    preferred_vendor_status,
    active_flag,
    purchasing_web_service_url

from {{ ref('vw_elt_staging_purchasing_dim_vendor') }}