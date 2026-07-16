with

    transaction_history as (
        select *
        from {{ ref('vw_stg_production_transactionhistory') }}
        qualify row_number() over (
            partition by "TransactionID"
            order by "TransactionID") = 1),

    product as (
        select *
        from {{ ref('vw_stg_production_product') }}
        qualify row_number() over (
            partition by "ProductID"
            order by "ProductID") = 1),

    product_subcategory as (
        select *
        from {{ ref('vw_stg_production_productsubcategory') }}
        qualify row_number() over (
            partition by "ProductSubcategoryID"
            order by "ProductSubcategoryID") = 1),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['th."TransactionID"']) }} as inventory_transaction_fact_sk,

            {{ dbt_utils.generate_surrogate_key(['cast(th."TransactionDate" as date)']) }} as transaction_date_sk,

            {{ dbt_utils.generate_surrogate_key(['th."ProductID"']) }} as product_sk,

            case
                when p."ProductSubcategoryID" is null then null
                else {{ dbt_utils.generate_surrogate_key([
                    'p."ProductSubcategoryID"']) }} end as product_subcategory_sk,

            case
                when ps."ProductCategoryID" is null then null
                else {{ dbt_utils.generate_surrogate_key([
                    'ps."ProductCategoryID"']) }} end as product_category_sk,

            -- Source identifiers / degenerate dimensions
            th."TransactionID"::number as transaction_id,
            th."ReferenceOrderID"::number as reference_order_id,
            th."ReferenceOrderLineID"::number as reference_order_line_id,
            concat(
                th."ReferenceOrderID", '-', th."ReferenceOrderLineID")::varchar as reference_order_line_id_bk,
            th."TransactionType"::varchar as transaction_type,
            
            th."Quantity"::number as transaction_quantity,
            th."ActualCost"::number(18, 2) as actual_cost,
            (th."Quantity"* th."ActualCost")::number(18, 2) as transaction_cost_amount,

            -- Metadata
            th."ModifiedDate"::timestamp as modified_datetime,

            'ADVENTURE_WORKS'::varchar as source_system,
            sysdate() as elt_process_datetime

        from transaction_history th
        left join product p
            on th."ProductID" = p."ProductID"
        left join product_subcategory ps
            on p."ProductSubcategoryID" = ps."ProductSubcategoryID"

    )

select *
from final