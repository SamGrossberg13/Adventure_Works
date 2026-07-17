with

    sales_order_header as (
        select *
        from {{ ref('vw_stg_sales_salesorderheader') }}
        qualify row_number() over (
            partition by "SalesOrderID"
            order by "SalesOrderID") = 1),
    sales_order_detail as (
        select *
        from {{ ref('vw_stg_sales_salesorderdetail') }}
        qualify row_number() over (
            partition by "SalesOrderID", "SalesOrderDetailID"
            order by "SalesOrderID", "SalesOrderDetailID") = 1),
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
            order by "ProductSubcategoryID"
        ) = 1),

    final as (

        select

            -- Fact surrogate key: one row per sales order detail line
            {{ dbt_utils.generate_surrogate_key(['sod."SalesOrderID"', 'sod."SalesOrderDetailID"']) }} as sales_fact_sk,

            -- Sales order header dimension key
            {{ dbt_utils.generate_surrogate_key(['soh."SalesOrderID"']) }} as sales_order_header_sk,

            -- Date dimension keys
            {{ dbt_utils.generate_surrogate_key([
                "to_char(cast(soh.\"OrderDate\" as date),'YYYY-MM-DD')"]) }} as order_date_sk,
            {{ dbt_utils.generate_surrogate_key(["to_char(cast(soh.\"DueDate\" as date),'YYYY-MM-DD')"]) }} as due_date_sk,
            case when soh."ShipDate" is null then null
                else {{ dbt_utils.generate_surrogate_key([
                    "to_char(cast(soh.\"ShipDate\" as date),'YYYY-MM-DD')"]) }} end as ship_date_sk,

            -- Direct dimension surrogate keys generated from source business keys
            {{ dbt_utils.generate_surrogate_key(['soh."CustomerID"']) }} as customer_sk,

            {{ dbt_utils.generate_surrogate_key(['sod."ProductID"']) }} as product_sk,

            case
                when p."ProductSubcategoryID" is null then
                    {{ dbt_utils.generate_surrogate_key(["'N/A'"]) }}
                else
                    {{ dbt_utils.generate_surrogate_key([
                        'p."ProductSubcategoryID"'
                    ]) }}
            end as product_subcategory_sk,

            case
                when ps."ProductCategoryID" is null then
                    {{ dbt_utils.generate_surrogate_key(["'N/A'"]) }}
                else
                    {{ dbt_utils.generate_surrogate_key([
                        'ps."ProductCategoryID"'
                    ]) }}
            end as product_category_sk,

            case 
                when soh."SalesPersonID" is null 
                    then {{ dbt_utils.generate_surrogate_key(["'N/A'"]) }}
                else {{ dbt_utils.generate_surrogate_key(['soh."SalesPersonID"']) }} end as salesperson_sk,

            {{ dbt_utils.generate_surrogate_key(['soh."TerritoryID"']) }} as territory_sk,

           -- {{ dbt_utils.generate_surrogate_key(['sod."SpecialOfferID"']) }} as special_offer_sk,

            {{ dbt_utils.generate_surrogate_key(['soh."ShipMethodID"']) }} as ship_method_sk,

            {{ dbt_utils.generate_surrogate_key(['soh."BillToAddressID"']) }} as bill_to_address_sk,

            {{ dbt_utils.generate_surrogate_key(['soh."ShipToAddressID"']) }} as ship_to_address_sk,

            -- Business/source identifiers for traceability
            soh."SalesOrderID"::number as sales_order_id,
            sod."SalesOrderDetailID"::number as sales_order_detail_id,
            concat(
                soh."SalesOrderID",
                '-',
                sod."SalesOrderDetailID"
            )::varchar as sales_order_line_id_bk,

            sod."OrderQty"::number as order_qty,
            sod."UnitPrice"::number(18, 2) as unit_price,
            sod."UnitPriceDiscount"::number(18, 4) as unit_price_discount,
            sod."LineTotal"::number(18, 2) as line_total,
            (sod."OrderQty"* sod."UnitPrice")::number(18, 2) as gross_sales_amount,
            (sod."OrderQty"* sod."UnitPrice"* sod."UnitPriceDiscount")::number(18, 2) as discount_amount,
            sod."LineTotal"::number(18, 2) as net_sales_amount,

            -- Metadata
            'ADVENTURE_WORKS'::varchar as source_system,

            sysdate() as elt_process_datetime

        from sales_order_detail sod

        left join sales_order_header soh
            on sod."SalesOrderID" = soh."SalesOrderID"

        left join product p
            on sod."ProductID" = p."ProductID"

        left join product_subcategory ps
            on p."ProductSubcategoryID" = ps."ProductSubcategoryID"

    )

select *
from final