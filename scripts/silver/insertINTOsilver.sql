TRUNCATE TABLE Silver.crm_cust_info;

INSERT INTO Silver.crm_cust_info (cst_id, cst_key,cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,       -- Trim removes the space before and after the word
TRIM(cst_lastname) AS cst_lastname,

CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'            -- To change the S into Single and M into married
	 ELSE 'NA'
END cst_marital_status,

CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'                               --To change F as Female and M as Male
	 ELSE 'NA'
END cst_gndr,
cst_create_date

FROM
(
	SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last         --  To find the duplicates in primary key (cst_id)
	FROM bronze.crm_cust_info                                                                  
	WHERE cst_id IS NOT NULL
) AS t WHERE flag_last = 1




-- To test

--To find duplicate primary key
SELECT cst_id, COUNT(*) FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL

SELECT cst_id, COUNT(*) FROM Silver.crm_cust_info GROUP BY cst_id HAVING COUNT(*)>1             ----to find the duplicates in cus_id (cus_info is the primary key)

--Check for unwanted space

SELECT cst_firstname
FROM Silver.crm_cust_info
WHERE cst_firstname!= TRIM(cst_firstname)

SELECT cst_lastname
FROM Silver.crm_cust_info
WHERE cst_lastname!= TRIM(cst_lastname)

--Data Standardisation and consistency

SELECT DISTINCT cst_gndr
FROM Silver.crm_cust_info

--Check for null or negative numbers

SELECT prd_cost FROM bronze.crm_prod_info WHERE prd_cost < 0 OR prd_cost IS NULL

SELECT * FROM Silver.crm_cust_info

