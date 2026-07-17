with

    salesperson as (

        select *
        from {{ ref('vw_stg_sales_salesperson') }}

        qualify row_number() over (
            partition by "BusinessEntityID"
            order by "BusinessEntityID"
        ) = 1

    ),

    vsalesperson as (

        select *
        from {{ ref('vw_stg_sales_vsalesperson') }}

        qualify row_number() over (
            partition by "BusinessEntityID"
            order by "BusinessEntityID"
        ) = 1

    ),

    final as (

        select

            {{ dbt_utils.generate_surrogate_key(['s."BusinessEntityID"']) }}
                as salesperson_sk,

            s."BusinessEntityID"::number as business_entity_id,

            s."TerritoryID"::number as territory_id,

            v."FirstName"::varchar as first_name,
            v."MiddleName"::varchar as middle_name,
            v."LastName"::varchar as last_name,

            trim(
                concat(
                    coalesce(v."FirstName",''),
                    ' ',
                    coalesce(v."MiddleName",''),
                    ' ',
                    coalesce(v."LastName",'')
                )
            ) as full_name,

            v."JobTitle"::varchar as job_title,

            s."SalesQuota"::number(18,2) as sales_quota,

            s."Bonus"::number(18,2) as bonus,

            s."CommissionPct"::number(18,4) as commission_pct,

            s."SalesYTD"::number(18,2) as sales_ytd,

            s."SalesLastYear"::number(18,2) as sales_last_year,

            v."TerritoryName"::varchar as territory_name,

            v."TerritoryGroup"::varchar as territory_group

        from salesperson s

        left join vsalesperson v
            on s."BusinessEntityID" = v."BusinessEntityID"

    )

select *
from final

union all

select

    {{ dbt_utils.generate_surrogate_key(["'N/A'"]) }}
        as salesperson_sk,

    null as business_entity_id,

    null as territory_id,

    'N/A' as first_name,
    null as middle_name,
    'N/A' as last_name,

    'N/A' as full_name,

    'N/A' as job_title,

    null as sales_quota,

    null as bonus,

    null as commission_pct,

    null as sales_ytd,

    null as sales_last_year,

    null as territory_name,

    null as territory_group