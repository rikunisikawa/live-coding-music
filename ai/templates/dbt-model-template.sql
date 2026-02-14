{{
  config(
    materialized='incremental',
    unique_key='{{ unique_key }}'
  )
}}

with source as (
  select
    {{ columns | join(',\n    ') }}
  from {{ source_relation }}

  {% if is_incremental() %}
  where {{ updated_at_column }} >= (
    select coalesce(max({{ updated_at_column }}), '1900-01-01')
    from {{ this }}
  )
  {% endif %}
),

final as (
  select
    {{ final_columns | join(',\n    ') }}
  from source
)

select * from final
