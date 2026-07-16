with
    salesorder as (
    select * from {{ ref('vw_stg_sales_salesorderheader') }}
    qualify row_number() over (
        partition by "SalesOrderID"
        order by "SalesOrderID"
    ) = 1),

final as (
        select
            {{ dbt_utils.generate_surrogate_key(['"SalesOrderID"']) }}
                as sales_order_header_id,
            "SalesOrderID"::number as sales_order_id_bk,
            "SalesOrderNumber"::varchar as sales_order_number,
            "PurchaseOrderNumber"::varchar as purchase_order_number,
            "AccountNumber"::varchar as account_number,
            "Status"::number as order_status,
            "OnlineOrderFlag"::boolean as online_order_flag,
            "CreditCardID"::number as credit_card_id,

            "SubTotal"::number as sub_total,
            "TaxAmt"::number as tax_amt,
            "Freight"::number as freight,
            "TotalDue"::number as total_due

        from salesorder)

select *
from final    