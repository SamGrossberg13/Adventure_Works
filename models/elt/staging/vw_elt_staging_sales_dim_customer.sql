with
    cust as (
        select *
        from {{ ref('vw_stg_sales_customer') }}),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['c."CustomerID"']) }}
                as customer_sk,
            c."CustomerID"::number as customer_id,
            c."PersonID"::number as person_id,
            c."StoreID"::number as store_id,
            c."TerritoryID"::number as territory_id,
            c."AccountNumber"::varchar as account_number,
            case
                when c."PersonID" is not null then 'Individual'
                when c."StoreID" is not null then 'Store'
                else 'Unknown'
            end as customer_type,

        from cust c
    )
select *
from final