{{ config(materialized='table') }}
{{ config(unique_key=["address_sk"]) }}

select

    address_sk,
    address_id,
    address_line_1,
    address_line_2,
    city,
    state_province_id,
    state_province_code,
    state_province_name,
    postal_code,
    territory_id

from {{ ref('vw_elt_staging_person_dim_address') }}