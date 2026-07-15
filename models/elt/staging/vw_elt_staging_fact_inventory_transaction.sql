with

    transaction_history as (
        select *
        from {{ ref('vw_stg_production_transactionhistory') }}
        qualify row_number() over (
            partition by "TransactionID"
            order by "TransactionID"
        ) = 1),
    dim_product as (
        select *
        from {{ ref('vw_elt_staging_production_dim_product') }}),
    dim_transaction_date as (
        select *
        from {{ ref('vw_elt_staging_dim_date') }}),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['t."TransactionID"']) }} as inventory_transaction_sk,

            p.product_sk as product_sk,

            t."TransactionID"::number as transaction_id,
            t."ReferenceOrderID"::number as reference_order_id,
            t."ReferenceOrderLineID"::number as reference_order_line_id,
            td.date_sk as transaction_date_sk,
            t."TransactionType"::varchar as transaction_type,
            t."Quantity"::number as quantity,
            t."ActualCost"::number(18,2) as actual_cost,

            'ADVENTURE_WORKS'::varchar
                as source_system,
            sysdate()
                as elt_process_datetime

        from transaction_history t
        left join dim_product p
            on t."ProductID" = p.product_id_bk
        left join dim_transaction_date td
            on cast(t."TransactionDate" as date) = td.calendar_date)


select *
from final