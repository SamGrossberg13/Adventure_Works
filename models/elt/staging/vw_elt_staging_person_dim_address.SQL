with

    address as (
        select *
        from {{ ref('vw_stg_person_address') }}
        qualify row_number() over (
            partition by "AddressID"
            order by "AddressID"
        ) = 1),
    state_province as (
        select *
        from {{ ref('vw_stg_person_stateprovince') }}
        qualify row_number() over (
            partition by "StateProvinceID"
            order by "StateProvinceID"
        ) = 1),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['a."AddressID"']) }}
                as address_sk,
            a."AddressID"::number as address_id,
            a."AddressLine1"::varchar as address_line_1,
            a."AddressLine2"::varchar as address_line_2,
            a."City"::varchar as city,
            a."StateProvinceID"::number as state_province_id,
            sp."StateProvinceCode"::varchar as state_province_code,
            sp."Name"::varchar as state_province_name,
            a."PostalCode"::varchar as postal_code,
            sp."TerritoryID"::number as territory_id
        from address a
        left join state_province sp
            on a."StateProvinceID" = sp."StateProvinceID")
select *
from final