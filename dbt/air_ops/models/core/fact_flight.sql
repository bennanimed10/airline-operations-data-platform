{{
    config(
        materialized='incremental',
        unique_key='flight_id',
        incremental_strategy='merge'
    )
}}

-- --------------------------------------------
-- Grain: one row per flight occurrence (flight_id)
-- --------------------------------------------

with flights as (

    select *
    from {{ ref('int_flights_clean') }}

    {% if is_incremental() %}

    -- Only process records loaded after the last run
    where ingested_at > (
        select coalesce(max(ingested_at), '1900-01-01'::timestamp_ltz)
        from {{ this }}
    )

    {% endif %}

),

dates as (

    select date_key, full_date
    from {{ ref('dim_date') }}

),

airlines as (

    select airline_key, airline_code
    from {{ ref('dim_airline') }}

),

airports as (

    select airport_key, airport_code
    from {{ ref('dim_airport') }}

),

final as (

    select

        flights.flight_id,

        -- Dimension keys
        -- Left joins keep every flight. A few BTS airport codes
        -- differ from FAA codes, so their airport key is NULL.
        dates.date_key,
        airlines.airline_key,
        origin.airport_key                    as origin_airport_key,
        destination.airport_key               as destination_airport_key,

        -- Flight details
        flights.flight_number,
        flights.tail_number,

        -- Times (BTS local hhmm format)
        flights.scheduled_departure_time,
        flights.actual_departure_time,
        flights.scheduled_arrival_time,
        flights.actual_arrival_time,

        -- Measures
        flights.departure_delay_minutes,
        flights.arrival_delay_minutes,
        flights.taxi_out_minutes,
        flights.taxi_in_minutes,
        flights.air_time_minutes,
        flights.distance_miles,

        -- Status
        flights.cancelled_flag,
        flights.diverted_flag,
        flights.flight_status,
        flights.delay_status,

        -- Delay causes
        flights.carrier_delay_minutes,
        flights.weather_delay_minutes,
        flights.nas_delay_minutes,
        flights.security_delay_minutes,
        flights.late_aircraft_delay_minutes,

        -- Metadata
        flights.source_file,
        flights.ingested_at

    from flights

    left join dates
        on flights.flight_date = dates.full_date

    left join airlines
        on flights.airline_code = airlines.airline_code

    left join airports as origin
        on flights.origin_airport = origin.airport_code

    left join airports as destination
        on flights.destination_airport = destination.airport_code

)

select *
from final
