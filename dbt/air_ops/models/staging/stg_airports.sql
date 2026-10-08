with source as (

    select *
    from {{ source('raw', 'airports') }}

),

renamed as (

    select

        -- Identifiers
        ARPT_ID                               as airport_code,
        ICAO_ID                               as icao_code,
        SITE_NO                               as faa_site_number,

        -- Names and location
        ARPT_NAME                             as airport_name,
        CITY                                  as city,
        STATE_CODE                            as state_code,
        STATE_NAME                            as state_name,
        COUNTRY_CODE                          as country_code,

        try_to_decimal(LAT_DECIMAL, 10, 7)    as latitude,
        try_to_decimal(LONG_DECIMAL, 10, 7)   as longitude,
        try_to_decimal(ELEV, 7, 1)            as elevation_feet,

        -- Facility type
        SITE_TYPE_CODE                        as facility_type_code,

        case SITE_TYPE_CODE
            when 'A' then 'AIRPORT'
            when 'B' then 'BALLOONPORT'
            when 'C' then 'SEAPLANE_BASE'
            when 'G' then 'GLIDERPORT'
            when 'H' then 'HELIPORT'
            when 'U' then 'ULTRALIGHT'
        end                                   as facility_type,

        -- Facility status
        ARPT_STATUS                           as facility_status_code,

        case ARPT_STATUS
            when 'O'  then 'OPERATIONAL'
            when 'CI' then 'CLOSED_INDEFINITELY'
            when 'CP' then 'CLOSED_PERMANENTLY'
        end                                   as facility_status,

        -- FAA data cycle
        to_date(EFF_DATE, 'YYYY/MM/DD')       as effective_date,

        -- Metadata
        _SOURCE_FILE                          as source_file,
        _INGESTED_AT                          as ingested_at,
        _FILE_LAST_MODIFIED                   as file_last_modified

    from source

)

select *
from renamed
