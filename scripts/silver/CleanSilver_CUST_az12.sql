TRUNCATE TABLE Silver.erp_CUST_AZ12;

INSERT INTO Silver.erp_CUST_AZ12(cid, bdate, gen)

SELECT 

CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END cid,

CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END bdate,

CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'NA'
END AS gen
FROM bronze.erp_CUST_AZ12


--Data Cleaning

SELECT DISTINCT
bdate
FROM bronze.erp_CUST_AZ12
WHERE bdate < '1926-01-01' OR bdate > GETDATE()

SELECT DISTINCT
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'NA'
END AS gen
FROM bronze.erp_CUST_AZ12
