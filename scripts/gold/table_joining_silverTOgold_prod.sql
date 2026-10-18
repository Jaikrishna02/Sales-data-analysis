CREATE VIEW Gold.dim_products AS 

SELECT 
	ROW_NUMBER() OVER (ORDER BY prd_key, prd_start_dt) AS product_key,
		prodinfo.prd_id AS product_id,
		prodinfo.prd_key AS product_number,
		prodinfo.cat_id AS category_id,
		prodinfo.prd_nm AS product_name,
		prodcat.CAT AS category,
		prodcat.SUBCAT AS subcategory,
		prodinfo.prd_line AS product_line,
		prodinfo.prd_cost AS produc_cost,                               
		prodcat.MAINTENANCE AS maintenance,
		prodinfo.prd_start_dt AS product_start_date,
		prodinfo.prd_end_dt AS product_end_date
	
FROM Silver.crm_prod_info prodinfo

LEFT JOIN Silver.erp_PX_CAT_G1V2 prodcat
ON prodinfo.cat_id = prodcat.id

WHERE prd_end_dt IS NULL     --to filter current products

