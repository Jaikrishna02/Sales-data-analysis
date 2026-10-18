# Data Warehouse Project

Building a Data Warehouse with SQL to analyze sales data and retrieve business insights from them.

This project consolidates sales data from two source systems (**CRM** and **ERP**) into a SQL Server data warehouse, following the **Medallion Architecture** (Bronze → Silver → Gold). The end result is a clean **star schema** ready for analytics and reporting.

![Data Architecture](docs/data_architecture.png)

---

## 🏗️ Architecture

| Layer | Purpose | Object type | Load method |
|---|---|---|---|
| **Bronze** | Raw data, stored as-is from the source CSV files | Tables | Truncate & `BULK INSERT` |
| **Silver** | Cleaned, standardized and enriched data | Tables | Truncate & insert from Bronze |
| **Gold** | Business-ready star schema for reporting | Views | Joins over Silver |

---

## 📦 Data Sources

| Source | File | Contents | Rows (approx.) |
|---|---|---|---|
| CRM | `cust_info.csv` | Customer details | 18,000 |
| CRM | `prd_info.csv` | Product details and history | 400 |
| CRM | `sales_details.csv` | Sales transactions | 60,000 |
| ERP | `CUST_AZ12.csv` | Customer birthdate and gender | 18,000 |
| ERP | `LOC_A101.csv` | Customer country | 18,000 |
| ERP | `PX_CAT_G1V2.csv` | Product categories | 40 |

---

## 🔄 ETL Pipeline

### Bronze: Load raw data
- Stored procedure `bronze.load_bronze` truncates each table and loads the CSV files with `BULK INSERT`.
- `TRY/CATCH` error handling, with load duration logged per table and for the full batch.

### Silver: Clean and standardize
- **Deduplication:** keeps the latest record per customer using `ROW_NUMBER()`.
- **Trimming:** removes unwanted spaces from names.
- **Normalization:** maps codes to readable values (`M`/`F` → `Male`/`Female`, `S`/`M` → `Single`/`Married`, product line codes → `Mountain`, `Road`, `Tour`, `Other Sales`, country codes → full names).
- **Date handling:** converts integer dates (`YYYYMMDD`) to `DATE` and sets invalid ones to `NULL`; future birthdates are set to `NULL`.
- **Business rules:** recalculates sales as `quantity × price` when missing or inconsistent, and derives missing or negative prices.
- **Key alignment:** splits the product key into category ID and product key, and strips prefixes and dashes from ERP customer IDs so they match CRM.
- **Enrichment:** calculates each product's end date with `LEAD()` (one day before the next start date).
- Wrapped in the stored procedure `Silver.load_Silver`.

### Gold: Star schema
| View | Type | Description |
|---|---|---|
| `gold.dim_customer` | Dimension | Customers from CRM, enriched with ERP country, birthdate and gender. CRM is the main source for gender, with ERP filling the gaps. |
| `gold.dim_products` | Dimension | Current products only, with category, subcategory and maintenance info. |
| `gold.fact_sales` | Fact | Sales transactions linked to customers and products through surrogate keys. |

![Data Model](docs/data_model.png)

---

## 📂 Repository Structure

```
├── datasets/
│   ├── source_crm/            # CRM source files (customers, products, sales)
│   └── source_erp/            # ERP source files (customer info, location, categories)
│
├── docs/                      # Architecture, data flow and data model diagrams, data catalog, naming conventions
│
├── scripts/
│   ├── bronze/                # Schema creation, Bronze tables, load procedure
│   ├── silver/                # Silver tables, cleaning scripts, load procedure
│   ├── gold/                  # Star schema views
│   └── reference/             # Course reference scripts and quality checks
│
├── LICENSE
└── README.md
```

---

## 🚀 How to Run

**Requirements:** SQL Server (Express is enough) and SQL Server Management Studio (SSMS).

1. **Create the database and schemas**
   ```sql
   CREATE DATABASE DataWarehouse;
   ```
   Then run `scripts/bronze/db_schema_creation.sql`.

2. **Create the Bronze tables:** run `scripts/bronze/ddl_bronze.sql`.

3. **Load the Bronze layer**
   - In `scripts/bronze/main_loading_data.sql`, change the file paths to where you saved the `datasets` folder.
   - Run it to create the procedure, then run `scripts/bronze/calling_stored_procedure.sql`:
   ```sql
   EXEC bronze.load_bronze;
   ```

4. **Create the Silver tables:** run `scripts/silver/silver_table_creation.sql`, then the `CREATE TABLE` part of `scripts/silver/CleanSilver_sales_details.sql` (it redefines the sales date columns as `DATE`).

5. **Load the Silver layer:** run `scripts/silver/silver_stored_procedure.sql`, then:
   ```sql
   EXEC Silver.load_Silver;
   ```

6. **Create the Gold views:** run the `CREATE VIEW` part of each script in `scripts/gold/`, in this order:
   1. `table_joining_silverTOgold.sql` (`dim_customer`)
   2. `table_joining_silverTOgold_prod.sql` (`dim_products`)
   3. `table_joining_silverTOgold_factsales.sql` (`fact_sales`)

7. **Query the results**
   ```sql
   SELECT * FROM gold.fact_sales;
   ```

> The cleaning and Gold scripts also contain the data quality checks I used while building each step (duplicates, unwanted spaces, invalid dates, foreign key integrity). Run them one query at a time.

---

## 🛠️ Skills Used

SQL Server · T-SQL · ETL · Data Warehousing · Medallion Architecture · Dimensional Modeling (Star Schema) · Data Cleaning · Window Functions · Stored Procedures · Git

---

## 🙏 Acknowledgements

This project was built by following the [SQL Data Warehouse Project](https://github.com/DataWithBaraa/sql-data-warehouse-project) course by **Data With Baraa**. The datasets, diagrams in `docs/`, and scripts in `scripts/reference/` come from the course. The scripts in `bronze/`, `silver/` and `gold/` are my own implementation.

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE).
