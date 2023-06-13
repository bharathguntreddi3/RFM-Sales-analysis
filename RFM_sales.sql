-- RFM(Recency Frequent Monetary)
-- Recency - Last order date
-- Requent - count of total orders
-- Monetary - total spend

-- show complete dataset
use bharath;
SELECT * FROM dbo.sales_data

-- show the distinct values of some common dimensions
SELECT DISTINCT status FROM sales_data -- 6 
SELECT DISTINCT year_id FROM sales_data -- 3
SELECT DISTINCT PRODUCTLINE FROM sales_data --7
SELECT DISTINCT MSRP FROM sales_data -- 80 huge plotting
SELECT DISTINCT COUNTRY FROM sales_data -- 19
SELECT DISTINCT TERRITORY FROM sales_data -- 4
SELECT DISTINCT DEALSIZE FROM sales_data -- 3

-- sales of all the products 
-- group the sales by products and order the data by revenue as desc
SELECT PRODUCTLINE, sum(sales) AS REVENUE
FROM sales_data
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

-- revenue with the status of product
SELECT STATUS, sum(sales) AS REVENUE
FROM sales_data
GROUP BY STATUS
ORDER BY 2 DESC;

-- year with maximum sales of the product
SELECT YEAR_ID, sum(sales) AS REVENUE
FROM sales_data
GROUP BY YEAR_ID
ORDER BY 2 DESC;

-- 2005 - least
-- 2003 - modest
-- 2004 - highest

SELECT DISTINCT MONTH_ID FROM sales_data
WHERE YEAR_ID = 2005; -- sales for only 5 months

SELECT DISTINCT MONTH_ID FROM sales_data
WHERE YEAR_ID = 2004
ORDER BY MONTH_ID ASC;  -- sales for all months made it the highest sales

-- revenue based on the dealsize
SELECT DEALSIZE, sum(sales) AS REVENUE
FROM sales_data
GROUP BY DEALSIZE
ORDER BY 2 DESC; -- with medium dealsize as highest

-- maximum revenue earned in each month for the 3 years
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_COUNTS
FROM sales_data
GROUP BY MONTH_ID
ORDER BY 2 DESC; -- November best month of sales

-- for 2004
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_COUNTS
FROM sales_data
WHERE YEAR_ID = 2004
GROUP BY MONTH_ID
ORDER BY 2 DESC;  -- November best month of sales

-- for 2005
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_COUNTS
FROM sales_data
WHERE YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 2 DESC;  -- May is the best month of sales

-- for 2003
SELECT MONTH_ID, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_COUNTS
FROM sales_data
WHERE YEAR_ID = 2003
GROUP BY MONTH_ID
ORDER BY 2 DESC;   -- November is the best month of sales

-- November is the best overall best month of sales with highest orders
-- checking the products that are sold during this highest sales month
SELECT MONTH_ID, PRODUCTLINE, sum(sales) AS REVENUE, count(ORDERNUMBER) AS ORDER_COUNTS
FROM sales_data
WHERE MONTH_ID = 11    -- add YEAR_ID in where clause to see products for each year
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC;

-- Best Customer by using RFM Analysis
-- RFM(Recency-Frequency-Monetary) an indexing technique used to segment customers based on their past purchase history
-- Recency - how long their last purchase was
-- Frequent - how often they purchase 
-- Monetary - how much spent

-- Best Customer from sales data
SELECT max(ORDERDATE) FROM sales_data  -- max order date
--DROP TABLE IF EXISTS #RFM
--;WITH RFM AS
--(
--	SELECT CUSTOMERNAME, 
--		sum(sales) AS MonetaryValue, 
--		avg(sales) AS AverageMonetaryValue, 
--		count(ORDERNUMBER) AS Frequencey, 
--		max(ORDERDATE) AS LastOrderDate,
--		(SELECT max(ORDERDATE) FROM sales_data) AS MaxOrderDate,
--		DATEDIFF(DD, max(ORDERDATE), (SELECT max(ORDERDATE) FROM sales_data)) AS Recency -- (last-max) how long the purchase is been i.e difference of the last and max date
--		-- less recency indicated recent orders
--		-- NTILE() function helps to divide the records into equal or buckets assigning a number to each bucket from 1 
--	FROM sales_data
--	GROUP BY CUSTOMERNAME
--),
--final_RFM AS
--(
--	SELECT *,
--		NTILE(4) OVER(ORDER BY Recency DESC) AS RFM_Recency,
--		NTILE(4) OVER(ORDER BY Frequencey) AS RFM_Frequencey,
--		NTILE(4) OVER(ORDER BY AverageMonetaryValue) AS RFM_Monetary
--	FROM RFM
--)
--SELECT *,
--	RFM_Recency + RFM_Frequencey + RFM_Monetary AS RFM_total,
--	CAST(RFM_Recency AS varchar) + CAST(RFM_Frequencey AS varchar) + CAST(RFM_Monetary AS varchar) RFM_Total_String
--	INTO #RFM
--FROM final_RFM

--SELECT * FROM #RFM



CREATE VIEW RFM_C 
AS
	SELECT CUSTOMERNAME, 
			sum(sales) AS MonetaryValue, 
			avg(sales) AS AverageMonetaryValue, 
			count(ORDERNUMBER) AS Frequency, 
			max(ORDERDATE) AS LastOrderDate,
			(SELECT max(ORDERDATE) FROM sales_data) AS MaxOrderDate,
			DATEDIFF(DD, max(ORDERDATE), (SELECT max(ORDERDATE) FROM sales_data)) AS Recency -- (last-max) how long the purchase is been i.e difference of the last and max date
			-- less recency indicated recent orders
			-- NTILE() function helps to divide the records into equal or buckets assigning a number to each bucket from 1 
	FROM sales_data
	GROUP BY CUSTOMERNAME
-- DROP VIEW RFM_C
-- SELECT * FROM RFM_C -- RFM-C

CREATE VIEW total_RFM 
AS
	SELECT *,
		NTILE(4) OVER(ORDER BY Recency DESC) AS RFM_Recency,
		NTILE(4) OVER(ORDER BY Frequency) AS RFM_Frequency,
		NTILE(4) OVER(ORDER BY MonetaryValue) AS RFM_Monetary
	FROM RFM_C
-- DROP VIEW total_RFM
-- SELECT * FROM total_RFM -- total_RFM

CREATE VIEW RFM_S
AS
	SELECT *,
		RFM_Recency + RFM_Frequency + RFM_Monetary AS RFM_total,
		CAST(RFM_Recency AS varchar) + CAST(RFM_Frequency AS varchar) + CAST(RFM_Monetary AS varchar) RFM_Total_String
	FROM total_RFM
-- DROP VIEW RFM_S
SELECT * FROM RFM_S -- RFM_S

SELECT CUSTOMERNAME, RFM_Recency, RFM_Frequency, RFM_Monetary,
	CASE
		WHEN RFM_total BETWEEN 3 AND 5 THEN 'Lost Customers' -- didn't buy anything
		WHEN RFM_total BETWEEN 6 AND 7 THEN 'Slipping customers' -- big buyers havent purchased lately
		WHEN RFM_total = 8 THEN 'New Customers'
		WHEN RFM_total = 9 OR RFM_total > 9 THEN 'Active' -- often buyers
	END RFM_Segment
FROM RFM_S



--	Most often sold products
SELECT DISTINCT ORDERNUMBER, STUFF(
	(SELECT ',' + PRODUCTCODE
	FROM sales_data  AS p
	WHERE ORDERNUMBER IN
		(
		SELECT ORDERNUMBER 
		FROM
			(
				SELECT ORDERNUMBER, COUNT(*) AS quantity
				FROM sales_data
				WHERE STATUS = 'shipped'
				GROUP BY ORDERNUMBER
			) AS b
		WHERE quantity = 9
	)
	AND p.ORDERNUMBER = s.ORDERNUMBER
	FOR XML PATH('')), 1, 1, '') AS ProductCodes
FROM sales_data AS s
ORDER BY ProductCodes DESC
