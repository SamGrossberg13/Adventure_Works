with
    special_offer as (
        select *
        from {{ ref('vw_stg_sales_specialoffer') }}),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['s."SpecialOfferID"']) }}
                as special_offer_sk,
            s."SpecialOfferID"::number as special_offer_id,
            s."Description"::varchar as offer_description,
            s."DiscountPct"::number(10,4) as discount_pct,
            s."Type"::varchar as offer_type,
            s."Category"::varchar as offer_category,
            s."StartDate"::date as offer_start_date,
            s."EndDate"::date as offer_end_date,
            s."MinQty"::number as min_quantity,
            s."MaxQty"::number as max_quantity,
        from special_offer s
    )
select *
from final