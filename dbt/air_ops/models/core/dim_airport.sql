with airports as (

    select *
    from {{ ref('stg_airports') }}

),

-- --------------------------------------------
-- One row per airport
-- Each FAA cycle reloads every airport, so keep
-- the most recent cycle, then the latest load.
-- --------------------------------------------

latest as (

    select *
    from airports

    qualify row_number() over (
        partition by airport_code
        order by
            effective_date desc,
            ingested_at desc
    ) = 1

),

final as (

    select

        -- Stable surrogate key: based only on the FAA code,
        -- so it does not change between FAA cycles
        md5(airport_code)                     as airport_key,

        airport_code,
        icao_code,
        airport_name,

        city,
        state_code,
        state_name,

        latitude,
        longitude,
        elevation_feet,

        facility_type,
        facility_status,

        -- Lineage
        effective_date,
        source_file

    from latest

)

select *
from final
