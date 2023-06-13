-- Best Customer by using RFM Analysis
-- RFM(Recency-Frequency-Monetary) an indexing technique used to segment customers based on their past purchase history
-- Recency - how long their last purchase was
-- Frequent - how often they purchase 
-- Monetary - how much spent

-- Best Customer from sales data by creating view for each individual table
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