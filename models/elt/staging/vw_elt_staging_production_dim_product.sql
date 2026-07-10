with
    prod as (
        select *
        from {{ ref("vw_stg_production_product") }}
    ),
    subcat as (
        select *
        from {{ ref("vw_stg_production_productsubcategory") }}
    ),
    category as (
        select *
        from {{ ref("vw_stg_production_productcategory") }}
    ),
    model as (
        select *
        from {{ ref("vw_stg_production_productmodel") }}
    ),
    final as (

        select
            {{ dbt_utils.generate_surrogate_key(['p."ProductID"']) }}
                as product_sk,
            p."ProductID"::number as product_id_bk,
            p."Name"::varchar as product_name,
            p."ProductNumber"::varchar as product_number,
            p."MakeFlag"::boolean as make_flag,
            p."FinishedGoodsFlag"::boolean as finished_goods_flag,
            p."Color"::varchar as product_color,
            p."Size"::varchar as product_size,
            p."Weight"::number as product_weight,
            p."ProductLine"::varchar as product_line,
            p."Class"::varchar as product_class,
            p."Style"::varchar as product_style,
            p."StandardCost"::number(18,2) as standard_cost,
            p."ListPrice"::number(18,2) as list_price,

            s."ProductSubcategoryID"::number as product_subcategory_id,
            s."Name"::varchar as product_subcategory_name,

            c."ProductCategoryID"::number as product_category_id,
            c."Name"::varchar as product_category_name,

            m."ProductModelID"::number as product_model_id,
            m."Name"::varchar as product_model_name,

            p."DaysToManufacture"::number as days_to_manufacture

        from prod p

        left join subcat s
            on p."ProductSubcategoryID" = s."ProductSubcategoryID"

        left join category c
            on s."ProductCategoryID" = c."ProductCategoryID"

        left join model m
            on p."ProductModelID" = m."ProductModelID"

    )

select *
from final