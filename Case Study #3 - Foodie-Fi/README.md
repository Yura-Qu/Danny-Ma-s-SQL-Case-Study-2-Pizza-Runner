# Case Study #3 - Foodie-Fi

## Introduction 

Danny noticed a market gap and aimed to create Foodie-Fi, a specialized streaming service exclusively for food-related content, akin to Netflix but solely for cooking shows. In 2020, with a group of astute friends, he launched this startup, offering monthly and annual subscriptions, granting users limitless access to an array of exclusive global food videos.

With a data-centric approach, Danny structured Foodie-Fi to guide all future investments and feature additions using data insights. This case study delves into using subscription-based digital data to address pivotal business queries.

### Entity Relationship Diagram 

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/36ec93e1-0c3e-46f0-8c54-4d715fdee506)

### Schema: `foodie_fi`
  - Table 1: plans
    | **plan_id** | **plan_name** | **price** |
    |-------------|---------------|-----------|
    | **0**       | trial         | 0         |
    | **1**       | basic monthly | 9.90      |
    | **2**       | pro monthly   | 19.90     |
    | **3**       | pro annual    | 199       |
    | **4**       | churn         | null      |
    - Customers can sign up for an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic, or upgrade to an annual pro plan at any point during the trial.
    - When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.
    - Primary key: `plan_id`
    - Foreign key: `plan_id`
  - Table 2: subscriptions
    | **customer_id** | **plan_id** | **start_date** |
    |-----------------|-------------|----------------|
    | 1               | 0           | 2020-08-01     |
    | 1               | 1           | 2020-08-08     |
    | 2               | 0           | 2020-09-20     |
    | 2               | 3           | 2020-09-27     |
    | 11              | 0           | 2020-11-19     |
    | 11              | 4           | 2020-11-26     |
    - Customer subscriptions show the exact date where their specific `plan_id` starts.
    - If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the `start_date` in the `subscriptions` table will reflect the date that the actual plan changes.
    - Primary key: `customer_id`
    - Foreign key: `plan_id`

## A. Customer Journey

Write a brief description of the customer’s onboarding journey.

```sql
SELECT
    subscriptions.customer_id,
    plans.plan_id,
    plans.plan_name,
    subscriptions.start_date
FROM
    plans 
JOIN
    subscriptions 
ON
    plans.plan_id = subscriptions.plan_id
WHERE
    subscriptions.customer_id IN (1,2,4,16,21);
```
- Customers with `customer_id` = 1,2,4,16 and 21 are select to do the onboarding journey.
