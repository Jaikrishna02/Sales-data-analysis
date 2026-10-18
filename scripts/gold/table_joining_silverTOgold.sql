

CREATE VIEW gold.dim_customer AS               --Creating view for gold

--Joining the tables using left join

SELECT  
		ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,   --creating surrogate key
 		custinfo.cst_id AS customer_id,
		custinfo.cst_key AS customer_no,
		custinfo.cst_firstname AS first_name,
		custinfo.cst_lastname AS last_name,
		custloc.cntry AS country,
		custinfo.cst_marital_status AS marital_status,

		CASE WHEN custinfo.cst_gndr != 'NA' THEN custinfo.cst_gndr 
			ELSE COALESCE (ca.gen, 'NA')
		END AS gender,

		ca.bdate AS birthday,
		custinfo.cst_create_date AS create_date                        --JOINING
		
	FROM Silver.crm_cust_info custinfo

	LEFT JOIN Silver.erp_CUST_AZ12 ca
	ON custinfo.cst_key = ca.cid

	LEFT JOIN Silver.erp_LOC_A101 custloc
	ON custinfo.cst_key = custloc.cid

	------------------------------------------------------------------------------------------

SELECT cst_id, COUNT(*)FROM
() t GROUP BY cst_id                      --Checking for duplicates. Inside the (), the joined table should be there
HAVING COUNT(*) > 1

-----------------------------------------------------------------------------------------------------------------

--Data Integration for Gender

SELECT DISTINCT 
	custinfo.cst_gndr,
	ca.gen,

	CASE WHEN custinfo.cst_gndr != 'NA' THEN custinfo.cst_gndr  --cst_gndr is from the CRM which is prioritized over ERP. The same code is pasted in the above query
		ELSE COALESCE (ca.gen, 'NA')
	END AS new_gen

FROM Silver.crm_cust_info custinfo
LEFT JOIN Silver.erp_CUST_AZ12 ca
ON custinfo.cst_key = ca.cid

LEFT JOIN Silver.erp_LOC_A101 custloc
ON custinfo.cst_key = custloc.cid

ORDER BY 1,2

SELECT DISTINCT gender FROM gold.dim_customer  ---To check the data

