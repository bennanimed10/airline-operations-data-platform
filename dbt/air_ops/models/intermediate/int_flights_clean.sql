with flights as (

    select *
    from {{ ref('stg_flights') }}

),

cleaned as (

    select

        -- Unique business key for a flight occurrence
        md5(
            concat(
                coalesce(to_varchar(flight_date), ''),
                '|',
                coalesce(airline_code, ''),
                '|',
                coalesce(to_varchar(flight_number), ''),
                '|',
                coalesce(origin_airport, ''),
                '|',
                coalesce(destination_airport, ''),
                '|',
                coalesce(to_varchar(scheduled_departure_time), '')
            )
        ) as flight_id,


        -- Original flight information
        flight_date,
        airline_code,
        flight_number,
        tail_number,

        origin_airport_id,
        origin_airport,
        origin_city,
        origin_state,

        destination_airport_id,
        destination_airport,
        destination_city,
        destination_state,

        scheduled_departure_time,
        actual_departure_time,

        departure_delay_minutes,
        departure_delay_positive_minutes,

        scheduled_arrival_time,
        actual_arrival_time,

        arrival_delay_minutes,
        arrival_delay_positive_minutes,

        taxi_out_minutes,
        taxi_in_minutes,
        air_time_minutes,
        distance_miles,

        cancelled_flag,
        cancellation_code,
        diverted_flag,


        -- -----------------------------------
        -- Route
        -- -----------------------------------

        origin_airport
            || '-'
            || destination_airport
            as route,


        -- -----------------------------------
        -- Flight status
        -- -----------------------------------

        case

            when cancelled_flag = 1
                then 'CANCELLED'

            when diverted_flag = 1
                then 'DIVERTED'

            else 'COMPLETED'

        end as flight_status,


        -- -----------------------------------
        -- Arrival delay status
        -- DOT considers >= 15 minutes delayed
        -- -----------------------------------

        case

            when cancelled_flag = 1
                then 'CANCELLED'

            when diverted_flag = 1
                then 'DIVERTED'

            when arrival_delay_minutes < 15
                then 'ON_TIME'

            when arrival_delay_minutes < 60
                then 'DELAYED'

            else 'SEVERELY_DELAYED'

        end as delay_status,


        -- -----------------------------------
        -- Analytical flags
        -- -----------------------------------

        case
            when arrival_delay_minutes >= 15
                 and cancelled_flag = 0
                 and diverted_flag = 0
            then 1
            else 0
        end as is_delayed,


        case
            when arrival_delay_minutes >= 60
                 and cancelled_flag = 0
                 and diverted_flag = 0
            then 1
            else 0
        end as is_severely_delayed,


        -- Delay causes

        carrier_delay_minutes,
        weather_delay_minutes,
        nas_delay_minutes,
        security_delay_minutes,
        late_aircraft_delay_minutes,


        -- Metadata

        source_file,
        ingested_at,
        file_last_modified

    from flights

)

select *
from cleaned