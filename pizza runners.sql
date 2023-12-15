# create dataset
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

# data cleaning 
DROP TABLE IF EXISTS customer_orders_temp;
CREATE TABLE customer_orders_temp AS
  SELECT 
    order_id, 
    customer_id, 
    pizza_id, 
    CASE
      WHEN exclusions IS NULL OR exclusions = '' THEN NULL
      WHEN exclusions = 'null' THEN NULL
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IS NULL OR extras = '' THEN NULL
      WHEN extras = 'null' THEN NULL
      ELSE extras
    END AS extras,
    order_time
  FROM customer_orders;
  SELECT * FROM customer_orders_temp;
  
  SELECT * FROM runner_orders;
  DROP TABLE IF EXISTS runner_orders_temp;
CREATE TABLE runner_orders_temp AS
 SELECT 
   order_id, 
   runner_id, 
   CASE
     WHEN pickup_time = 'null' THEN NULL
     ELSE pickup_time
   END AS pickup_time,
   CASE
     WHEN distance = 'null' THEN NULL
     WHEN distance LIKE '%km' THEN TRIM('km' from distance)
     ELSE distance 
   END AS distance,
   CASE
     WHEN duration = 'null' THEN NULL
     WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
     WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
     WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
     ELSE duration
   END AS duration,
   CASE
     WHEN cancellation IS NULL or cancellation = 'null' THEN ''
     ELSE cancellation
   END AS cancellation
  FROM runner_orders;
  
 
ALTER TABLE runner_orders_temp
  MODIFY COLUMN pickup_time TIMESTAMP,
  MODIFY COLUMN distance DECIMAL(10,2), 
  MODIFY COLUMN duration INT;
 SELECT * FROM runner_orders_temp;
 
 # How many pizzas were ordered?
 SELECT COUNT(order_id) AS ordered_pizza 
  FROM customer_orders_temp;

# How many unique customer orders were made?
SELECT COUNT(distinct(order_id)) AS unique_ordered_pizza 
 FROM customer_orders_temp;
 
 # How many successful orders were delivered by each runner?
 SELECT * FROM runner_orders_temp;

SELECT runner_id, COUNT(runner_id) AS runner_count
FROM runner_orders_temp
WHERE cancellation = ''
GROUP BY runner_id
ORDER BY runner_count DESC;

# How many of each type of pizza was delivered?
SELECT * FROM runner_orders_temp;
SELECT * FROM Practice1.customer_orders_temp;

# Join the table:runner_orders_temp, customer_orders_temp, pizza_names
SELECT *
FROM runner_orders_temp
JOIN customer_orders_temp
USING (order_id)
JOIN pizza_names
USING (pizza_id)
WHERE DISTANCE IS NOT NULL;

SELECT pizza_name, COUNT(pizza_id) 
FROM runner_orders_temp
JOIN customer_orders_temp
USING (order_id)
JOIN pizza_names
USING (pizza_id)
WHERE DISTANCE IS NOT NULL
GROUP BY pizza_name;

# How many Vegetarian and Meatlovers were ordered by each customer?

SELECT *
FROM customer_orders_temp
JOIN pizza_names
USING (pizza_id);

SELECT customer_id, pizza_name, COUNT(customer_id) AS pizza_count
FROM customer_orders_temp
JOIN pizza_names
USING (pizza_id)
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

# What was the maximum number of pizzas delivered in a single order?
SELECT order_id, order_count AS max_order_count
FROM (
    SELECT order_id, COUNT(*) AS order_count
    FROM customer_orders_temp
    JOIN runner_orders_temp USING (order_id)
    WHERE distance IS NOT NULL
    GROUP BY order_id
) AS counted_orders
ORDER BY order_count DESC
LIMIT 1;

# How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(*)
    FROM customer_orders_temp
    JOIN runner_orders_temp USING (order_id)
    WHERE distance IS NOT NULL
    AND exclusions IS NOT NULL
    AND extras IS NOT NULL;
# For each customer, how many delivered pizzas had at least 1 change, and how many had no changes?

SELECT *
    FROM customer_orders_temp
    JOIN runner_orders_temp USING (order_id)
    WHERE distance IS NOT NULL;
    
SELECT customer_id,
  SUM(CASE
    WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1
    ELSE 0
  END) AS Changed,
   SUM(CASE
    WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 0
    ELSE 1
  END) AS Unchanged
FROM (
  SELECT *
  FROM customer_orders_temp
  JOIN runner_orders_temp USING (order_id)
  WHERE distance IS NOT NULL
) AS combined_orders
GROUP BY customer_id;

# What was the total volume of pizzas ordered for each hour of the day?

SELECT 
EXTRACT(HOUR FROM order_time) AS hour_of_day, 
count(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY hour_of_day
ORDER BY hour_of_day;

# What was the volume of orders for each day of the week?

SELECT DAYNAME(order_time) AS day_of_week,
   COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY day_of_week
ORDER BY pizza_count DESC;
