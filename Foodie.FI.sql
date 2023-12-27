# A. Customer Journey

SELECT subscriptions.customer_id, plans.plan_id, plans.plan_name, subscriptions.start_date
FROM plans 
JOIN subscriptions 
ON plans.plan_id = subscriptions.plan_id
WHERE subscriptions.customer_id IN (1,2,4,16,21);

# Data Analysis Questions
# How many customers has Foodie-Fi ever had?
select count(distinct customer_id) from subscriptions; 

# What is the monthly distribution of trial plan start_date values for our dataset use the start of the month as the group by value?

SELECT MONTH(start_date) AS months, COUNT(MONTH(start_date)) AS customers
FROM subscriptions
where plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY customers;

# What plan start_date values occur after the year 2020 for our dataset?
# Show the breakdown by count of events for each plan_name.

SELECT  s.plan_id, p.plan_name, count(s.plan_id) AS plan_count
FROM subscriptions as s
join plans as p using (plan_id)
WHERE YEAR(s.start_date) > 2020
group by s.plan_id,p.plan_name
order by s.plan_id;

# What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT count(customer_id),round(count(customer_id)/1000 * 100,1) FROM subscriptions 
where plan_id = 4;

# How many customers have churned straight after their initial free trial — what percentage is this rounded to the nearest whole number?

SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY start_date)
  FROM subscriptions;
# What is the number and percentage of customer plans after their initial free trial?

SELECT * FROM subscriptions;

WITH ranked_subs AS (
    SELECT *,
        RANK() OVER (PARTITION BY customer_id ORDER BY start_date) as ranks
    FROM subscriptions
    JOIN plans USING (plan_id)
)
SELECT plan_id, plan_name, 
       COUNT(plan_id),
       (COUNT(plan_id) / (SELECT COUNT(plan_id) FROM ranked_subs WHERE ranks = 2) *100) AS ratio
FROM ranked_subs
WHERE ranks = 2
GROUP BY plan_id, plan_name
ORDER BY plan_id;

# What is the customer count and percentage breakdown of all 5 plan_name values at 2020–12–31?

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
GROUP BY plan_name
ORDER BY customer_count DESC;
