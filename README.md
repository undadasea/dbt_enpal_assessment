### Using the project

Try running the following commands:
- dbt run
- dbt test


### Assumptions & follow-up for stakeholders
1. deals in `activity` don't overlap with deals in `deal_changes`:
    #### Expected behavior
    - `deal_id` overlap between datasets: **> 90%** \
        *(we don't expect 100% because some deals could've been started a while ago and there're no calls or meeting for this deal, or a deal was just generated and there weren't any calls just yet)*
    - percentage of `users` assigned to the same deal in both datasets: **100%** \
        *(we expect 100% because if a deal is already assigned to a user or changed to another user, the activity done for this deal should be done by that user)*
    #### Actuial statistics
    - `deal_id` overlap between datasets: **~ 0.3%** (averaged) \
    Test queries:
        |  |number of overlaped distinct deal_id |  total distinct deal_id |  overlap percentage |
        |---|---|---|---|
        |  activity | 8 |  4572 | 0.17%  |
        |  deal_changes | 8 |  1995 |  0.4% |
        |  query | `select count(distinct d.deal_id) from activity a join deal_changes d on a.deal_id = d.deal_id;` | `select count(distinct deal_id) from <table>;`  |   | 
    
    - percentage of `users` assigned to the same deal in both datasets: **0%** \
    Test query: `select * from activity a join deal_changes d on a.assigned_to_user::text = d.new_value::text and d.deal_id = a.deal_id where d.changed_field_key = 'user_id';`

    #### Possible explanations and questions for stakeholders
    - it could simply be because it's a dummy dataset
    - in real life that would be a problem
        - it's not clear why these sets don't overlap. Don't we make changes to deals we have some activity (calls, meetings) for? Or don't we ever call our customers which go through our stages? Is it expected?
        - if it's expected, I would tell my stakeholders that it doesn't make sense to include steps 2.1 and 3.1 into the funnel because there's hardly any data on them
        - if it's not expected, I would check our connection to PipeDrive, maybe the data is out of sync at the moment

2. `follow_up` type is inactive - means, we can't use it? When was it active? **Decision** on this: **don't use for this assignment**
```
postgres=# select * from activity_types;
 id |       name       | active |       type
----+------------------+--------+------------------
  1 | Sales Call 1     | Yes    | meeting
  2 | Sales Call 2     | Yes    | sc_2
  3 | Follow Up Call   | No     | follow_up
  4 | After Close Call | Yes    | after_close_call
(4 rows)
```

3. Question for PipeDrive users
`source_unique_postgres_public_activity_activity_id` test is failing with 11 not unique activity_id. Is this expected?

### Results
Two approaches were chosen. It makes sense to leave only one approach, because the datamarts are quite similar, but shows different funnels.
#### rep_sales_funnel_monthly
Funnel in this mart shows _operational_ side of the metrics due to how they are calculated. In this mart, we straighforwardly count deals per stage during a period of time (on a monthly basis). It could be used to analyze how well and how efficient efforts from the sales team were used to convert the leads.
#### rep_sales_funnel_cohort_monthly
Cohort funnel shows how deal convertion performs based on when a deal was aquired, regardless of when the next stages took place. It helps to see how every bucket of sales is performing over time. It's possible to improve it by adding how much time it took approximately for deals to go from Stage 1 to Stage 9.

### Notes
- Usually there's a `staging` layer in dbt project. It's used to rename data fields, change column types, unfold json fields, etc. In this project I didn't use all the raw datasets and saw no need to create staging models for those I did use.

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
