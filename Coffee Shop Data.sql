WITH sales
AS (
SELECT
	CAST(created_at AS DATE) AS created_at,
	orders.quantity,
	cust_name AS Customer_Name,
	COALESCE(in_or_out, 'NA') AS in_or_out,
	item_name,
	item_cat AS item_category,
	item_size,
	CONCAT('$',ROUND(item_price,2)) AS cost,
	CONCAT('$',(quantity*CAST(LTRIM(item_price, '$') AS FLOAT))) AS Purchase_Total
FROM orders
INNER JOIN items
		ON orders.item_id = items.item_id
),

workers
AS(
SELECT
	CONCAT(first_name, ' ', last_name) AS employee,
	position,
	sal_per_hour AS rate,
	day_of_week,
	DATEDIFF(HOUR, start_time, end_time) AS shift_total,
	date
FROM staff
LEFT JOIN rota
		ON staff.staff_id = rota.staff_id
LEFT JOIN shift
		ON rota.shift_id = shift.shift_id
)

SELECT 
	created_at,
	quantity,
	Customer_Name,
	in_or_out,
	item_name,
	item_category,
	item_size,
	cost,
	Purchase_Total,
	CONCAT('$', SUM(CAST(LTRIM(Purchase_Total,'$') AS FLOAT)) OVER (PARTITION BY item_name ORDER BY created_at)) AS Cumulative_Sales,
	employee,
	position,
	(rate*shift_total) AS Daily_Pay,
	day_of_week
FROM sales
INNER JOIN workers
		ON created_at = date
ORDER BY created_at ASC
