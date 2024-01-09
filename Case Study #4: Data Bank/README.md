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

> I am still figuring out how to find the median, 80th, and 95th percentile. But here is the average...
```sql
WITH cte AS (
    SELECT 
        *,
        DATEDIFF(end_date, start_date) AS date_difference 
    FROM 
        customer_nodes
    WHERE 
        end_date != '9999-12-31'
    ORDER BY 
        customer_id
)
SELECT 
    region_id,
    AVG(date_difference) AS average_date_difference
FROM 
    cte
GROUP BY
    region_id
ORDER BY 
    region_id;
```

## B. Customer Transactions

### 6. What is the unique count and total amount for each transaction type?

```sql
select 
    txn_type,
    count(txn_type) as transation_count,
    sum(txn_amount) as transaction_amount,
    avg(txn_amount) as avg_transaction
from 
    customer_transactions
group by 
    txn_type;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/932b6d58-9c8f-4915-a5bf-56fcb549de62)


- Deposits constitute the highest transaction count (2671), while withdrawals mark the lowest transaction count (1580).
- Deposits also represent the highest total transaction amount (1359168), whereas withdrawals exhibit the lowest total transaction amount (793003).
- The average transaction amount is highest for deposits (508.8611) and lowest for purchases (498.7860).

### 7. What is the average total historical deposit counts and amounts for all customers?

```sql
select 
    txn_type,
    count(txn_type) as transation_count,
    sum(txn_amount) as transaction_amount,
    avg(txn_amount) as avg_transaction
from 
    customer_transactions
group by 
    txn_type;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/60c6b1ce-9533-4e5b-a962-64b9e5730ce5)

- The average deposit counts per customer is 5 and the average deposit amount per customer is 509.

### 8. For each month — how many Data Bank customers make more than 1 deposit and either one purchase or withdrawal in a single month?

```sql
WITH monthly_amount AS (
    SELECT 
        *,
        MONTH(txn_date) AS months,
        CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END AS deposit_amount,
        CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END AS purchase_amount,
        CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END AS withdrawal_amount 
    FROM 
        customer_transactions 
), aa AS (
SELECT 
    customer_id,
    months,
    SUM(deposit_amount) AS sum_deposit_amount,
    SUM(purchase_amount) AS sum_purchase_amount,
    SUM(withdrawal_amount) AS sum_withdrawal_amount,
    SUM(purchase_amount) + SUM(withdrawal_amount) AS purchase_withdrawal
FROM 
    monthly_amount 
GROUP BY 
    customer_id, months 
HAVING 
    sum_deposit_amount > 1 
AND 
    (sum_purchase_amount = 1 or sum_withdrawal_amount =1)
AND 
    purchase_withdrawal = 1
ORDER BY 
    customer_id) 
    
select 
    months,
    count(customer_id) as customer_count
from 
    aa
group by 
    months;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/5279b89d-b440-4f5b-8b06-c20ae22e3e30)

1. First I made three dummy variables:
   1. deposit_amount = 1 when transaction type = deposit, otherwise = 0
   2. purchase_amount = 1 when transaction type = purchase, otherwise = 0
   3. withdrawal_amount = 1 when transaction type = withdrawal, otherwise = 0
2. Then I calculated the total transaction amount of each type of the transaction type
3. I filtered only the results that
   1. Has more than 1 deposit
   2. And either one purchase or withdrawal
   in a month
> January had the highest number of customers (53) who had made more than 1 deposit and either 1 withdrawal or 1 deposit, while April had the least number of such customers (22).

### 9. What is the closing balance for each customer at the end of the month?

> First, I checked how many months of data is recorded
> ```sql
> select distinct(month(txn_date)) from customer_transactions;
> ```
> ![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/edd026fa-b9a9-49ef-bf29-db6caf1805e5)
>
> In the period from January to April 2020, the `customer_transaction` dataset recorded entries only for transaction occurrences. For these months, the closing balance remains consistent with the preceding month's closing balance."
> - For example: for customer 1, there were only records for January and March:
>   ![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/df9d988c-7516-498d-93dc-c06e714a7c01)



```sql
WITH cte AS (
    SELECT 
        *,
        MONTH(txn_date) AS months,
        CASE
            WHEN txn_type = 'deposit' THEN ABS(txn_amount)
            WHEN txn_type IN ('purchase', 'withdrawal') THEN -txn_amount
            ELSE txn_amount
        END AS modified_amount
    FROM 
        customer_transactions
)
SELECT 
    customer_id,
    months,
    SUM(SUM(modified_amount)) OVER (PARTITION BY customer_id ORDER BY months) AS cumulative_sum
FROM 
    cte
GROUP BY 
    customer_id, 
    months
ORDER BY 
    customer_id, 
    months;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/839ada6a-48bc-4b6b-9c63-b7c79158681e)

1. Interpretation of different transaction types:
   1. Deposits refer to money added or credited to an account, typically reflecting an increase in funds -- positive 
   2. Withdrawals signify money taken out or debited from an account, usually indicating a decrease in funds -- negative
   3. Purchases represent transactions made using the Data Bank debit card, indicating a decrease in funds -- negative
      > Thus I used `CASE WHEN` to change the transaction amount accordingly
2. Then I calculated the cumulative account balance of each customer by month by using the window function:
   `SUM(SUM(modified_amount)) OVER (PARTITION BY customer_id ORDER BY months)`
   
   1. `SUM(modified_amount):` This calculates the sum of the modified_amount column within each group defined by `customer_id` and `months`.
   2. `OVER (PARTITION BY customer_id ORDER BY months)`: This clause establishes the window frame or partition. It groups the data by `customer_id` and orders them within each partition based on the `months` column.
   3. The outer `SUM()` function then computes the cumulative sum across these partitions.
> If there are missing months, it means no transactions during those periods, thus the closing balance remains the same from the preceding month.

### 10. What is the percentage of customers who increase their closing balance by more than 5%?

## C. Data Allocation Challenge

### 11. Running a customer balance column that includes the impact of each transaction

```sql
SELECT 
    customer_id,
    txn_date,
    txn_type,
    txn_amount,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type = 'withdrawal' THEN -txn_amount
            WHEN txn_type = 'purchase' THEN -txn_amount
            ELSE 0
        END
    ) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance
FROM 
    customer_transactions;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/12a0a9a9-2516-4295-a8e6-4131ed3c3310)

- `SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount WHEN txn_type = 'withdrawal' THEN -txn_amount WHEN txn_type = 'purchase' THEN -txn_amount ELSE 0 END) OVER(PARTITION BY customer_id ORDER BY txn_date) AS running_balance`:
  - Uses a `CASE` statement to categorize transactions into deposits, withdrawals, and purchases, adjusting the amounts accordingly by making withdrawals and purchases negative.
  - Utilizes the `SUM()` function combined with `OVER(PARTITION BY customer_id ORDER BY txn_date)` to calculate a running balance for each customer_id by aggregating the adjusted transaction amounts based on the transaction date order.

### 12. Customer balance at the end of each month

```sql
SELECT 
    customer_id,
    MONTH(txn_date) AS transaction_month,
    SUM(
        CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            WHEN txn_type = 'withdrawal' THEN -txn_amount
            WHEN txn_type = 'purchase' THEN -txn_amount
            ELSE 0
        END 
    ) AS total_amount
FROM 
    customer_transactions
GROUP BY 
    customer_id, transaction_month
ORDER BY 
    customer_id;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/69ed87c4-db6e-4076-9fc5-55a648b5c030)

### 13. minimum, average, and maximum values of the running balance for each customer

```sql
WITH cte AS (
    SELECT 
        customer_id,
        MONTH(txn_date) AS Month,
        SUM(
            CASE 
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type = 'withdrawal' THEN -txn_amount
                WHEN txn_type = 'purchase' THEN -txn_amount
                ELSE 0
            END
        ) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance 
    FROM 
        customer_transactions
)
SELECT 
    customer_id,
    ROUND(AVG(running_balance)) AS Average,
    MIN(running_balance) AS Minimum,
    MAX(running_balance) AS Maximum
FROM 
    cte
GROUP BY 
    customer_id
ORDER BY 
    customer_id;
```

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/6f983cdb-56e3-4279-acd7-15829e4e2076)

