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

