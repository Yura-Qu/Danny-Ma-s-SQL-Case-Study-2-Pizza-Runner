# Case Study #5 - Data Mart

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/8ce3870a-0951-4aad-82d5-38f4a3e0743a)

## Introduction 

Danny wants to address the impact of the sustainability changes at Data Mart:

1. Quantifying the Impact of Changes (June 2020):
   - Assess the measurable impact on sales performance post-implementation of sustainability changes.
2. Identifying Most Impacted Areas:
   - Determine which platforms (online, physical stores, etc.), regions, customer segments, and types were most affected by these changes.
3. Mitigating Impact on Future Sustainability Updates:
   - Develop strategies to minimize the potential negative impact on sales when introducing similar sustainability updates in the future.

These questions focus on evaluating the direct impact on sales after the implementation of sustainable packaging, identifying areas that were most affected, and devising strategies to mitigate any adverse effects during future sustainability updates.


### Available Data

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/08f7dd1f-0d28-42f0-81fe-1ddf98e5ef42)
- Customer `segment` and `customer_type` data relates to personal age and demographic information that is shared with Data Mart
- `transactions` is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases

## 1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the `data_mart schema` named `clean_weekly_sales`:
1. Convert the `week_date` to a **DATE** format
2. Add a `week_number` as the second column for each week_date value, for example, any value from the 1st of January to the 7th of January will be 1, the 8th to 14th will be 2 etc
3. Add a `month_number` with the calendar month for each `week_date` value as the 3rd column
4. Add a `calendar_year` column as the 4th column containing either 2018, 2019 or 2020 values
5. Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value
   | segment | age_band     |
   |---------|--------------|
   | 1       | Young Adults |
   | 2       | Middle Aged  |
   | 3 or 4  | Retirees     |
6. Add a new demographic column using the following mapping for the first letter in the segment values:
   | segment | demographic |
   |---------|-------------|
   | C       | Couples     |
   | F       | Families    |
7. Ensure all `null` string values with an "unknown" string value in the original segment column as well as the new `age_band` and demographic columns
8. Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

### Solution: 

> Create Table Using Another Table
> ``` sql
> CREATE TABLE new_table_name AS
>    SELECT column1, column2,...
>    FROM existing_table_name
>    WHERE ....;
> ```

| **Column Name** | **Explanation of the query** |
|---|---|
| week_dates | Transforming a date format from DD/MM/YY to YY/MM/DD to enhance readability, aligning it more closely with the common date reading pattern. |
| week_number | Based on the data cleaning guideline specifying week numbers, a rule was set: '1st to 7th January is Week 1, 8th to 14th is Week 2,' and so on. However, for 2020, the first calendar week spanned from the 1st to the 4th of January, making the 5th to the 11th the second week. To determine week numbers accordingly, I began by extracting the day of the year, dividing it by 7, and using the ceiling function to get the week number. |
| month_number | Extract the month |
| calendar_year | Extract the year  |
| region | region |
| platform | platform |
| segment | Replace `null` string values with an `unknown` string value |
| age_band | Self-explanatory |
| demographic | Self-explanatory |
| customer_type | customer_type |
| transactions | transactions |
| sales | sales |
| avg_transaction | the sales value divided by transactions rounded to 2 decimal places |

``` sql
CREATE TABLE clean_weekly_sales AS
SELECT  
    DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%y/%m/%d') AS week_dates,
    ceiling(dayofyear((DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%y/%m/%d')))/7) as week_number,
    month(DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%y/%m/%d')) as month_number,
    year(DATE_FORMAT(STR_TO_DATE(week_date, '%d/%m/%y'), '%y/%m/%d')) as calendar_year,
    region,
    platform,
    CASE
            WHEN segment = 'null' THEN 'unknow'
            ELSE segment
    END AS segment,
    CASE
            WHEN SUBSTRING(segment, 2, 1) = 1 THEN 'Young Adults'
            WHEN SUBSTRING(segment, 2, 1) = 2 THEN 'Middle Aged'
            WHEN SUBSTRING(segment, 2, 1)  IN (3,4) THEN 'Retirees'
            ELSE 'unknown'
    END AS age_band,
    CASE
            WHEN SUBSTRING(segment, 1, 1) IN ('C','c') THEN 'Couples'
            WHEN SUBSTRING(segment, 1, 1) IN ('F','f') THEN 'Families'
            ELSE 'unknown'
    END AS demographic,
    customer_type,
    transactions,
    sales,
    round(sales/transactions,2) AS avg_transaction
FROM weekly_sales;

SELECT * from clean_weekly_sales;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/53bcf06d-79b3-439f-af4b-2c99063974dd)

> why the specified data cleaning operations are beneficial:
> 1. Standardized Date Format: ensures uniformity, simplifying date-based analysis and calculations.
> 2. Week/Month/Year Number Addition: Adding the corresponding columns facilitates insights based on weeks, months or year, aiding in time scale performance evaluation and trend analysis.
> 3. Handling Null Values: Replacing null string values with "unknown" standardizes the dataset, preventing potential errors and ensuring uniformity in analysis.
> 4. Transaction Analysis: Calculating avgerage transaction provides a new metric for analyzing sales efficiency.

## 2. Data Exploration

### 1. What day of the week is used for each week_date value?

```sql
SELECT DISTINCT(dayname(week_dates)) from clean_weekly_sales;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/7f122492-706d-4aa1-a10f-cd25aa162b24)

### 2. What range of week numbers are missing from the dataset?

```sql
SELECT n AS week_number
FROM (
    SELECT ones.n + tens.n * 10 AS n
    FROM (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    ) ones
    CROSS JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ) tens
) numbers
WHERE n BETWEEN 1 AND 52
AND n NOT IN (SELECT DISTINCT week_number FROM clean_weekly_sales)
ORDER BY week_number;
```
The range of week number that missing are week 1-11, 37-49 

### 3. How many total transactions were there for each year in the dataset?

```sql
select 
    calendar_year,
    sum(transactions) as Total_transaction 
from clean_weekly_sales
group by calendar_year
order by calendar_year;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/786dab76-214e-4114-a009-da9d91500ef8)

- The Total transactions observed across 2018, 2019, and 2020 showed a consistent upward trend, with the sales of 346,406,460, 365,639,285, and 375,813,651, respectively.

### 4. What is the total sales for each region for each month?

```sql
select
    region,
    month_number,
    sum(sales) as total_sales
from clean_weekly_sales
group by region,month_number
order by region,month_number;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/d816f2ea-3939-4734-8e80-847e841c9361)

### 5. What is the total count of transactions for each platform

```sql
select 
	platform,
    sum(transactions) as counts
from clean_weekly_sales
group by platform;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/0de252e4-4064-4128-8538-04b8345b318f)

![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/f8d08e17-6258-4784-ada5-1b37b8b14fa8)

- Most transactions, about 99.5% totaling 1,081,934,227, were conducted via retail channels, while Shopify accounted for a mere 0.5%, totaling 5,925,169 transactions.

### 6. What is the percentage of sales for Retail vs Shopify for each month?

- CTE1: the total number sales for each month
- CTE2: the total number of sales for Retail vs Shopify for each month
- CTE3:
  - Join CTE1 and CTE2 so that the total number of sales are replicated
  - Calculate the percentage of sales for Retail vs Shopify for each month: Rentail / Shopify sales in a month / total sales in that month 

```sql
WITH CTE1 AS (
    SELECT 
		calendar_year,
        month_number,
        SUM(sales) AS total_sales
    FROM 
        clean_weekly_sales
    GROUP BY 
        calendar_year,
        month_number
	ORDER BY 
		calendar_year,
        month_number
),
CTE2 AS (
    SELECT 
		cws.calendar_year,
        cws.month_number,
        cws.platform,
        SUM(cws.sales) AS platform_sales
    FROM 
        clean_weekly_sales cws
    GROUP BY 
        cws.calendar_year,
        cws.month_number, 
        cws.platform
	ORDER BY 
		cws.calendar_year,
        cws.month_number, 
        cws.platform
)
SELECT 
	CTE2.calendar_year,
	CTE2.month_number,
    CTE2.platform,
    CTE2.platform_sales,
    round(CTE2.platform_sales / CTE1.total_sales,4) *100 AS percentage
FROM
    CTE2
JOIN
    CTE1 ON CTE1.month_number = CTE2.month_number
		AND CTE1.calendar_year = CTE2.calendar_year;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/0b62fa46-0ff6-4c72-8aa7-f09c51feee3a)

### 7. What is the percentage of sales by demographic for each year in the dataset?

```sql
with cte1 as (
select 
	calendar_year,
    demographic,
    sum(sales) as sales
from 
	clean_weekly_sales
group by
	calendar_year,
    demographic
order by 
	calendar_year,
    demographic
),
cte2 as (    
select
	calendar_year as cte2_year,
    sum(sales) as Total
from 
	clean_weekly_sales
group by 
	calendar_year
order by 
	calendar_year),
cte3 as (    
select * from cte1
join cte2
where 
	cte1.calendar_year = cte2_year
)
select 
	calendar_year,
    demographic,
    sales,
    round(sales/Total,4)*100 as percentage
from cte3
;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/d73db602-7678-4726-97e4-ed73d9d743ae)

- The majority of sales, approximately 40%, in the years 2018, 2019, and 2020 fall under the category of an unknown demographic. Following this, around 30% of sales are attributed to families, while couples represent the smallest portion.

### 8. Which age_band and demographic values contribute the most to Retail sales?

```sql
select 
    age_band,
    demographic,
    sum(sales),
    sum(sales)/ SUM(SUM(sales)) OVER () *100 As Retail_sales
from 
    clean_weekly_sales
where 
    platform = 'Retail'
group by 
    age_band,
    demographic
order by 
    Retail_sales desc
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/81f9f781-65be-481d-b7e6-9b68d2f388fa)

- The largest share of retail sales, constituting 42%, comes from an unknown age_band and demographic. Following this, retired families contribute 16.73%, and retired couples make up 16.07% of the total sales.

### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg1, 
  SUM(sales) / sum(transactions) AS avg2
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```

## 3. Before & After Analysis

> This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
>
> Taking the `week_date` value of **2020-06-15** as the baseline week where the Data Mart sustainable packaging changes came into effect.
>
> We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

### 10. 
#### What is the total sales for the 4 weeks before and after 2020-06-15? 

```sql
WITH CTE1 as (
Select *
from clean_weekly_sales
where 
    (dayofyear(DATE_FORMAT(week_dates, '%y/%m/%d')) > dayofyear(DATE_FORMAT('2020/06/15', '%y/%m/%d'))-28
    and week_dates < DATE_FORMAT('2020/06/15', '%y/%m/%d')
	and calendar_year = 2020 )
    or (dayofyear(DATE_FORMAT(week_dates, '%y/%m/%d')) < dayofyear(DATE_FORMAT('2020/06/15', '%y/%m/%d'))+28
    and week_dates > DATE_FORMAT('2020/06/15', '%y/%m/%d')
	and calendar_year = 2020 )
order by week_number),
CTE2 as (
select *,
    CASE
    WHEN week_number < 24 THEN 'Bef'
    WHEN week_number > 24 THEN 'Aft'
  END AS Intervention
from CTE1)
SELECT 
    Intervention,
    SUM(transactions) AS transaction_,
    SUM(sales) as sales_,
    sum(sales)/ SUM(SUM(sales)) OVER () *100 As Percentage
from CTE2
group by Intervention
;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/4b6bb887-4461-4694-a8f0-8fc49b200c8b)

- CTE1
  - Select dates within a 28-day (4 weeks) window centered around (before and after) 2020/06/15.

- CTE2
  - Introduce a new column with the following labels:
    - 'BEF' for dates falling within 4 weeks before 2020/06/15.
    - 'AFT' for dates falling within 4 weeks after 2020/06/15.

- Finally, I computed:
  - The total number of transactions during the 4 weeks before and after 2020/06/15, respectively.
  - The total sales amount for the 4 weeks before and after 2020/06/15, respectively.
  - The percentage of sales during the 4 weeks before and after 2020/06/15, respectively.
    
#### What is the growth or reduction rate in actual values and percentage of sales?

```sql
WITH CTE1 as (
Select *
from clean_weekly_sales
where 
    (dayofyear(DATE_FORMAT(week_dates, '%y/%m/%d')) > dayofyear(DATE_FORMAT('2020/06/15', '%y/%m/%d'))-28
    and week_dates < DATE_FORMAT('2020/06/15', '%y/%m/%d')
	and calendar_year = 2020 )
    or (dayofyear(DATE_FORMAT(week_dates, '%y/%m/%d')) < dayofyear(DATE_FORMAT('2020/06/15', '%y/%m/%d'))+28
    and week_dates > DATE_FORMAT('2020/06/15', '%y/%m/%d')
	and calendar_year = 2020 )
order by week_number),
CTE2 as (
select *,
    CASE
    WHEN week_number < 24 THEN 'Bef'
    WHEN week_number > 24 THEN 'Aft'
  END AS Intervention
from CTE1)
SELECT 
    Intervention,
    SUM(transactions) AS transaction_,
    SUM(transactions) - LAG(SUM(transactions)) OVER (ORDER BY Intervention) AS Intervention_difference,
    SUM(transactions) / LAG(SUM(transactions)) OVER (ORDER BY Intervention) AS Intervention_difference
from CTE2
group by Intervention;
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/142e5901-0c96-4b0f-b773-7542c602d876)

Similarly: 

- CTE1
  - Select dates within a 28-day (4 weeks) window centered around (before and after) 2020/06/15.

- CTE2
  - Introduce a new column with the following labels:
    - 'BEF' for dates falling within 4 weeks before 2020/06/15.
    - 'AFT' for dates falling within 4 weeks after 2020/06/15.

- Finally, I computed:
  - The total number of transactions during the 4 weeks before and after 2020/06/15, respectively.
  - The difference of the sales amount for between the 4 weeks before and after 2020/06/15, respectively.
  - The growth rate of sales during the 4 weeks before and after 2020/06/15, respectively.
    
> Summary:
> Following the introduction of the new sustainable packaging, there has been a increase in sales, resulting in an increase of $102,587. This corresponds to a growth rate of 1.22%.


### 11. What about the entire 12 weeks before and after?

In this instance, I reused the code from the preceding question, modifying the filtering criterion from 24 days (4 weeks) to 84 days (12 weeks). The outcome is as follows:
>![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/3ea3fa2c-6504-42c1-9125-cc3f1d89ce77)
>
>![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/370eb20d-4926-4f94-a942-31e8e6ee2301)
>
>In this scenario, the count of transactions within the 12-week window before and after 2020/06/15 experienced a decrease of $1,607,880, indicating a reduction of 00.94%.

Then I used R to visualise the sales difference within the 12-week window before and after 2020/06/15 

```r
library(dplyr)
sales<-read.csv("sales.csv")
sales$week_dates <- ymd(sales$week_dates)
sum_sales <- sales %>%
  group_by(week_dates) %>%
  summarize(total_sales = sum(sales))
plot(sum_sales$week_dates,sum_sales$total_sales,
     type = "l",
     xlab = "week_dates",
     ylab = "sales")
abline(v = ymd("2020/06/15"),
       col = "red")
abline(h = mean(sum_sales$total_sales[sum_sales$week_dates<ymd("2020/06/15")]),
       col = "blue")
abline(h = mean(sum_sales$total_sales[sum_sales$week_dates>ymd("2020/06/15")]),
       col = "green")
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/40c7dd32-72d0-4e9e-8882-548a0b09e8a9)

- In this visual representation, the vertical red line signifies the cutoff date of 2020/06/15.
- The blue horizontal line corresponds to the average sales within the 12-week window before 2020/06/15.
- The green horizontal line indicates the average sales within the 12-week window after 2020/06/15.
- A noticeable descending trend in sales is evident from the graph.

> However, we should also consider the seasonal pattern of sales:
```r
library(tsibble)
library(dplyr)
library(lubridate)
library(feasts)

sales <- read.csv("1.csv")
sales$week_dates <- ymd(sales$week_dates)

sum_sales <- sales %>%
  mutate(Month = yearmonth(week_dates)) %>%
  group_by(Month) %>%
  summarize(total_sales = sum(sales))

# Convert to tsibble and fill gaps
sum_sales <- as_tsibble(sum_sales, index = Month) 

plot(sum_sales$Month[1:7], sum_sales$total_sales[1:7],
     type = "l")

ggplot(sum_sales, aes(x = Month, y = total_sales)) +
  geom_line() +
  labs(title = "Total Sales Over Time")+
  geom_vline(xintercept = as.numeric(ymd("2020/06/15")), linetype = "dashed", color = "blue") 
```
![image](https://github.com/Yura-Qu/SQL-Case-Study/assets/143141778/b21da147-ad40-4d51-9b45-e8f93b40dba2)

We can observe a distinct seasonal pattern based on the data from 2018 to 2020: 
- According to the trends in 2018 and 2019, we anticipate a peak in sales around April and July, with a corresponding drop in sales between April and July.
- However, in 2020, sales continue to rise from April to June, coinciding with the introduction of new sustainable packaging in mid-June. Surprisingly, there is an unexpected decline in sales in July, followed by a recovery in August.
- Consequently, attributing the fluctuations in sales solely to the introduction of the new sustainable packaging may be challenging, given the deviation from the typical sales patterns observed in previous years.
