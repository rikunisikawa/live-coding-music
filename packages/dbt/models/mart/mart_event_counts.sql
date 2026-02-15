with base as (
  select * from {{ ref('core_events') }}
)

select
  date_trunc('day', event_ts) as event_date,
  event_type,
  count(*) as event_count
from base
group by 1, 2
