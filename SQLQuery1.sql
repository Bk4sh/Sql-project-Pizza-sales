use portfolioProject;

select * from pizza_sales;

--Total Revenue
select round(SUM(total_price), 2) as total_revenue from pizza_sales;

--Average order value: The average amount spent per order, calculated dividing total_revenue by the total number of orders 
select ROUND(SUM(total_price)/COUNT(distinct order_id), 2) as avg_order_value from pizza_sales;

--Total pizzas sold: the sum of the quantities of all pizzas sold
select SUM(quantity) as total_pizzas_sold from pizza_sales;

--Total orders: The total number of order placed.
select COUNT(distinct order_id) as total_orders from pizza_sales;

--Average pizzas per order: the average number of pizzas sold per order, calculated by dividing the total number of pizzas sold by the total total number of orders.
select
	CAST(SUM(quantity) as decimal(10, 2))/
	CAST(COUNT(distinct order_id) as decimal(10, 2)) as average_pizzas_per_order
from pizza_sales;

--Daily trend for total orders
select
	DATENAME(DW,order_date) as order_day,
	COUNT(distinct order_id) as orders_per_day
from pizza_sales
group by DATENAME(DW,order_date);

--Hourly trend for total orders
select
	DATEPART(HOUR, order_time) as order_hour,
	COUNT(distinct order_id) as order_per_hour
from pizza_sales
group by DATEPART(HOUR, order_time)
order by DATEPART(HOUR, order_time);

--Percentage of sales by pizza category
with mycte as (
	select
		pizza_category,
		CAST(SUM(total_price) as decimal(10, 2)) as sales_per_category
	from pizza_sales
	group by pizza_category
)
select
	pizza_category,
	CAST(sales_per_category*100/SUM(sales_per_category) over() as decimal(10, 2)) as percentage_sales_per_category 
from mycte
order by pizza_category;

--Percentage of sales by pizza category and per month
with mycte1 as (
	select
		pizza_category,
		MONTH(order_date) as months,
		CAST(SUM(total_price) as decimal(10, 2)) as sales_per_category_month
	from pizza_sales
	group by pizza_category, MONTH(order_date)
)
select
	*,
	CAST(sales_per_category_month*100/SUM(sales_per_category_month) over() as decimal(10, 2)) as percentages
from mycte1
--where months = 1
order by pizza_category, months;


--Percentage of sales by pizza category and n month
with mycte1 as (
	select
		pizza_category,
		MONTH(order_date) as months,
		CAST(SUM(total_price) as decimal(10, 2)) as sales_per_category_month
	from pizza_sales
	group by pizza_category, MONTH(order_date)
),
mycte2 as (
	select
		*,
		CAST(sales_per_category_month*100/SUM(sales_per_category_month) over() as decimal(10, 2)) as percentages
	from mycte1
)
select * from mycte2 where months = 12 order by pizza_category;


--Percentage of sales by pizza size
with mycte3 as (
	select
		pizza_size,
		SUM(total_price) as sales_per_size
	from pizza_sales
	group by pizza_size
)
select
	pizza_size,
	CAST(sales_per_size as decimal(10, 2)) as sales_per_size,
	CAST(sales_per_size*100/SUM(sales_per_size) over() as decimal(10, 2)) as percentage_sales_per_size
from mycte3
order by pizza_size;

--Percentage of sales by pizza size in quarter
SELECT
    pizza_size,
    CASE
        WHEN DATEPART(QUARTER, order_date) = 1 THEN 'Q1'
        WHEN DATEPART(QUARTER, order_date) = 2 THEN 'Q2'
        WHEN DATEPART(QUARTER, order_date) = 3 THEN 'Q3'
        ELSE 'Q4'
    END AS quarters,
    CAST(SUM(total_price) as decimal(10, 2)) AS sales_per_quarters
FROM pizza_sales
--WHERE order_date BETWEEN '2015-01-01' AND '2015-03-31'
GROUP BY pizza_size, DATEPART(QUARTER, order_date)
ORDER BY pizza_size, DATEPART(QUARTER, order_date);


--Total pizzas sold by category
select
	pizza_category,
	sum(quantity) as total_pizza_sold
from pizza_sales
group by pizza_category;


--Top 5 best pizzas by total pizzas sold
select TOP 5
	pizza_name,
	SUM(quantity) as total_pizza
from pizza_sales
--where MONTH(order_date) = 1
group by pizza_name
order by SUM(quantity) desc;


--bottom 5 best pizzas by total pizzas sold
select TOP 5
	pizza_name,
	SUM(quantity) as total_pizza
from pizza_sales
--where MONTH(order_date) = 1
group by pizza_name
order by SUM(quantity) asc;