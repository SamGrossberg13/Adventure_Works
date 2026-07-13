with

    territory as (
        select *
        from {{ ref('vw_stg_sales_salesterritory') }}
    ),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['t."TerritoryID"']) }}
                as territory_sk,
            t."TerritoryID"::number as territory_id,
            t."Name"::varchar as territory_name,
            t."CountryRegionCode"::varchar as country_region_code,
            t."Group"::varchar as territory_group,
            t."SalesYTD"::number(18,2) as sales_ytd,
            t."SalesLastYear"::number(18,2) as sales_last_year,
            t."CostYTD"::number(18,2) as cost_ytd,
            t."CostLastYear"::number(18,2) as cost_last_year
        from territory t
    )
select *
from final