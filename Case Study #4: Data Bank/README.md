# Case Study #4: Data Bank

## Introduction 
In the financial sector, Neo-Banks, digital-only banks without physical branches, have emerged as an innovative trend. Danny, envisioning a blend of these modern banks, cryptocurrency, and data, spearheads a new venture - Data Bank.

Unlike conventional digital banks, Data Bank handles financial transactions and operates as the most secure distributed data storage platform globally. Customers' cloud data storage limits correlate directly with their account balances. However, several intricacies in this model prompt the Data Bank team to seek assistance.

The management aims to expand its customer base while accurately forecasting the required data storage. This case study delves into metrics calculation, growth analysis, and strategic data assessment to better forecast and plan future developments at Data Bank.

### Available Data

#### Entity Relationship Diagram

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/c83ad6dc-cd12-4df6-9875-37e569f378dc)

1. **Table 1: Regions**
   | region_id | region_name |
   |-----------|-------------|
   | 1         | Africa      |
   | 2         | America     |
   | 3         | Asia        |
   | 4         | Europe      |
   | 5         | Oceania     |
2. **Table 2: Customer Nodes**
   | customer_id | region_id | node_id | start_date | end_date   |
   |-------------|-----------|---------|------------|------------|
   | 1           | 3         | 4       | 2020-01-02 | 2020-01-03 |
   | 2           | 3         | 5       | 2020-01-03 | 2020-01-17 |
   | 3           | 5         | 4       | 2020-01-27 | 2020-02-18 |
   | 4           | 5         | 4       | 2020-01-07 | 2020-01-19 |
3. **Table 3: Customer Transactions**
   | customer_id | txn_date   | txn_type | txn_amount |
   |-------------|------------|----------|------------|
   | 429         | 2020-01-21 | deposit  | 82         |
   | 155         | 2020-01-10 | deposit  | 712        |
   | 398         | 2020-01-01 | deposit  | 196        |
   | 255         | 2020-01-14 | deposit  | 563        |

## A. Customer Nodes Exploration

### 1. How many unique nodes are there in the Data Bank system?

```sql
select count(distinct(node_id)) from customer_nodes;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/b4e0518d-87f3-4b78-b3ce-ba5fe72feefd)
- There are 5 unique nodes. 

### 2. What is the number of nodes per region?

```sql
SELECT c.region_id,
       region_name,
       COUNT(node_id) AS num_of_nodes
FROM customer_nodes c
INNER JOIN regions r ON c.region_id = r.region_id
GROUP BY c.region_id, region_name
ORDER BY num_of_nodes DESC;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/e0006406-f84b-4226-8cdf-37a27cbb006c)

- Australia has the most nodes (770)
- Europe has the least nodes (616)

### 3. How many customers are allocated to each region?

```sql
SELECT
    c.region_id,
    region_name,
    COUNT(DISTINCT customer_id) AS No_of_customers
FROM
    customer_nodes AS c
JOIN
    regions AS r ON c.region_id = r.region_id
GROUP BY
    c.region_id,
    region_name;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/df50ed1d-4b7d-43ac-8171-c8857d9e8388)

- Australia has the most customers (110)
- Europe has the least customers (88)
- The count of nodes within a region correlates with the quantity of customers within the same region.

### 4. How many days on average are customers reallocated to a different node?

```sql
WITH cte AS (
    SELECT 
        *,
        RANK() OVER(PARTITION BY customer_id ORDER BY node_id) AS customer_rank,
        DATEDIFF(end_date, start_date) AS date_difference
    FROM 
        customer_nodes
    WHERE 
        end_date != '9999-12-31'
),
cte1 AS (
    SELECT 
        customer_id,
        customer_rank,
        SUM(date_difference) AS total_nodes
    FROM cte
    GROUP BY customer_id, customer_rank
)
SELECT ROUND(AVG(total_nodes)) FROM cte1;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/14612e89-8f47-41d4-abe9-5f0ecdd75787)
- First, I generated a CTE called `cte` to
  - Generate a ranking system specific to each customer based on the nodes they are assigned to. This ranking is independent between customers, ensuring identification of the node a customer was allocated. If a customer is repeatedly assigned to the same node at different times, the 'customer_rank' remains the same.
  - Additionally, compute the duration spent by each customer on the node during each occurrence by using `DATEDIFF`.
  - Remove instances of the anomalous end date '9999-12-31'."
- Then, I generated the second CTE called `cte1` to calculate the total days that each customer spent on each nodes on different days.
- Lastly, I calculated the average number of days that a customer is relocated to a different node.
> On average, customers are reassigned to a new node approximately every 24 days.

### 5. What is the median, 80th, and 95th percentile for this same reallocation days metric for each region?
