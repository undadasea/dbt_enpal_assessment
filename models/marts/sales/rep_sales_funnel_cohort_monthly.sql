with deals_funnel_start as (
    select
        distinct
        deal_id,
        date(date_trunc('month', change_timestamp)) as month_deal_created
    from {{ref('sales_stage_changes')}}
    where stage_id = '1'
),
activity_steps as (
    select
        a.deal_id,
        f.month_deal_created,
        a.step_id as funnel_step,
        a.step_name as kpi_name
    from {{ref('sales_steps_activity')}} a
    join {{ref('sales_stage_changes')}} s
        on a.deal_id = s.deal_id and a.due_to_timestamp > s.change_timestamp
    join deals_funnel_start f on a.deal_id = f.deal_id
    where a.step_id in ('2.1', '3.1')
),
union_steps_and_stages as (
    select
        s.deal_id,
        f.month_deal_created,
        s.stage_id as funnel_step,
        s.stage_name as kpi_name
    from {{ref('sales_stage_changes')}} s
    join deals_funnel_start f using(deal_id)

    union all

    select
        deal_id,
        month_deal_created,
        funnel_step,
        kpi_name
    from activity_steps
)

select
    count(*) as deals_count,
    month_deal_created,
    funnel_step,
    kpi_name
from union_steps_and_stages
group by month_deal_created, funnel_step, kpi_name
order by month_deal_created, funnel_step
