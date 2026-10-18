TRUNCATE TABLE Silver.crm_prod_info;

INSERT INTO Silver.crm_prod_info (
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)

SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,                                        --CREATE A COLUMN FOR CATEGORYID
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,    --Replaces null with 0

CASE UPPER(TRIM(prd_line)) 
	WHEN 'M' THEN 'Mountain'
	WHEN 'R' THEN 'Road'                               --Data Normalisation
	WHEN 'S' THEN 'Other Sales'
	WHEN 'T' THEN 'Tour'
ELSE 'NA'
END AS prd_line, 

prd_start_dt,
DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt                  --Data Enrichment
FROM bronze.crm_prod_info 


----Testing

SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,



FROM bronze.crm_prod_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')




WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT distinct id FROM bronze.erp_PX_CAT_G1V2) 

SELECT distinct id FROM bronze.erp_PX_CAT_G1V2