{{ config(materialized='table') }}
{{ config(unique_key=["customer_key"]) }}

select
    customer_sk,
    customer_id,
    person_id,
    store_id,
    territory_id,
    account_number,
    customer_type

from {{ ref('vw_elt_staging_sales_dim_customer') }}