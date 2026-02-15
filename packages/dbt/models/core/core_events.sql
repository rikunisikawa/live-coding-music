{{
  config(
    materialized='incremental',
    unique_key='event_id'
  )
}}

with base as (
  select
    event_id,
    user_id,
    event_type,
    event_ts,
    updated_at
  from {{ ref('stg_example_events') }}

  {% if is_incremental() %}
  where updated_at >= (
    select coalesce(max(updated_at), '1900-01-01') from {{ this }}
  )
  {% endif %}
)

select * from base
