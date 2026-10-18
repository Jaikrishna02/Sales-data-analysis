
---Creating stored procedure for silver layer

CREATE OR ALTER PROCEDURE Silver.load_Silver AS
BEGIN 

	DECLARE @start_time DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME  
	
	BEGIN TRY

		SET @start_time = GETDATE(); -----To record start time
		SET @batch_start_time = GETDATE();

		-- All the table operations of silver layer are here as a copy

		----------------------crm_cust_info-------------------------------

		PRINT 'Silver.crm_cust_info';

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

			SET @end_time = GETDATE()
			PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'


		--------------------------------crm_prod_info-------------------------------

		SET @start_time = GETDATE(); 

		PRINT 'Silver.crm_prod_info';

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

			SET @end_time = GETDATE()
			PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'


		--------------------------------crm_sales_details-------------------------------

		SET @start_time = GETDATE(); 

		PRINT 'Silver.crm_sales_details';

		TRUNCATE TABLE Silver.crm_sales_details;
		INSERT INTO Silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,                               --Inserting the cleaned table from bronze to silver layer
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)

		SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,

		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
		END AS sls_order_dt,

		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)         
		END AS sls_ship_dt,                                                                           --Cleaning data from bronze table inserted into silver table


		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
		END AS sls_due_dt,

		CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales!= sls_quantity * ABS(sls_price)                 
				THEN sls_quantity * ABS(sls_price)                                                             
			ELSE sls_sales
		END sls_sales,

		sls_quantity,

		CASE WHEN sls_price IS NULL OR sls_price <=0
				THEN sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price

		FROM bronze.crm_sales_details

			SET @end_time = GETDATE()
			PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'


		--------------------------------erp_CUST_AZ12-------------------------------

		SET @start_time = GETDATE(); 

		PRINT 'Silver.erp_CUST_AZ12';

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

			SET @end_time = GETDATE()
			PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'


		--------------------------------erp_LOC_A101-------------------------------

		SET @start_time = GETDATE(); 

		PRINT 'Silver.erp_LOC_A101';

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

			SET @end_time = GETDATE()
			PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'


		--------------------------------erp_PX_CAT_G1V2-------------------------------

		SET @start_time = GETDATE(); 

		PRINT 'Silver.erp_PX_CAT_G1V2';

		INSERT INTO Silver.erp_PX_CAT_G1V2(id, cat, subcat, maintenance)

		SELECT
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_PX_CAT_G1V2

			SET @end_time = GETDATE()
			PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'

			SET @batch_end_time = GETDATE();
			PRINT 'lOAD DURATION OF BRONZE LAYER IS ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'SECONDS'

	END TRY
	BEGIN CATCH
	PRINT '<<<<<<<<<<<<<<<<ERROR!!!!!!>>>>>>>>>>>>>'
			PRINT ('ERROR MESSAGE' + error_message());
			PRINT ('ERROR NUMBER' + CAST(error_number() AS NVARCHAR));
		END CATCH
END



