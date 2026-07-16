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

    product as (
        select *
        from {{ ref('vw_stg_production_product') }}
        qualify row_number() over (
            partition by "ProductID"
            order by "ProductID"
        ) = 1),

    product_subcategory as (
        select *
        from {{ ref('vw_stg_production_productsubcategory') }}
        qualify row_number() over (
            partition by "ProductSubcategoryID"
            order by "ProductSubcategoryID"
        ) = 1),

    final as (
        select

            -- Fact surrogate key: one row per purchase order detail line
            {{ dbt_utils.generate_surrogate_key([
                'pod."PurchaseOrderID"',
                'pod."PurchaseOrderDetailID"']) }} as purchase_order_fact_sk,

            -- Purchase order header dimension key
            {{ dbt_utils.generate_surrogate_key([
                'poh."PurchaseOrderID"']) }} as purchase_order_header_sk,

            -- Date dimension keys
            {{ dbt_utils.generate_surrogate_key([
                'cast(poh."OrderDate" as date)']) }} as order_date_sk,

            {{ dbt_utils.generate_surrogate_key([
                'cast(pod."DueDate" as date)']) }} as due_date_sk,

            case
                when poh."ShipDate" is null then null
                else {{ dbt_utils.generate_surrogate_key([
                    'cast(poh."ShipDate" as date)']) }} end as ship_date_sk,

            -- Direct dimension surrogate keys generated from source business keys
            {{ dbt_utils.generate_surrogate_key(['pod."ProductID"']) }} as product_sk,

            {{ dbt_utils.generate_surrogate_key(['p."ProductSubcategoryID"']) }} as product_subcategory_sk,

            {{ dbt_utils.generate_surrogate_key(['ps."ProductCategoryID"']) }} as product_category_sk,

            {{ dbt_utils.generate_surrogate_key(['poh."VendorID"']) }} as vendor_sk,

            {{ dbt_utils.generate_surrogate_key(['poh."ShipMethodID"']) }} as ship_method_sk,


            -- Business/source identifiers for traceability
            poh."PurchaseOrderID"::number as purchase_order_id,
            pod."PurchaseOrderDetailID"::number as purchase_order_detail_id,

            concat(poh."PurchaseOrderID", '-', pod."PurchaseOrderDetailID")::varchar as purchase_order_line_id_bk,

            pod."OrderQty"::number as purchase_order_qty,
            pod."UnitPrice"::number(18, 2) as purchase_unit_price,
            pod."LineTotal"::number(18, 2) as purchase_line_total,
            pod."ReceivedQty"::number as received_qty,
            pod."RejectedQty"::number as rejected_qty,
            pod."StockedQty"::number as stocked_qty,

            -- Derived measures
            (pod."OrderQty"* pod."UnitPrice")::number(18, 2) as gross_purchase_amount,
            pod."LineTotal"::number(18, 2) as net_purchase_amount,

            -- Metadata
            'ADVENTURE_WORKS'::varchar as source_system,

            sysdate() as elt_process_datetime

        from purchase_order_detail pod

        left join purchase_order_header poh
            on pod."PurchaseOrderID" = poh."PurchaseOrderID"

        left join product p
            on pod."ProductID" = p."ProductID"

        left join product_subcategory ps
            on p."ProductSubcategoryID" = ps."ProductSubcategoryID"

    )

select *
from final