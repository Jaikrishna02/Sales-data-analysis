TRUNCATE TABLE Silver.erp_LOC_A101;

INSERT INTO Silver.erp_LOC_A101(cid, cntry)               --Inserting the clean data in silver table

SELECT 
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) = 'United States' OR TRIM(cntry) = 'US' OR TRIM(cntry) = 'USA' THEN 'America'           ---Cleaning the data
	 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'NA'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_LOC_A101


--TESTING THE DATA

SELECT DISTINCT 
cntry
FROM bronze.erp_LOC_A101

SELECT cst_key FROM Silver.crm_cust_info