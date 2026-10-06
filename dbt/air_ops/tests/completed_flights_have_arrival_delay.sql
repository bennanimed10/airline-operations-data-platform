select *
from {{ ref('int_flights_clean') }}

where flight_status = 'COMPLETED'
  and arrival_delay_minutes is null