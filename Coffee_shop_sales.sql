SELECT * FROM coffee_sales


--covert transaction_date  into a proper date format
UPDATE coffee_sales
SET transaction_date = CONVERT(DATE,transaction_date, 103);

ALTER TABLE coffee_sales 
ALTER COLUMN transaction_date DATE;

--covert transaction_time into a proper time format 
UPDATE coffee_sales
SET transaction_time = CONVERT(TIME,transaction_time, 108);

ALTER TABLE coffee_sales 
ALTER COLUMN transaction_time TIME;

--TOTAL SALES ANALYSIS
-- CALCULATING THE TOTAL SALES FOR EACH RESPECTIVE MONTH

SELECT CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1),'K') AS TOTAL_SALES
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 --May Month

--Month on month increase or decrease in total sales

SELECT 
	MONTH(transaction_date) as MONTH,
	ROUND(SUM(unit_price * transaction_qty),1) as total_sales,
	(SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1) -- month sales difference
	OVER (ORDER BY MONTH (transaction_date))) / LAG(SUM(unit_price * transaction_qty),1) -- Division by PM sales
	OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increas_percentage --- Percentange 
FROM coffee_sales
WHERE 
	MONTH(transaction_date) IN (4,5)
GROUP BY 
	MONTH(transaction_date)
ORDER BY 
	MONTH(transaction_date);

-- Total orders analysis 
-- calculating the total number of orders for each respective month
SELECT	
	COUNT(transaction_id) AS Total_Orders
FROM 
	coffee_sales
WHERE 
	MONTH(transaction_date) = 3 -- may month

--Month on month increase or decrease in total orders
SELECT 
	MONTH(transaction_date) as MONTH,
	COUNT (transaction_id) as Total_orders,
	(COUNT(transaction_id) - LAG(COUNT(transaction_id),1) -- order difference
	OVER (ORDER BY MONTH (transaction_date))) / LAG(COUNT(transaction_id),1) -- Division by PM ORDERS
	OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increas_percentage --- Percentange 
FROM coffee_sales
WHERE 
	MONTH(transaction_date) IN (4,5)
GROUP BY 
	MONTH(transaction_date)
ORDER BY 
	MONTH(transaction_date);

--TOTAL QUANTITY SOLD 
-- CALCULATING TOTAL NUMBERS OF QUANTITY SOLD FOR EACH RESPECTIVE MONTH 

SELECT SUM(transaction_qty)AS TOTAL_QUANTITY_SOLD
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 --May Month

-- Month on month increase or decrease in total quantity sold 
SELECT 
	MONTH(transaction_date) as MONTH,
	SUM (transaction_qty) as Total_quantity_sold,
	(SUM (transaction_qty) - LAG(SUM(transaction_qty),1) -- order difference
	OVER (ORDER BY MONTH (transaction_date))) / LAG(COUNT(transaction_qty),1) -- Division by PM ORDERS
	OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increas_percentage --- Percentange 
FROM coffee_sales
WHERE 
	MONTH(transaction_date) IN (4,5) -- for april and may
GROUP BY 
	MONTH(transaction_date)
ORDER BY 
	MONTH(transaction_date);


--CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
	CONCAT(ROUND (SUM(unit_price * transaction_qty)/ 1000 ,1), 'K') as total_sales,
	CONCAT(ROUND (COUNT(transaction_id)/1000 ,1),'K') AS total_orders,
	CONCAT(ROUND (SUM(transaction_qty)/1000 ,1),'K') AS total_quantity_sales
FROM coffee_sales
WHERE transaction_date = '2023-05-18'

--SALES ANALYSIS BY WEEKEND AND WEEKDAYS 
  -- WEEKEND = SAT AND SUNDAY 
  -- WEEKDAYS = MON - FRI
 
 SELECT 
	CASE 
	WHEN DATEPART(WEEKDAY,transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
	END AS DAY_TYPE, 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS TotalSales
 FROM coffee_sales
 WHERE 
	MONTH(transaction_date) = 5
 GROUP BY  
	CASE 
	WHEN DATEPART(WEEKDAY,transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
 END 

 --SALES ANALYSIS BY STORE LOCATION

SELECT store_location, 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K') AS TotalSales
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 -- may
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC

-- DAILY SALES ANALYSIS WITH AVERAGE LINE
SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000 ,1), 'K') AS AVG_SALES
FROM 
(
SELECT 
	SUM(unit_price * transaction_qty) as total_sales
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 -- may 
GROUP BY transaction_date
) AS internal_query

--DAILY SALES FOR THE SELECTED MONTH
SELECT DAY(transaction_date) AS day_of_month,
		CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K')AS total_sales
	FROM coffee_sales
	WHERE  MONTH(transaction_date) = 5 -- May
	GROUP BY DAY(transaction_date)
	ORDER BY DAY(transaction_date)

SELECT 
 day_of_month, 
 CASE
		WHEN total_sales > Avg_Sales THEN 'Above Average'
		WHEN total_sales < Avg_Sales THEN 'Below Average'
ELSE 'Average'
END AS Sales_Status, 
total_sales
		
FROM(
	SELECT DAY(transaction_date) AS day_of_month,
	SUM(unit_price * transaction_qty) as total_sales,
	AVG(SUM(unit_price * transaction_qty)) OVER () AS Avg_Sales
	FROM coffee_sales
	WHERE MONTH(transaction_date) = 5
	GROUP BY DAY(transaction_date)
	)AS sales_data
ORDER BY day_of_month

--SALES BY PRODUCT CATEGORY
SELECT product_category, 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K') AS TotalSales
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 -- may
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC

--TOP 10 PRODUCT BY Sales
SELECT TOP 10
	product_type, 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K') AS TotalSales
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 -- may
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC

--SALES ANALYSIS BY DAYS AND HOURS
SELECT 
	
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K') AS TotalSales,
	SUM(transaction_qty) AS total_qty,
	COUNT(*) AS Total_orders
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 -- may
AND DATEPART(WEEKDAY, transaction_date) = 2 --- monday
AND DATEPART(HOUR,transaction_time) = 8 ---- 8th Hour


SELECT 
	DATEPART(HOUR, transaction_time) AS TIME_STAMP,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K') AS TotalSales
FROM coffee_sales
WHERE MONTH(transaction_date) = 5 -- may
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY  DATEPART(HOUR, transaction_time) 

--
--TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
	CASE 
		WHEN DATEPART(WEEKDAY, transaction_date) = 2 THEN 'Monday'
		 WHEN DATEPART(WEEKDAY, transaction_date) = 3 THEN 'Tuesday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 4 THEN 'Wednesday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 5 THEN 'Thursday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 6 THEN 'Friday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 7 THEN 'Saturday' 
ELSE 'Sunday'
END AS Day_of_week,
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 ,1), 'K') AS TotalSale
FROM coffee_sales
WHERE  MONTH(transaction_date) = 5
GROUP BY 
CASE 
		WHEN DATEPART(WEEKDAY, transaction_date) = 2 THEN 'Monday'
		 WHEN DATEPART(WEEKDAY, transaction_date) = 3 THEN 'Tuesday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 4 THEN 'Wednesday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 5 THEN 'Thursday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 6 THEN 'Friday'
		  WHEN DATEPART(WEEKDAY, transaction_date) = 7 THEN 'Saturday' 
ELSE 'Sunday'
END;