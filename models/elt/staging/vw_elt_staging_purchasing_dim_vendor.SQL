with
    vendor as (
        select *
        from {{ ref('vw_stg_purchasing_vendor') }}
        qualify row_number() over (
            partition by "BusinessEntityID"
            order by "BusinessEntityID"
        ) = 1),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['v."BusinessEntityID"']) }}
                as vendor_sk,
            v."BusinessEntityID"::number as business_entity_id,
            v."AccountNumber"::varchar as vendor_account_number,
            v."Name"::varchar as vendor_name,
            v."CreditRating"::number as credit_rating,
            v."PreferredVendorStatus"::boolean as preferred_vendor_status,
            v."ActiveFlag"::boolean as active_flag,
            v."PurchasingWebServiceURL"::varchar as purchasing_web_service_url
        from vendor v)
select *
from final