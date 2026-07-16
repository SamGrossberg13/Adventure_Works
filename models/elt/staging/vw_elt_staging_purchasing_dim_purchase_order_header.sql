with
    purchaseorder as (
    select * from {{ ref('vw_stg_purchasing_purchaseorderheader') }}
    qualify row_number() over (
        partition by "PurchaseOrderID"
        order by "PurchaseOrderID"
    ) = 1),

final as (
        select
            {{ dbt_utils.generate_surrogate_key(['"PurchaseOrderID"']) }}
                as purchase_order_header_sk,
            "PurchaseOrderID"::number as purchase_order_id_bk,
            "Status"::number as purchase_order_status,

            "SubTotal"::number as sub_total,
            "TaxAmt"::number as tax_amt,
            "Freight"::number as freight,
            "TotalDue"::number as total_due

        from purchaseorder)

select *
from final    