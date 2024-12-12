{{ config
    (
        materialized = 'view'
    )
}}

select
    d.deal_id,
    d.change_time as change_timestamp,
    d.new_value as stage_id,
    s.stage_name
from {{ source('postgres_public','deal_changes') }} d
left join {{ source('postgres_public','stages') }} s on d.new_value = s.stage_id::text
where changed_field_key = 'stage_id'
