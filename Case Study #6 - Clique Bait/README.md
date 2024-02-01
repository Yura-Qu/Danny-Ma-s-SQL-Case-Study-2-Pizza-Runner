# Case Study #6 - Clique Bait

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/56835cb8-8564-48a3-ae53-3cdb514c60c1)

## Introduction 

### Dataset
  - Users: Customers who visit the Clique Bait website are tagged via their cookie_id.
  - Events: Customer visits are logged in this events table at a cookie_id level and the event_type and page_id values can be used to join onto relevant satellite tables to obtain further information about each event.The sequence_number is used to order the events within each visit.
  - Event Identifier: The event_identifier table shows the types of events which are captured by Clique Bait’s digital data systems.
  - Campaign Identifier: This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.
  - Page Hierarchy: This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

### ERD
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/acae70ac-647f-4a1f-acb8-3950a49933ec)

## 1. Digital Analysis

### 1.1 How many users are there?

```sql
select count(distinct user_id) from users;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/674f8515-1ba7-4282-9c5d-9eceb3ff7381)

### 1.2 How many cookies does each user have on average?
```sql
with CTE as(
select 
    user_id,
    count(cookie_id) as counts
from users
group by user_id
) 
select 
    round(avg(counts)) 
from CTE;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/acd4f179-1c65-4da1-840e-221cb3db6f49)

### 1.3 What is the unique number of visits by all users per month?

```sql
select * from events;
select 
     Month(event_time) As Months,
     COUNT(distinct visit_id) As Visit_id
from events
group by Month(event_time);
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/00d36be0-0c34-48ff-b9e5-b8b63da6548b)

### 1.4 What is the number of events for each event type?

```sql
select 
    events.event_type,
    event_identifier.event_name,
    count(events.event_type) As counts
from events
join 
    event_identifier
where 
    events.event_type = event_identifier.event_type
group by 
    event_type,
    event_name
order by event_type;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/f0de38d6-f12d-471c-8828-e02bd47a5689)

### 1.5 What is the percentage of visits which have a purchase event?
```sql
select 
    count(distinct visit_id)/(select count(distinct visit_id) from events) *100 As percentage
from events
join 
    event_identifier
on 
    events.event_type = event_identifier.event_type
where 
    events.event_type = 3; 
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/8fba587e-b490-4029-b917-55a76995ef70)

### 1.6 What is the percentage of visits which view the checkout page but do not have a purchase event?

```sql
with CTE as (
select 
    distinct visit_id,
    sum(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout,
    sum(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY visit_id)
select 
    (1-(sum(purchase)/sum(checkout)))*100 as percentage 
from CTE;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/67c800e6-c265-4d67-86b0-d094a99cc48d)
> - `checkout`: viewed the page and and went to checkout 
>   - `event_type = 1` -- Page View
>   - `page_id = 12` -- Checkout
> - `purchase`:
>   - `event_type = 3 -- Purchase
> - `sum(purchase)/sum(checkout)` -- The percentage of visit which view the checkout page and have a purchase event
>   - Thus, `1 - (sum(purchase)/sum(checkout))` -- The percentage of visit which view the checkout page and dont have a purchase event

### 1.7 What are the top 3 pages by number of views? 

```sql
SELECT 
    events.page_id,
    page_hierarchy.page_name,
    COUNT(events.page_id) as counts
FROM events
JOIN page_hierarchy ON events.page_id = page_hierarchy.page_id
WHERE event_type = 1
GROUP BY events.page_id, page_hierarchy.page_name
ORDER BY counts DESC
LIMIT 3;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/ca193cf5-1452-4c4e-a998-2ed0ed011dc8)

### 1.8 What is the number of views and cart adds for each product category?

> product category -- `product_category`
> number of views -- `event_type` = 1
> cart adds -- `event_type` = 2

```sql
SELECT 
    page_hierarchy.product_category,
    SUM(CASE WHEN events.event_type = 1 THEN 1 ELSE 0 END) AS 'Page View',
    SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) AS 'Add to Cart'
FROM events
JOIN page_hierarchy ON events.page_id = page_hierarchy.page_id
WHERE page_hierarchy.product_category is not null
GROUP BY page_hierarchy.product_category
ORDER BY page_hierarchy.product_category;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/217b2bb1-b997-401f-8b01-a80a266da9b1)

### 1.9 What are the top 3 products by purchases?

```sql
SELECT 
    page_id,
    count(page_id)
FROM events
where event_type = 3
group by page_id;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/6e968854-b25b-43f3-98ad-3e7b1d6751a2)
> There is no enough information to answer this question, from the given dataset, we can only know all the purchased orders went through confirmation page.

## 2. Product Funnel Analysis

Using a single SQL query — create a new output table which has the following details:

| Question | event_type | event_name |
|---|---|---|
| How many times was each product viewed? | 1 | Page View |
| How many times was each product added to cart? | 2 | Add to Cart |
| How many times was each product added to a cart but not purchased (abandoned)? | 2 but not 3 |  |
| How many times was each product purchased? | 3 | Purchase |

## 3. Generate a table that has 1 single row for every unique visit_id record and has the following columns:

| Variable  | Definition | Table from | Variable from  |
|---|---|---|---|
| user_id |  | users | user_id |
| visit_id |  | events | visit_id |
| visit_start_time | the earliest event_time for each visit | events | event_time |
| page_views | count of page views for each visit | events | event_type = 1 |
| cart_adds | count of product cart add events for each visit | events | event_type = 2 |
| purchase | if a purchase event exists for each visit then 1 else 0 | events | event_type = 3 |
| campaign_name | if the visit_start_time falls between the start_date and end_date |  | visit_start_time |
| impression | count of ad impressions for each visit | events | event_type = 4 |
| click | count of ad clicks for each visit | events | event_type = 5 |

```sql
CREATE TABLE Campaigns AS
select 
    distinct user_id,visit_id,
    Min(start_date) as visit_start_time,
    sum(case when event_type = 1 then 1 else 0 end) as page_views,
    sum(case when event_type = 2 then 1 else 0 end) as cart_adds,
    sum(case when event_type = 3 then 1 else 0 end) as purchase,
    case
        when min(event_time) > '2020-01-01 00:00:00' and min(event_time) < '2020-01-14 00:00:00'
			then 'BOGOF - Fishing For Compliments'
		when min(event_time) > '2020-01-15 00:00:00' and min(event_time) < '2020-01-28 00:00:00'
			then '25% Off - Living The Lux Life'
		when min(event_time) > '2020-02-01 00:00:00' and min(event_time) < '2020-03-31 00:00:00'
			then 'Half Off - Treat Your Shellf(ish)' 
		else NULL
end as Campaign,
    sum(case when event_type = 4 then 1 else 0 end) as impression,
    sum(case when event_type = 5 then 1 else 0 end) as click
from events
join users on events.cookie_id = users.cookie_id
group by user_id,visit_id;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/b0085dc4-afb4-43cb-a748-6fb8e454350b)


Question:
1. Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
   ```r
   Campaigns <- read.csv("Campaigns.csv")
   Campaigns$visit_start_time <- as.Date(Campaigns$visit_start_time)
   # Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
   aggregate(cbind(page_views,
                   cart_adds,
                   purchase,
                   click) ~ impression, data = Campaigns, mean)
   ```
   ![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/59af1448-55c0-4f5e-a8b5-6daf8848d8ca)

   - As we can observe, for each metric, users who have received impressions during each campaign period showed a significant difference in compare with users who did not receive impressions:
     - Higher count of page views for each visit
     - Higher count of product cart add events for each visit
     - Greater probability that purchase event exists for each visit
     - Higher count of ad clicks for each visit
2. Does clicking on an impression lead to higher purchase rates?
   ```r
   lm1 <- lm(purchase ~ click, data = Campaigns)
   summary(lm1)
   ```
   ![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/57276a2c-69c5-44f3-bbdb-341a10e54b85)

   - The model is statistically significant, and the independent variable "click" has a significant positive effect on the dependent variable "purchase" -- clicking on an impression is correlated with a higher purchase rates? The model explains about 14.95% of the variance in the dependent variable.

3. What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to eachother?
