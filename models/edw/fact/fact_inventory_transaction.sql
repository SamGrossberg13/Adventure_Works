{{ config(materialized='table') }}
{{ config(unique_key=["inventory_transaction_sk"]) }}

select *

from {{ ref('vw_elt_staging_fact_inventory_transaction') }}