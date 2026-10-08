with flights as (

    select *
    from {{ ref('int_flights_clean') }}

),

dates as (

    select distinct
        flight_date as full_date
    from flights
    where flight_date is not null

),

final as (

    select

        -- Integer key in YYYYMMDD format, e.g. 20260701
        to_number(to_char(full_date, 'YYYYMMDD'))    as date_key,

        full_date,

        year(full_date)                              as year,
        quarter(full_date)                           as quarter,

        month(full_date)                             as month_number,
        to_char(full_date, 'MMMM')                   as month_name,

        day(full_date)                               as day_of_month,

        -- ISO numbering (1 = Monday ... 7 = Sunday) so the
        -- result does not depend on the WEEK_START session setting
        dayofweekiso(full_date)                      as day_of_week_number,

        decode(
            dayofweekiso(full_date),
            1, 'Monday',
            2, 'Tuesday',
            3, 'Wednesday',
            4, 'Thursday',
            5, 'Friday',
            6, 'Saturday',
            7, 'Sunday'
        )                                            as day_of_week_name,

        dayofweekiso(full_date) in (6, 7)            as is_weekend

    from dates

)

select *
from final
