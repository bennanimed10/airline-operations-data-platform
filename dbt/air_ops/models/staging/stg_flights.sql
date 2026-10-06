with source as (

    select *
    from {{ source('raw', 'flights') }}

),

renamed as (

    select

        "FlightDate"                          as flight_date,
        "Reporting_Airline"                   as airline_code,
        "Flight_Number_Reporting_Airline"     as flight_number,
        "Tail_Number"                         as tail_number,

        "OriginAirportID"                     as origin_airport_id,
        "Origin"                              as origin_airport,
        "OriginCityName"                      as origin_city,
        "OriginState"                         as origin_state,

        "DestAirportID"                       as destination_airport_id,
        "Dest"                                as destination_airport,
        "DestCityName"                        as destination_city,
        "DestState"                           as destination_state,

        "CRSDepTime"                          as scheduled_departure_time,
        "DepTime"                             as actual_departure_time,
        "DepDelay"                            as departure_delay_minutes,
        "DepDelayMinutes"                     as departure_delay_positive_minutes,

        "CRSArrTime"                          as scheduled_arrival_time,
        "ArrTime"                             as actual_arrival_time,
        "ArrDelay"                            as arrival_delay_minutes,
        "ArrDelayMinutes"                     as arrival_delay_positive_minutes,

        "TaxiOut"                             as taxi_out_minutes,
        "TaxiIn"                              as taxi_in_minutes,
        "AirTime"                             as air_time_minutes,
        "Distance"                            as distance_miles,

        "Cancelled"                           as cancelled_flag,
        "CancellationCode"                    as cancellation_code,
        "Diverted"                            as diverted_flag,

        "CarrierDelay"                        as carrier_delay_minutes,
        "WeatherDelay"                        as weather_delay_minutes,
        "NASDelay"                            as nas_delay_minutes,
        "SecurityDelay"                       as security_delay_minutes,
        "LateAircraftDelay"                   as late_aircraft_delay_minutes,

        "_SOURCE_FILE"                        as source_file,
        "_INGESTED_AT"                        as ingested_at,
        "_FILE_LAST_MODIFIED"                 as file_last_modified

    from source

)

select *
from renamed