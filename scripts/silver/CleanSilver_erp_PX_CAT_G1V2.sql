INSERT INTO Silver.erp_PX_CAT_G1V2(id, cat, subcat, maintenance)

SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_PX_CAT_G1V2

---Testing data

SELECT DISTINCT
subcat
FROM bronze.erp_PX_CAT_G1V2
WHERE subcat != TRIM(subcat)
	
SELECT DISTINCT
subcat
FROM bronze.erp_PX_CAT_G1V2
WHERE subcat IS NULL