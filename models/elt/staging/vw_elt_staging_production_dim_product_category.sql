
with

    cat as (
        select *
        from {{ ref("vw_stg_production_productcategory") }}
        qualify row_number() over (
            partition by "ProductCategoryID"
            order by "ModifiedDate" desc
        ) = 1),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['"ProductCategoryID"']) }}
                as product_category_sk,
            "ProductCategoryID"::number as product_category_id_bk,
            "Name"::varchar as product_category_name,

        from cat
    )

select *
from final