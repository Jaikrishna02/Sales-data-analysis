IF OBJECT_ID ('Silver.crm_cust_info', 'U') IS NOT NULL
DROP TABLE Silver.crm_cust_info;                                 -- Checking whether the table already exists. If it does, the old table will be dropped and the empty one will be there

CREATE TABLE Silver.crm_cust_info (

cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),                                         -- We are creating a table for Silver layer and initialising all headers in the cust_info csv file
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE,
dwh_create_data DATETIME2 DEFAULT GETDATE()                     ---To get the meta data of the time of table creation

);

IF OBJECT_ID ('Silver.crm_prod_info', 'U') IS NOT NULL
DROP TABLE Silver.crm_prod_info;

CREATE TABLE Silver.crm_prod_info (

prd_id INT,
cat_id NVARCHAR(50),
prd_key NVARCHAR(50),                   
prd_nm NVARCHAR(50),                                                -- We are creating a table for Silver layer and initialising all headers in the prod_info csv file
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_data DATETIME2 DEFAULT GETDATE() 

);

IF OBJECT_ID ('Silver.crm_sales_details', 'U') IS NOT NULL
DROP TABLE Silver.crm_sales_details;

CREATE TABLE Silver.crm_sales_details (

sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,                                                    -- We are creating a table for Silver layer and initialising all headers in the csv_details csv file
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_data DATETIME2 DEFAULT GETDATE() 

);

IF OBJECT_ID ('Silver.erp_CUST_AZ12', 'U') IS NOT NULL
DROP TABLE Silver.erp_CUST_AZ12;

CREATE TABLE Silver.erp_CUST_AZ12 (
CID NVARCHAR(50), 
BDATE DATE,                                                           -- We are creating a table for Silver layer and initialising all headers in the CUST_AZ12 csv file
GEN NVARCHAR(20),
dwh_create_data DATETIME2 DEFAULT GETDATE() 
);

IF OBJECT_ID ('Silver.erp_LOC_A101', 'U') IS NOT NULL
DROP TABLE Silver.erp_LOC_A101;

CREATE TABLE Silver.erp_LOC_A101 (
CID NVARCHAR(50),                                                      -- We are creating a table for Silver layer and initialising all headers in the LOC_A101 csv file
CNTRY NVARCHAR(50),
dwh_create_data DATETIME2 DEFAULT GETDATE() 
);

IF OBJECT_ID ('Silver.erp_PX_CAT_G1V2', 'U') IS NOT NULL
DROP TABLE Silver.erp_PX_CAT_G1V2;

CREATE TABLE Silver.erp_PX_CAT_G1V2 (
ID NVARCHAR(50),
CAT NVARCHAR(50),                                                       -- We are creating a table for Silver layer and initialising all headers in the PX_CAT_G1V2 csv file
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50),
dwh_create_data DATETIME2 DEFAULT GETDATE() 
);