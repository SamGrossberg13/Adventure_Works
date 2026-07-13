with
    ship_method as (
        select *
        from {{ ref('vw_stg_purchasing_shipmethod') }}
        qualify row_number() over (
            partition by "ShipMethodID"
            order by "ShipMethodID"
        ) = 1),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['s."ShipMethodID"']) }}
                as ship_method_sk,
            s."ShipMethodID"::number as ship_method_id,
            s."Name"::varchar as ship_method_name,
            s."ShipBase"::number(18,2) as ship_base,
            s."ShipRate"::number(18,2) as ship_rate
        from ship_method s)
select *
from final