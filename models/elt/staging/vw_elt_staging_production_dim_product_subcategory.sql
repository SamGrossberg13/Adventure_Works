
with

    subcat as (
        select *
        from {{ ref("vw_stg_production_productsubcategory") }}
        qualify row_number() over (
            partition by "ProductSubcategoryID"
            order by "ModifiedDate" desc
        ) = 1),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['"ProductSubcategoryID"']) }}
                as product_subcategory_sk,
            "ProductSubcategoryID"::number as product_subcategory_id_bk,
            "Name"::varchar as product_subcategory_name,

        from subcat
    )

select *
from final

union all

select

    {{ dbt_utils.generate_surrogate_key(["'N/A'"]) }}
        as product_subcategory_sk,

    null as product_subcategory_id_bk,

    'N/A' as product_subcategory_name