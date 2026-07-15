{{ config(materialized='table') }}
{{ config(unique_key=["date_sk"]) }}

select
    date_sk,
    calendar_date,
    day_number,
    day_name,
    week_number,
    month_number,
    month_name,
    quarter_number,
    year_number,
    day_of_year,
    is_weekend,
    year_month,
    month_year,
    first_day_of_month,
    last_day_of_month

from {{ ref('vw_elt_staging_dim_date') }}
