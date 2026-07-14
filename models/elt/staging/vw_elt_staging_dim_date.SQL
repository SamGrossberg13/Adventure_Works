with
    dates as (
        select
            dateadd(
                day,
                seq4(),
                '2010-01-01'
            ) as calendar_date

        from table(generator(rowcount => 8000))),
    final as (
        select
            {{ dbt_utils.generate_surrogate_key(['calendar_date']) }}
                as date_sk,
            calendar_date,
            day(calendar_date) as day_number,
            dayname(calendar_date) as day_name,
            week(calendar_date) as week_number,
            month(calendar_date) as month_number,
            monthname(calendar_date) as month_name,
            quarter(calendar_date) as quarter_number,
            year(calendar_date) as year_number,
            dayofyear(calendar_date) as day_of_year,
            case
                when dayofweek(calendar_date) in (0,6)
                then true
                else false
            end as is_weekend,
            to_char(calendar_date,'YYYY-MM')
                as year_month,
            to_char(calendar_date,'Mon YYYY')
                as month_year,
            date_trunc('month', calendar_date)
                as first_day_of_month,
            last_day(calendar_date)
                as last_day_of_month
        from dates
        where calendar_date <= '2030-12-31'
    )
select *
from final