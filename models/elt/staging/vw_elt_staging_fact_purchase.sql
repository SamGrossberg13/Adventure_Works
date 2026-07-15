with

    purchase_order_header as (
        select *
        from {{ ref('vw_stg_purchasing_purchaseorderheader') }}
        qualify row_number() over (
            partition by "PurchaseOrderID"
            order by "PurchaseOrderID"
        ) = 1),
    purchase_order_detail as (
        select *
        from {{ ref('vw_stg_purchasing_purchaseorderdetail') }}
        qualify row_number() over (
            partition by "PurchaseOrderID", "PurchaseOrderDetailID"
            order by "PurchaseOrderID", "PurchaseOrderDetailID"
        ) = 1),
    dim_product as (
        select *
        from {{ ref('vw_elt_staging_production_dim_product') }}),
    dim_vendor as (
        select *
        from {{ ref('vw_elt_staging_purchasing_dim_vendor') }}),
    dim_ship_method as (
        select *
        from {{ ref('vw_elt_staging_purchasing_dim_ship_method') }}),
    dim_order_date as (
        select *
        from {{ ref('vw_elt_staging_dim_date') }}),
    dim_due_date as (
        select *
        from {{ ref('vw_elt_staging_dim_date') }}),
    dim_ship_date as (
        select *
        from {{ ref('vw_elt_staging_dim_date') }}),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['pod."PurchaseOrderID"','pod."PurchaseOrderDetailID"']) }} as purchase_order_sk,
            
            od.date_sk as order_date_sk,
            dd.date_sk as due_date_sk,
            sd.date_sk as ship_date_sk,

            p.product_sk as product_sk,
            v.vendor_sk as vendor_sk,
            sm.ship_method_sk as ship_method_sk,

            poh."PurchaseOrderID"::number as purchase_order_id,
            pod."PurchaseOrderDetailID"::number as purchase_order_detail_id,
            concat(
                poh."PurchaseOrderID",
                '-',
                pod."PurchaseOrderDetailID"
            ) as purchase_order_line_id_bk,


            pod."OrderQty"::number as purchase_order_qty,
            pod."UnitPrice"::number(18,2) as purchase_unit_price,
            pod."LineTotal"::number(18,2)
                as purchase_line_total,
            pod."ReceivedQty"::number as received_qty,
            pod."RejectedQty"::number as rejected_qty,
            pod."StockedQty"::number as stocked_qty,
            poh."SubTotal"::number(18,2) as order_subtotal,
            poh."TaxAmt"::number(18,2) as tax_amount,
            poh."Freight"::number(18,2) as freight_amount,
            poh."TotalDue"::number(18,2) as total_due,


            'ADVENTURE_WORKS'::varchar
                as source_system,
            sysdate()
                as elt_process_datetime

        from purchase_order_detail pod
        left join purchase_order_header poh
            on pod."PurchaseOrderID" = poh."PurchaseOrderID"
        left join dim_product p
            on pod."ProductID" = p.product_id_bk
        left join dim_ship_method sm
            on poh."ShipMethodID" = sm.ship_method_id
        left join dim_vendor v 
            on poh."VendorID" = v.business_entity_id
        left join dim_order_date od
            on cast(poh."OrderDate" as date) = od.calendar_date
        left join dim_due_date dd
            on cast(pod."DueDate" as date) = dd.calendar_date
        left join dim_ship_date sd
            on cast(poh."ShipDate" as date) = sd.calendar_date)

select *
from final