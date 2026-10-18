CREATE VIEW Gold.fact_sales AS

SELECT 
	sd.sls_ord_num AS order_number,
	dpr.product_key,
	dcu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS sales_quantity,
	sd.sls_price AS sales_price 

FROM Silver.crm_sales_details sd

LEFT JOIN Gold.dim_products dpr
ON sd.sls_prd_key = dpr.product_number
LEFT JOIN Gold.dim_customer dcu
ON sd.sls_cust_id = dcu.customer_id

---------------------------------------------------------

--fOREIGN KEY INTEGRITY CHECK

SELECT *
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customer c
ON c.customer_key = f.customer_key

LEFT JOIN Gold.dim_products p
ON p.product_key = f.product_key

WHERE c.customer_key IS NULL




