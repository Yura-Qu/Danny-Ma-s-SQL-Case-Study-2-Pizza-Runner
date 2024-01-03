# Case Study #3 - Foodie-Fi

## Table of Contents
- [Introduction](#introduction)
- [Customer Jouney](#a-customer-journey)
- [Data Analysis Questions](#b-data-analysis-questions)
- [Challenge Payment Question](#c-challenge-payment-question)

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

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

> $\textbf{Churn Rate} = \frac{\textbf{Churned customers}}{\textbf{Total number of customers}}$
> 
> According to question 1, the total number of customers Foodie-Fi ever had is 10000.

```sql
SELECT 
    count(distinct(customer_id)),
    round(count(distinct(customer_id))/1000 * 100,1) 
FROM 
    subscriptions 
where 
    plan_id = 4;
```

- 307 customers have churned, accounting for roughly 30.7% of the total customer count.
  
### 5. How many customers have churned straight after their initial free trial — what percentage is this rounded to the nearest whole number?

- To solve this question, CTE needs to be used.
   > A common table expression, or CTE, is a temporary named result set created from a simple SELECT statement that can be used in a subsequent SELECT statement. Each SQL CTE is like a named query, whose result is stored in a virtual table (a CTE) to be referenced later in the main query. [This article provides an excellent introduction to CTE.](https://learnsql.com/blog/what-is-common-table-expression/)
- `RANK() OVER(PARTITION BY ... ORDER BY ...)`
  - `RANK()`: assigns a rank to each row
  - `PARTITION BY`: Divides the result set into partitions to which the RANK() function is applied separately. Rows within each partition are ranked independently.
  - `ORDER BY`: Specifies the columns based on which the ranking is done within each partition.
    > This query is commonly used when
    > 1. **Top-N Queries:** Identifying top or bottom performers based on certain criteria within a specific group or partition.
    > 2. **Ranking within Categories:** Analyzing sales, scores, or any other metric within specific groups (like months, regions, product categories, etc.).
    > 3. **Analyzing Trends:** Detecting changes or trends over time or within defined segments.

```sql
WITH ranked_subs AS (
    SELECT *,
        RANK() OVER (PARTITION BY customer_id ORDER BY start_date) as ranks
    FROM subscriptions
    JOIN plans USING (plan_id)
)
SELECT 
       COUNT(plan_id) as No_of_churn,
       round(COUNT(plan_id) / (SELECT COUNT(plan_id) FROM ranked_subs WHERE ranks = 2) *100,0) AS ratio
FROM 
    ranked_subs
WHERE 
    ranks = 2 
    AND 
        plan_id = 4
GROUP BY 
    plan_id, plan_name
ORDER BY 
    plan_id;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/25fcce0b-9eef-493e-817b-67affe8e7545)

- A CTE named `ranked_subs` is created to generate a temporary dataset, assigning a rank to each row based on the `start_date` order within each unique `customer_id`. Then, I filtered the dataset for rows with a rank of 2 and a plan_id of 4, signifying customers who churned immediately after the trial plan.
- 92 customers discontinued their subscription right after the initial free trial period, accounting for roughly 9% of the entire customer base.

### 6. What is the number and percentage of customer plans after their initial free trial?

> For this query, we can essentially reuse the code from the previous question. However, our focus here is on the overall distribution of customers' choices after the trial plan. Hence, we simply eliminate the filter used to select churned customers.

```sql
WITH ranked_subs AS (
    SELECT *,
        RANK() OVER (PARTITION BY customer_id ORDER BY start_date) as ranks
    FROM subscriptions
    JOIN plans USING (plan_id)
)
SELECT plan_id, plan_name,
       COUNT(plan_id) as No_of_churn,
       (COUNT(plan_id) / (SELECT COUNT(plan_id) FROM ranked_subs WHERE ranks = 2) *100) AS ratio
FROM 
    ranked_subs
WHERE 
    ranks = 2 
GROUP BY 
    plan_id, plan_name
ORDER BY plan_id;
```

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/885808c9-e656-400e-acf2-613976453bbc)

1. Over 90% of Foodie-Fi's customers continue their journey with the service.
2. More than 80% of them are subscribed to paid plans, with Plans 1 (Basic Monthly) and 2 (Pro Monthly) being the most popular.
3. There seems to be room for enhancing customer acquisition for Plan 3 (Pro Annual), considering only a small fraction (3.7%) of customers opt for this plan.

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020–12–31?

> We want to know the most recent plan status for each customer before December 31, 2020.
> 
> `RANK() OVER(PARTITION BY customer_id ORDER BY start_date DESC) as ranks ` is used to assign a rank to each row based on the descending order of `start_date` within that customer's partition. The most recent start_date will have a rank of 1, the second most recent will have a rank of 2, and so on within that customer's records.

```sql
WITH ranking AS (
    SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY start_date DESC) as ranks
    FROM subscriptions
    WHERE start_date <= '2020-12-31'
)
SELECT plan_name, COUNT(plan_id) AS customer_count,
    ROUND(
        COUNT(plan_id) / (SELECT COUNT(customer_id) FROM ranking WHERE ranks = 1) * 100, 1
    ) AS percentage
FROM ranking
JOIN plans USING (plan_id)
WHERE ranks = 1
GROUP BY plan_name;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/b89baf0a-c6da-45f7-8ff4-502184b1cd4d)

1. By December 31st, 2020, the Pro Monthly plan held the highest subscription rate (32.6%).
2. Notably, the churn rate experienced a significant surge, jumping from 9.2% at the trial period's conclusion to 23.6% by the year's end.
3. Additionally, the remarkably low rate of trial plan subscriptions, standing at only 1.9%, suggests a limited number of new Foodie-Fi users.
4. However, there's an observable increase in users transitioning to the Pro Annual plan compared to the count of customers initially subscribed to the Pro Annual plan. This pattern hints at more users upgrading from Basic and Pro Monthly plans to the Pro Annual subscription tier.

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
select 
    count(customer_id) 
from 
    subscriptions
where 
    year(start_date) = 2020
and 
    plan_id = 3;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/bc83d2b0-10fb-4a77-85e1-1c378ceddb47)

- 195 customers upgraded to an annual plan in 2020

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

> First, I need to test my assumption that all the customers join foodie fi with a trail plan: 

```sql
WITH ranked_subs AS (
    SELECT *,
        RANK() OVER (PARTITION BY customer_id ORDER BY start_date) AS ranks
    FROM subscriptions
)

SELECT plan_id, COUNT(plan_id)
FROM ranked_subs
WHERE ranks = 1
GROUP BY plan_id;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/132045a1-3f9e-47ef-a8c3-1879d70e0814)

YES!

> I perform a self-join on the "subscriptions" table where the `plan_id` in the first instance equals 0 (trail plan) and the `plan_id` in the second instance equals 3 (pro annual) for the same customer. Subsequently, I compute the date difference.

```sql
WITH annual_plan AS (
    SELECT 
        a.customer_id, 
        a.plan_id AS current_plan, 
        b.plan_id AS previous_plan, 
        a.start_date AS current_start, 
        b.start_date AS previous_start
    FROM 
        subscriptions AS a
    JOIN 
        subscriptions AS b
    ON 
        a.customer_id = b.customer_id
    WHERE 
        a.plan_id = 3
    AND 
        b.plan_id = 0   
)
SELECT 
    ROUND(AVG(DATEDIFF(current_start,previous_start)),0) AS date_difference
FROM 
    annual_plan;
```
The annual_plan table:

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/f81ae500-dcc8-4bf5-ab64-66552bf6ff96)

On average, customers typically take around 105 days from their initial sign-up with Foodie-Fi to transition to an annual plan.

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/6697dcc7-9bfa-4160-9992-da1d6b2c0090) 

### 10. Can you further breakdown this average value into 30-day periods (i.e. 0–30 days, 31–60 days, etc)

> In this question, I used a function called `WIDTH_BUCKET`, and Chatgpt gives a very good explanation of `WIDTH_BUCKET`:
> 
> `WIDTH_BUCKET` is used to categorize numerical values into a defined set of ranges or buckets. It's particularly useful for creating histograms or segmenting continuous data into discrete groups.
> - Here's a breakdown of how it operates:
>   - Parameters: It takes several parameters:
>     - Input value: The numerical value you want to place into a bucket.
>     - Lower bound: The minimum value of the range.
>     - Upper bound: The maximum value of the range.
>     - Number of buckets: The desired number of buckets to create between the lower and upper bounds.
>   - Functionality: `WIDTH_BUCKET` computes the bucket number for each input value. It divides the range specified by the lower and upper bounds into a specific number of equally spaced intervals or buckets.
> - Example
>   ```sql
>   SELECT age,
>        WIDTH_BUCKET(age, 0, 100, 5) AS age_bucket
>   FROM person_data; ```
> -    
>    - `WIDTH_BUCKET(age, 0, 100, 5)` categorizes the age values into five buckets between 0 and 100.
>    - Bucket 1: Ages from 0 to 20
>    - Bucket 2: Ages from 21 to 40
>    - Bucket 3: Ages from 41 to 60
>    - Bucket 4: Ages from 61 to 80
>    - Bucket 5: Ages from 81 to 100

Alternatively, just use the simple `CASE WHEN`

```sql
WITH a AS (
	SELECT 
        a.customer_id, 
        a.plan_id AS current_plan, 
        b.plan_id AS previous_plan, 
        a.start_date AS current_start, 
        b.start_date AS previous_start,
        DATEDIFF(a.start_date, b.start_date) as Date_diff,
        FLOOR(DATEDIFF(a.start_date, b.start_date) / 30) as bins
    FROM 
        subscriptions AS a
    JOIN 
        subscriptions AS b
    ON 
        a.customer_id = b.customer_id
    WHERE 
        a.plan_id = 3
    AND 
        b.plan_id = 0 
), 
b AS (
    SELECT *,
    CASE 
        WHEN bins = 0 THEN '0–30 days'
        WHEN bins = 1 THEN '31–60 days'
        WHEN bins = 2 THEN '61–90 days'
        WHEN bins = 3 THEN '91–120 days'
        WHEN bins = 4 THEN '121–150 days'
        WHEN bins = 5 THEN '151–180 days'
        WHEN bins = 6 THEN '181–210 days'
        WHEN bins = 9 THEN '211–240 days'
        WHEN bins = 10 THEN '241–270 days'
        WHEN bins = 11 THEN '271–300 days'
        WHEN bins = 12 THEN '301–330 days'
        ELSE '331–360 days'
    END AS category
    FROM a
) 
SELECT category, 
    ROUND(AVG(Date_diff), 0) as Average_days, 
	COUNT(category) as Counts
FROM b
GROUP BY category
ORDER BY MIN(bins);
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/5b64f5e2-76b3-4dde-838a-1391a4a5c7c6)

### 11. How many customers were downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
SELECT COUNT(a.customer_id) AS no_of_customer
FROM subscriptions AS a
JOIN subscriptions AS b ON a.customer_id = b.customer_id
WHERE a.plan_id = 2
  AND b.plan_id = 1
  AND YEAR(a.start_date) = 2020
  AND YEAR(b.start_date) = 2020
  AND DATEDIFF(b.start_date, a.start_date) > 0;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/70301540-1759-4e33-9712-314247562ac2)

- During 2020, there were no customers who switched from the pro monthly to the basic monthly plan.

## C. Challenge Payment Question

The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of the month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also start at the end of the month period
- once a customer churns they will no longer make payments

Thus: 
> 1. Only start_date in 2020 is included
> 2. Remove trial plans since no payments were made
> 3. 
