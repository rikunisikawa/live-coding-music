with source as (
  select
    event_id,
    user_id,
    event_type,
    event_ts,
    updated_at
  from {{ source('raw', 'events') }}
)

select * from source
