with flights as (

    select *
    from {{ ref('int_flights_clean') }}

),

-- --------------------------------------------
-- One row per airline
-- BTS only provides the carrier code, so no
-- airline names are added here.
-- --------------------------------------------

airlines as (

    select distinct
        airline_code
    from flights
    where airline_code is not null

),

final as (

    select

        -- Deterministic surrogate key based on the carrier code
        md5(airline_code)                     as airline_key,

        airline_code

    from airlines

)

select *
from final
