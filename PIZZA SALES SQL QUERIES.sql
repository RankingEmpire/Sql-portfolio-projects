SELECT * FROM pizza_sales

 -- TOTAL REVENUE 
 SELECT SUM (total_price) as Total_Revenue 
	from pizza_sales

-- GETTING AVERAGE ORDER VALUE 
SELECT SUM(total_price) / count (distinct order_id) as Avg_Order_Value
from pizza_sales

---- total pizza sold 
select sum(quantity) as total_pizza_sold
from pizza_sales

-- Total orders
select count (distinct order_id)as total_orders 
from pizza_sales

--Average pizza per order 
select cast (sum(quantity) / 
count(distinct order_id) as decimal(10,2)) as  Avg_pizza_per_order
from pizza_sales

--daily trends for orders 
SELECT DATENAME (DW, order_date) as order_day , count (distinct order_id ) as Total_orders 
from pizza_sales
GROUP BY  DATENAME (DW, order_date)

--HOURLY TRENDS
SELECT DATEPART (HOUR, order_time) as order_hours,count (distinct order_id ) as Total_orders 
from pizza_sales
GROUP BY DATEPART (HOUR, order_time)
ORDER BY DATEPART (HOUR, order_time)

--- PERCENTAGE SALES BY PIZZA CATEGORY
SELECT pizza_category, SUM (total_price) * 100 /
(SELECT SUM(total_price) from pizza_sales WHERE MONTH (order_date) =1) AS PCT
FROM pizza_sales
WHERE MONTH (order_date) =1 
GROUP BY pizza_category

-- PERCENTAGE SALES BY PIZZA SIZE
SELECT pizza_size, CAST (SUM (total_price)AS decimal(10,2)) as total_sales, CAST (SUM (total_price) * 100 /
(SELECT SUM(total_price) from pizza_sales WHERE DATEPART (QUARTER, order_date) =1 )AS decimal(10,2)) AS PCT
FROM pizza_sales
WHERE DATEPART (QUARTER, order_date) =1
GROUP BY pizza_size
ORDER BY PCT DESC

--TOTAL PIZZA SOLD BY PIZZA CATEGORY
select pizza_category, sum(quantity) as total_pizza_sold
from pizza_sales
GROUP BY pizza_category

--TOP 5 BEST SELLERS BY PIZZA SOLD 
select top 5 pizza_name, sum(quantity) as total_pizza_sold
from pizza_sales
GROUP BY pizza_name
order by sum(quantity) Desc

--BOTTOM 5 SELLERS BY PIZZA SOLD
select top 5 pizza_name, sum(quantity) as total_pizza_sold
from pizza_sales
GROUP BY pizza_name
order by sum(quantity) ASC 