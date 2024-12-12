{{ config
    (
        materialized = 'view'
    )
}}

select
    a.deal_id,
    a.due_to as due_to_timestamp,
    case
        when t.type = 'meeting' then '2.1'
        when t.type = 'sc_2' then '3.1'
    end as step_id,
    t.name as step_name
from {{ source('postgres_public','activity') }} a
left join {{ source('postgres_public','activity_types') }} t on a.type = t.type
where a.done is true and t.active = 'Yes'
