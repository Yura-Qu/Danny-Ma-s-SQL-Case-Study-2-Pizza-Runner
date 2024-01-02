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

| **customer_id** | **plan_id** | **plan_name** | **start_date** |
|:---------------:|:-----------:|:-------------:|:--------------:|
| 1               | 0           | trial         | 2020-08-01     |
| 1               | 1           | basic monthly | 2020-08-08     |
| 2               | 0           | trial         | 2020-09-20     |
| 2               | 3           | pro annual    | 2020-09-27     |
| 4               | 0           | trial         | 2020-01-17     |
| 4               | 1           | basic monthly | 2020-01-24     |
| 4               | 4           | churn         | 2020-04-21     |
| 16              | 0           | trial         | 2020-05-31     |
| 16              | 1           | basic monthly | 2020-06-07     |
| 16              | 3           | pro annual    | 2020-10-21     |
| 21              | 0           | trial         | 2020-02-04     |
| 21              | 1           | basic monthly | 2020-02-11     |
| 21              | 2           | pro monthly   | 2020-06-03     |
| 21              | 4           | churn         | 2020-09-27     |

- Customers with `customer_id` = 1,2,4,16 and 21 are selected to do the onboarding journey.
  - Customer 1: The customer began their journey by initiating a free trial on August 1, 2020. Following the trial's conclusion (after 7 days) on August 8, 2020, they proceeded to subscribe to the basic monthly plan.
  - Customer 2 initiated their free trial on September 20, 2020. After the trial concluded, they subscribed to the pro annual plan on September 27, 2020.
  - Customer 4 started their free trial on January 17, 2020. Following the trial, they subscribed to the basic monthly plan on January 24, 2020. However, they canceled their Foodie-Fi basic monthly plan on April 21, 2020.
  - Customer 16 commenced their free trial on May 31, 2020, and subsequently subscribed to the basic monthly plan on June 07, 2020. Later, they upgraded to the pro annual plan on October 21, 2020.
  - Customer 21 commenced their free trial on February 04, 2020, and thereafter subscribed to the basic monthly plan on February 11, 2020. They later upgraded to the pro annual plan on June 03, 2020. However, they canceled their Foodie-Fi basic monthly plan on September 27, 2020.
 
## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

```sql
select count(distinct customer_id) from subscriptions; 
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/815e6460-e974-4930-866b-683a19d99c86)

There are 1000 customers.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

> Number of trial plans monthly
> 1. Extract the months from `start_date` column by using `MONTH( )`
> 2. Filter results to show only those on trial plan `plan_id = 0`
> 3. Group and count the total number of plan_ids per month `COUNT(MONTH(start_date))`

```sql
SELECT
    MONTH(start_date) AS months,
    COUNT(MONTH(start_date)) AS customers
FROM
    subscriptions
where
    plan_id = 0
GROUP BY
    MONTH(start_date)
ORDER BY
    customers DESC;
```
|   months  |   customers  |
|-----------|--------------|
|   3       |   94         |
|   7       |   89         |
|   8       |   88         |
|   1       |   88         |
|   5       |   88         |
|   9       |   87         |
|   12      |   84         |
|   4       |   81         |
|   6       |   79         |
|   10      |   79         |
|   11      |   75         |
|   2       |   68         |

- March has the highest number of customers starting their journey with Foodie-Fi.
- February, on the other hand, has the least number of customers beginning their trial plan.
- Overall, the count of customers joining Foodie-Fi is fairly consistent across all months.

### 3. What plan start_date values occur after the year 2020 for our dataset? — Show the breakdown by count of events for each plan_name.

> What is the count for each plan post-2020?
> 1. Select plans with start dates on or after January 1, 2021 -- `YEAR(s.start_date) > 2020`
> 2. Count the customers based on the number of events.
> 3. Group the outcomes by plan names

```sql
SELECT
    s.plan_id,
    p.plan_name,
    count(s.plan_id) AS plan_count
FROM
    subscriptions as s
join
    plans as p
using
    (plan_id)
WHERE
    YEAR(s.start_date) > 2020
group by
    s.plan_id,
    p.plan_name
order by
    s.plan_id;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/bc24eebb-815b-47f5-be29-c99ec7032399)

- No customers initiated their trial plan after 2020 (which is concerning).
- There's a significant number of customers ending their Foodie-Fi services after 2020 (equally concerning).
- The counts for Pro Monthly and Pro Annual subscriptions are relatively similar.

> Hence, to explore whether this is simply a coding error or an actual absence of customers starting their trial plan after 2020, I reviewed the annual distribution of trial plans.
> ```sql
> SELECT
>     YEAR(start_date),
>     count(YEAR(start_date))
> FROM
>     subscriptions as s
> WHERE
>     s.plan_id = 0
> group by
>     YEAR(start_date);
> ```
> ![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/b9cc0b3a-8797-4b30-88ef-08b2e1e79897)
> 
> It appears that indeed, no customer initiated their trial plan after 2020.

> Yet, upon reviewing the dataset, it's evident that the overwhelming majority (as much as 92%) of records occurred are not from after 2020.
> ```sql
> SELECT 
>    YEAR(start_date),
>    count(YEAR(start_date)),
>    round(count(YEAR(start_date))/ 2650,2)*100
> FROM 
>    subscriptions 
> group by 
>    YEAR(start_date);
> ```
> ![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/e0564a26-64a8-4552-b001-b6fe82fb58e5)
> 
> Therefore, the outcome might not accurately represent the actual scenario -- this is the limitation of this dataset. (Data limitation: the available data is inadequate or incomplete, leading to constraints or restrictions in its usability for analysis or decision-making) 

