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