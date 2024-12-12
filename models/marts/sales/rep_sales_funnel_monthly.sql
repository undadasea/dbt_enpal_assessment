with stages_and_steps as (
    select
        deal_id,
        date(date_trunc('month', change_timestamp)) as month,
        stage_id as funnel_step,
        stage_name as kpi_name
    from {{ref('sales_stage_changes')}}
    union all 
    select
        a.deal_id,
        date(date_trunc('month', a.due_to_timestamp)) as month,
        step_id as funnel_step,
        step_name as kpi_name
    from {{ref('sales_steps_activity')}} a
    join {{ref('sales_stage_changes')}} s 
        on a.deal_id = s.deal_id and a.due_to_timestamp > s.change_timestamp -- activity should happen after the creation of a deal
    where step_id in ('2.1', '3.1')
)
select
    count(*) as deals_count,
    month,
    funnel_step,
    kpi_name
from stages_and_steps
group by month, funnel_step, kpi_name
order by month, funnel_step
