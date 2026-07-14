with

    sales_order_header as (
        select *
        from {{ ref('vw_stg_sales_salesorderheader') }}
        qualify row_number() over (
            partition by "SalesOrderID"
            order by "SalesOrderID"
        ) = 1),
    sales_order_detail as (
        select *
        from {{ ref('vw_stg_sales_salesorderdetail') }}
        qualify row_number() over (
            partition by "SalesOrderID", "SalesOrderDetailID"
            order by "SalesOrderID", "SalesOrderDetailID"
        ) = 1),
    dim_customer as (
        select *
        from {{ ref('vw_elt_staging_sales_dim_customer') }}),
    dim_product as (
        select *
        from {{ ref('vw_elt_staging_production_dim_product') }}),
    dim_salesperson as (
        select *
        from {{ ref('vw_elt_staging_sales_dim_salesperson') }}),
    dim_territory as (
        select *
        from {{ ref('vw_elt_staging_sales_dim_salesterritory') }}),
    dim_special_offer as (
        select *
        from {{ ref('vw_elt_staging_sales_dim_special_offer') }}),
    dim_ship_method as (
        select *
        from {{ ref('vw_elt_staging_purchasing_dim_ship_method') }}),
    dim_bill_to_address as (
        select *
        from {{ ref('vw_elt_staging_person_dim_address') }}),
    dim_ship_to_address as (
        select *
        from {{ ref('vw_elt_staging_person_dim_address') }}),
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
            {{ dbt_utils.generate_surrogate_key(['sod."SalesOrderID"','sod."SalesOrderDetailID"']) }} as sales_fact_sk,
            
            od.date_sk as order_date_sk,
            dd.date_sk as due_date_sk,
            sd.date_sk as ship_date_sk,

            c.customer_sk as customer_sk,
            p.product_sk as product_sk,
            sp.salesperson_sk as salesperson_sk,
            t.territory_sk as territory_sk,
            so.special_offer_sk as special_offer_sk,
            sm.ship_method_sk as ship_method_sk,
            bta.address_sk as bill_to_address_sk,
            sta.address_sk as ship_to_address_sk,

            soh."SalesOrderID"::number as sales_order_id,
            sod."SalesOrderDetailID"::number as sales_order_detail_id,
            soh."SalesOrderNumber"::varchar as sales_order_number,
            soh."PurchaseOrderNumber"::varchar as purchase_order_number,
            soh."AccountNumber"::varchar as account_number,
            concat(
                soh."SalesOrderID",
                '-',
                sod."SalesOrderDetailID"
            ) as sales_order_line_id_bk,
            soh."Status"::number as order_status,
            soh."OnlineOrderFlag"::boolean as online_order_flag,
            soh."CreditCardID"::number as credit_card_id,

            sod."OrderQty"::number as order_qty,
            sod."UnitPrice"::number(18,2) as unit_price,
            sod."UnitPriceDiscount"::number(18,4)
                as unit_price_discount,
            sod."LineTotal"::number(18,2)
                as line_total,
            (sod."OrderQty"* sod."UnitPrice")::number(18,2)
                as gross_sales_amount,
            (sod."OrderQty"* sod."UnitPrice"* sod."UnitPriceDiscount")::number(18,2)
                as discount_amount,
            sod."LineTotal"::number(18,2)
                as net_sales_amount,

            'ADVENTURE_WORKS'::varchar
                as source_system,
            sysdate()
                as elt_process_datetime

        from sales_order_detail sod
        left join sales_order_header soh
            on sod."SalesOrderID" = soh."SalesOrderID"
        left join dim_customer c
            on soh."CustomerID" = c.customer_id
        left join dim_product p
            on sod."ProductID" = p.product_id_bk
        left join dim_salesperson sp
            on soh."SalesPersonID" = sp.business_entity_id
        left join dim_territory t
            on soh."TerritoryID" = t.territory_id
        left join dim_special_offer so
            on sod."SpecialOfferID" = so.special_offer_id
        left join dim_ship_method sm
            on soh."ShipMethodID" = sm.ship_method_id
        left join dim_bill_to_address bta
            on soh."BillToAddressID" = bta.address_id
        left join dim_ship_to_address sta
            on soh."ShipToAddressID" = sta.address_id
        left join dim_order_date od
            on cast(soh."OrderDate" as date) = od.calendar_date
        left join dim_due_date dd
            on cast(soh."DueDate" as date) = dd.calendar_date
        left join dim_ship_date sd
            on cast(soh."ShipDate" as date) = sd.calendar_date)

select *
from final