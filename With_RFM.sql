-- Best Customer by using RFM Analysis
-- RFM(Recency-Frequency-Monetary) an indexing technique used to segment customers based on their past purchase history
-- Recency - how long their last purchase was
-- Frequent - how often they purchase 
-- Monetary - how much spent

-- Best Customer from sales data using with clause
DROP TABLE IF EXISTS #RFM
;WITH RFM AS
(
	SELECT CUSTOMERNAME, 
		sum(sales) AS MonetaryValue, 
		avg(sales) AS AverageMonetaryValue, 
		count(ORDERNUMBER) AS Frequencey, 
		max(ORDERDATE) AS LastOrderDate,
		(SELECT max(ORDERDATE) FROM sales_data) AS MaxOrderDate,
		DATEDIFF(DD, max(ORDERDATE), (SELECT max(ORDERDATE) FROM sales_data)) AS Recency -- (last-max) how long the purchase is been i.e difference of the last and max date
		-- less recency indicated recent orders
		-- NTILE() function helps to divide the records into equal or buckets assigning a number to each bucket from 1 
	FROM sales_data
	GROUP BY CUSTOMERNAME
),
final_RFM AS
(
	SELECT *,
		NTILE(4) OVER(ORDER BY Recency DESC) AS RFM_Recency,
		NTILE(4) OVER(ORDER BY Frequencey) AS RFM_Frequencey,
		NTILE(4) OVER(ORDER BY AverageMonetaryValue) AS RFM_Monetary
	FROM RFM
)
SELECT *,
	RFM_Recency + RFM_Frequencey + RFM_Monetary AS RFM_total,
	CAST(RFM_Recency AS varchar) + CAST(RFM_Frequencey AS varchar) + CAST(RFM_Monetary AS varchar) RFM_Total_String
	INTO #RFM
FROM final_RFM

SELECT * FROM #RFM