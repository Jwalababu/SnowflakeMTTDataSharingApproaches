-- =====================================================================
-- Snowflake Secure Data Sharing with Row Access Policies
-- This script demonstrates secure views, materialized views, dynamic tables,
-- row access policies, and data sharing capabilities
-- DISCLAIMER: THIS CODE IS PROVIDED ONLY AS A SAMPLE AND IS NOT PART OF SNADARD SNOWFALKE SERVICE OFFERING.
-- =====================================================================
-- Set context
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
-- =====================================================================
-- STEP 1. DATABASE AND SCHEMA SETUP
-- =====================================================================
-- Create database for secure data sharing
CREATE DATABASE IF NOT EXISTS SECURE_DATA_SHARING;
USE DATABASE SECURE_DATA_SHARING;
-- Create schemas
CREATE SCHEMA IF NOT EXISTS CORE_DATA;
CREATE SCHEMA IF NOT EXISTS SECURE_VIEWS;
CREATE SCHEMA IF NOT EXISTS SECURE_MATERIALIZED_VIEWS;
CREATE SCHEMA IF NOT EXISTS DYNAMIC_TABLES;
CREATE SCHEMA IF NOT EXISTS SHARED_DATA;
-- =====================================================================
-- STEP 2. CUSTOMER ACCOUNT MAPPING TABLE
-- =====================================================================
USE SCHEMA CORE_DATA;
-- Customer account mapping table to control data access
CREATE
OR REPLACE TABLE CUSTOMER_ACCOUNT_MAPPING (
    CUSTOMER_KEY VARCHAR(50) PRIMARY KEY,
    CUSTOMER_NAME VARCHAR(100) NOT NULL,
    SNOWFLAKE_ACCOUNT_IDENTIFIER VARCHAR(100) NOT NULL,
    ACCOUNT_LOCATOR VARCHAR(50),
    REGION VARCHAR(50),
    IS_ACTIVE BOOLEAN DEFAULT TRUE,
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
-- Insert sample customer account mappings
-- Change values of account identifier and account Locator values for your target accounts
INSERT INTO
    CUSTOMER_ACCOUNT_MAPPING
VALUES
    (
        'CUST_001',
        'Acme Corporation',
        'ENUATA.AWS1',
        'GDS57240',
        'us-east-1',
        TRUE,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    ),
    (
        'CUST_002',
        'Global Tech Solutions',
        'DATAGKS.AWS2',
        'UFGC57412',
        'europe-west1',
        TRUE,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    ),
    (
        'CUST_003',
        'Innovative Systems Inc',
        'INNOSYS.US-WEST-2',
        'EF11111',
        'us-west-2',
        TRUE,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    ),
    (
        'CUST_004',
        'Enterprise Data Co',
        'ENTDATA.AUSTRALIA-EAST',
        'GH22222',
        'australia-east',
        TRUE,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    ),
    (
        'CUST_005',
        'Cloud Solutions Ltd',
        'CLOUDSOL.CANADA-CENTRAL',
        'IJ33333',
        'canada-central',
        TRUE,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    );
    -- =====================================================================
    -- STEP 3. SAMPLE BASE TABLES
    -- =====================================================================
    -- Customer data table
    CREATE
    OR REPLACE TABLE CUSTOMERS (
        CUSTOMER_ID VARCHAR(50) PRIMARY KEY,
        CUSTOMER_KEY VARCHAR(50) NOT NULL,
        -- Maps to CUSTOMER_ACCOUNT_MAPPING
        CUSTOMER_NAME VARCHAR(100) NOT NULL,
        EMAIL VARCHAR(200),
        PHONE VARCHAR(50),
        ADDRESS VARCHAR(500),
        CITY VARCHAR(100),
        STATE VARCHAR(50),
        COUNTRY VARCHAR(50),
        POSTAL_CODE VARCHAR(20),
        REGISTRATION_DATE DATE,
        STATUS VARCHAR(20) DEFAULT 'ACTIVE',
        CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
    );
    -- Sales transactions table
    CREATE
    OR REPLACE TABLE SALES_TRANSACTIONS (
        TRANSACTION_ID VARCHAR(50) PRIMARY KEY,
        CUSTOMER_KEY VARCHAR(50) NOT NULL,
        -- Maps to CUSTOMER_ACCOUNT_MAPPING
        CUSTOMER_ID VARCHAR(50) NOT NULL,
        PRODUCT_ID VARCHAR(50),
        PRODUCT_NAME VARCHAR(200),
        CATEGORY VARCHAR(100),
        QUANTITY INTEGER,
        UNIT_PRICE DECIMAL(10, 2),
        TOTAL_AMOUNT DECIMAL(12, 2),
        DISCOUNT_AMOUNT DECIMAL(10, 2) DEFAULT 0,
        TAX_AMOUNT DECIMAL(10, 2),
        TRANSACTION_DATE DATE,
        TRANSACTION_TIMESTAMP TIMESTAMP_NTZ,
        SALES_REP VARCHAR(100),
        REGION VARCHAR(50),
        CREATED_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
    );
    -- Product information table
    CREATE
    OR REPLACE TABLE PRODUCTS (
        PRODUCT_ID VARCHAR(50) PRIMARY KEY,
        CUSTOMER_KEY VARCHAR(50) NOT NULL,
        -- Maps to CUSTOMER_ACCOUNT_MAPPING
        PRODUCT_NAME VARCHAR(200) NOT NULL,
        CATEGORY VARCHAR(100),
        SUBCATEGORY VARCHAR(100),
        BRAND VARCHAR(100),
        DESCRIPTION TEXT,
        UNIT_PRICE DECIMAL(10, 2),
        COST DECIMAL(10, 2),
        MARGIN_PCT DECIMAL(5, 2),
        IS_ACTIVE BOOLEAN DEFAULT TRUE,
        CREATED_DATE DATE,
        UPDATED_DATE DATE
    );
    -- Insert sample data
INSERT INTO
    CUSTOMERS
VALUES
    (
        'C001',
        'CUST_001',
        'John Smith',
        'john.smith@acme.com',
        '555-0101',
        '123 Main St',
        'New York',
        'NY',
        'USA',
        '10001',
        '2024-01-15',
        'ACTIVE',
        CURRENT_TIMESTAMP()
    ),
    (
        'C002',
        'CUST_001',
        'Jane Doe',
        'jane.doe@acme.com',
        '555-0102',
        '456 Oak Ave',
        'New York',
        'NY',
        'USA',
        '10002',
        '2024-01-20',
        'ACTIVE',
        CURRENT_TIMESTAMP()
    ),
    (
        'C003',
        'CUST_002',
        'Bob Johnson',
        'bob.johnson@globaltech.com',
        '555-0201',
        '789 Pine St',
        'London',
        'England',
        'UK',
        'SW1A 1AA',
        '2024-02-01',
        'ACTIVE',
        CURRENT_TIMESTAMP()
    ),
    (
        'C004',
        'CUST_003',
        'Alice Wilson',
        'alice.wilson@innosys.com',
        '555-0301',
        '321 Cedar Blvd',
        'San Francisco',
        'CA',
        'USA',
        '94102',
        '2024-02-15',
        'ACTIVE',
        CURRENT_TIMESTAMP()
    ),
    (
        'C005',
        'CUST_004',
        'Charlie Brown',
        'charlie.brown@entdata.com',
        '555-0401',
        '654 Maple Dr',
        'Sydney',
        'NSW',
        'Australia',
        '2000',
        '2024-03-01',
        'ACTIVE',
        CURRENT_TIMESTAMP()
    );
INSERT INTO
    SALES_TRANSACTIONS
VALUES
    (
        'T001',
        'CUST_001',
        'C001',
        'P001',
        'Laptop Pro',
        'Electronics',
        2,
        1299.99,
        2599.98,
        100.00,
        199.99,
        '2024-03-15',
        '2024-03-15 10:30:00',
        'Sarah Connor',
        'North America',
        CURRENT_TIMESTAMP()
    ),
    (
        'T002',
        'CUST_001',
        'C002',
        'P002',
        'Wireless Mouse',
        'Accessories',
        5,
        29.99,
        149.95,
        0.00,
        12.00,
        '2024-03-16',
        '2024-03-16 14:15:00',
        'Sarah Connor',
        'North America',
        CURRENT_TIMESTAMP()
    ),
    (
        'T003',
        'CUST_002',
        'C003',
        'P003',
        'Monitor 4K',
        'Electronics',
        1,
        599.99,
        599.99,
        50.00,
        45.00,
        '2024-03-17',
        '2024-03-17 09:45:00',
        'James Bond',
        'Europe',
        CURRENT_TIMESTAMP()
    ),
    (
        'T004',
        'CUST_003',
        'C004',
        'P001',
        'Laptop Pro',
        'Electronics',
        1,
        1299.99,
        1299.99,
        0.00,
        99.99,
        '2024-03-18',
        '2024-03-18 16:20:00',
        'Tony Stark',
        'North America',
        CURRENT_TIMESTAMP()
    ),
    (
        'T005',
        'CUST_004',
        'C005',
        'P004',
        'Keyboard Mechanical',
        'Accessories',
        3,
        149.99,
        449.97,
        30.00,
        35.00,
        '2024-03-19',
        '2024-03-19 11:10:00',
        'Bruce Wayne',
        'Asia Pacific',
        CURRENT_TIMESTAMP()
    );
INSERT INTO
    PRODUCTS
VALUES
    (
        'P001',
        'CUST_001',
        'Laptop Pro',
        'Electronics',
        'Computers',
        'TechBrand',
        'High-performance laptop',
        1299.99,
        800.00,
        38.46,
        TRUE,
        '2024-01-01',
        '2024-01-01'
    ),
    (
        'P002',
        'CUST_001',
        'Wireless Mouse',
        'Accessories',
        'Input Devices',
        'TechBrand',
        'Ergonomic wireless mouse',
        29.99,
        15.00,
        50.02,
        TRUE,
        '2024-01-01',
        '2024-01-01'
    ),
    (
        'P003',
        'CUST_002',
        'Monitor 4K',
        'Electronics',
        'Displays',
        'ViewTech',
        '27-inch 4K monitor',
        599.99,
        350.00,
        41.67,
        TRUE,
        '2024-01-01',
        '2024-01-01'
    ),
    (
        'P004',
        'CUST_003',
        'Keyboard Mechanical',
        'Accessories',
        'Input Devices',
        'KeyMaster',
        'RGB mechanical keyboard',
        149.99,
        75.00,
        50.00,
        TRUE,
        '2024-01-01',
        '2024-01-01'
    ),
    (
        'P005',
        'CUST_004',
        'Tablet Pro',
        'Electronics',
        'Mobile',
        'MobileTech',
        '10-inch professional tablet',
        799.99,
        500.00,
        37.50,
        TRUE,
        '2024-01-01',
        '2024-01-01'
    );
    
-- =====================================================================
-- OPTION 1. SECURE VIEWS
-- =====================================================================

--Option 1: Create secure views - without row access policies- to filter rows and share them in a listing
USE SCHEMA SECURE_VIEWS;
-- Secure view for customer summary with aggregated data
--Step 1.1 Create a ssecure view for the client and account mapping table which will be part of the data share listing
CREATE OR REPLACE SECURE VIEW SECURE_VIEWS.CUSTOMER_ACCOUNT_MAPPING_SECURE_VIEW AS
SELECT *
FROM CORE_DATA.CUSTOMER_ACCOUNT_MAPPING cam
WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = CURRENT_ACCOUNT();
    
--Step 1.2 Create secure views on base tables to filter customer specific rows
CREATE OR REPLACE SECURE VIEW CUSTOMER_SECURE_VIEW AS
SELECT *
FROM CORE_DATA.CUSTOMERS c
WHERE c.CUSTOMER_KEY in (
        SELECT CUSTOMER_KEY
        FROM SECURE_VIEWS.CUSTOMER_ACCOUNT_MAPPING_SECURE_VIEW cam
        WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = CURRENT_ACCOUNT()
    );

CREATE OR REPLACE SECURE VIEW SALES_TRANSACTIONS_SECURE_VIEW AS
SELECT *
FROM CORE_DATA.SALES_TRANSACTIONS s
WHERE s.CUSTOMER_KEY in (
        SELECT CUSTOMER_KEY
        FROM SECURE_VIEWS.CUSTOMER_ACCOUNT_MAPPING_SECURE_VIEW cam
        WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = CURRENT_ACCOUNT()
    );
    
CREATE OR REPLACE SECURE VIEW PRODUCTS_SECURE_VIEW AS
SELECT *
FROM CORE_DATA.PRODUCTS p
WHERE p.CUSTOMER_KEY in (
        SELECT CUSTOMER_KEY
        FROM SECURE_VIEWS.CUSTOMER_ACCOUNT_MAPPING_SECURE_VIEW cam
        WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = CURRENT_ACCOUNT()
    );
    
--Step 1.3 Create Share
CREATE OR REPLACE SHARE SHARE_SECURE_VIEWS 
COMMENT = 'Secure customer data share with dynamic row-level filtering without row access policies';

-- Grant usage on database and schemas to the share
GRANT USAGE ON DATABASE SECURE_DATA_SHARING TO SHARE SHARE_SECURE_VIEWS;
GRANT USAGE ON SCHEMA SECURE_DATA_SHARING.SECURE_VIEWS TO SHARE SHARE_SECURE_VIEWS;

-- Grant access to secure views
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_VIEWS.CUSTOMER_ACCOUNT_MAPPING_SECURE_VIEW TO SHARE SHARE_SECURE_VIEWS;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_VIEWS.CUSTOMER_SECURE_VIEW TO SHARE SHARE_SECURE_VIEWS;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_VIEWS.SALES_TRANSACTIONS_SECURE_VIEW TO SHARE SHARE_SECURE_VIEWS;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_VIEWS.PRODUCTS_SECURE_VIEW TO SHARE SHARE_SECURE_VIEWS;

--Step 1.4 Create Listing that includes the share created above. Example below is a very basic.
--Feel free to elaborate the YML ddescription here or expand the listing information in Snowsight listings wizard
CREATE EXTERNAL LISTING IF NOT EXISTS LISTING_SECURE_VIEWS SHARE SHARE_SECURE_VIEWS AS $$
title: "CUSTOMER DATA SECURE VIEWS"
description: "This listing provides access CUSTOMER DATA IN SECURE VIEWS"
listing_terms:
   type: "STANDARD"
targets:
    accounts: ["CUSTORG1.ACOUNTNAME1","CUSTORG2.ACOUNTNAME2"]
$$ COMMENT = 'Change your target accounts as created in the mapping table';


-- =====================================================================
-- OPTION 2. ROW ACCESS POLICIES ON BASE TABLES
-- =====================================================================
--Option 2: Create row access policies to filter rows and share them in a listing
--Step 2.1 Create Row Access Policy
-- Row access policy for customer-based filtering using current_account()
USE SCHEMA CORE_DATA;

CREATE OR REPLACE ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER AS (CUSTOMER_KEY VARCHAR(50)) RETURNS BOOLEAN -> EXISTS (
    SELECT 1
    FROM CORE_DATA.CUSTOMER_ACCOUNT_MAPPING cam
    WHERE cam.CUSTOMER_KEY = CUSTOMER_KEY
        AND cam.IS_ACTIVE = TRUE
        AND (
            -- Allow access if current account matches the mapped account
            cam.SNOWFLAKE_ACCOUNT_IDENTIFIER = CURRENT_ACCOUNT()
            OR cam.ACCOUNT_LOCATOR = CURRENT_ACCOUNT()
            OR CURRENT_ACCOUNT() IN ('GX99240') -- show all records if its provider account
        )
);
    

--Step 2.2 Apply Row access policy to base tables
ALTER TABLE CUSTOMERS ADD ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER ON (CUSTOMER_KEY);
ALTER TABLE SALES_TRANSACTIONS ADD ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER ON (CUSTOMER_KEY);
ALTER TABLE PRODUCTS ADD ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER ON (CUSTOMER_KEY);

--Step 2.3 Create a share with Secured Views without Row Access Policies
-- Create share for customer data
CREATE SHARE IF NOT EXISTS SHARE_TABLES_WITH_RAP COMMENT = 'Secure customer data share with row access policies';

-- Grant usage on database and schemas to the share
GRANT USAGE ON DATABASE SECURE_DATA_SHARING TO SHARE SHARE_TABLES_WITH_RAP;
GRANT USAGE ON SCHEMA SECURE_DATA_SHARING.CORE_DATA TO SHARE SHARE_TABLES_WITH_RAP;
    
-- Grant access to secure views
GRANT SELECT ON VIEW SECURE_DATA_SHARING.CORE_DATA.CUSTOMERS TO SHARE SHARE_TABLES_WITH_RAP;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.CORE_DATA.SALES_TRANSACTIONS TO SHARE SHARE_TABLES_WITH_RAP;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.CORE_DATA.PRODUCTS TO SHARE SHARE_TABLES_WITH_RAP;

--Step 2.4 Create Listing that includes the share created above. Example below is a very basic.
--Feel free to elaborate the YML ddescription here or expand the listing information in Snowsight listings wizard
CREATE EXTERNAL LISTING IF NOT EXISTS LISTING_TABLES_WITH_RAP SHARE SHARE_TABLES_WITH_RAP AS $$
title: "CUSTOMER DATA TABLES WITH RAP"
description: "This listing provides access CUSTOMER DATA with Row Access Policies"
listing_terms:
   type: "STANDARD"
targets:
    accounts: ["CUSTORG1.ACOUNTNAME1","CUSTORG2.ACOUNTNAME2"]
$$ COMMENT = 'Change your target accounts as created in the mapping table';


-- =====================================================================
-- OPTION 3. DYNAMIC TABLES
-- =====================================================================
--Option 3:Create Dynamic tables and share seperate listings with each customer with their specific dynamic tables
--Step 3.1 Create Dynamic tables from base tables with Row Access Policies applied.
--Create seperate schema for each customer so it holds dynamic tables belong to that customer
CREATE OR REPLACE SCHEMA DYNAMIC_TABLES_<CLIENTX>;
USE SCHEMA DYNAMIC_TABLES_<CLIENTX>;

CREATE OR REPLACE DYNAMIC TABLE CUSTOMERS_DT TARGET_LAG = '24 HOURS' WAREHOUSE = COMPUTE_WH AS
SELECT *
FROM CORE_DATA.CUSTOMERS c
WHERE c.CUSTOMER_KEY in (
    SELECT CUSTOMER_KEY
    FROM CORE_DATA.CUSTOMER_ACCOUNT_MAPPING cam
    WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = 'XXY57412'
    );
    
CREATE OR REPLACE DYNAMIC TABLE PRODUCTS_DT TARGET_LAG = '24 HOURS' WAREHOUSE = COMPUTE_WH AS
SELECT *
FROM CORE_DATA.PRODUCTS p
WHERE p.CUSTOMER_KEY in (
    SELECT CUSTOMER_KEY
    FROM CORE_DATA.CUSTOMER_ACCOUNT_MAPPING cam
    WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = 'XXY57412'
    );
    
CREATE OR REPLACE DYNAMIC TABLE SALES_TRANSACTIONS_DT TARGET_LAG = '24 HOURS' WAREHOUSE = COMPUTE_WH AS
SELECT *
FROM CORE_DATA.SALES_TRANSACTIONS s
WHERE s.CUSTOMER_KEY in (
    SELECT CUSTOMER_KEY
    FROM CORE_DATA.CUSTOMER_ACCOUNT_MAPPING cam
    WHERE cam.IS_ACTIVE = TRUE AND cam.ACCOUNT_LOCATOR = 'XXY57412'
    );
    
--Step 3.2 Create a share with Dynamic Tables
-- Create share for customer data. Note the share is specific to each customer
CREATE SHARE IF NOT EXISTS SHARE_DYNAMIC_TABLES_<CLIENTX> COMMENT = 'Secure customer data share with DYNAMIC_TABLES';

-- Grant usage on database and schemas to the share
GRANT USAGE ON DATABASE SECURE_DATA_SHARING TO SHARE SHARE_DYNAMIC_TABLES_<CLIENTX>;
GRANT USAGE ON SCHEMA SECURE_DATA_SHARING.DYNAMIC_TABLES_<CLIENTX> TO SHARE SHARE_DYNAMIC_TABLES_<CLIENTX>;

-- Grant access to Dynamic Tables
GRANT SELECT ON VIEW SECURE_DATA_SHARING.DYNAMIC_TABLES_<CLIENTX>.CUSTOMERS_DT TO SHARE SHARE_DYNAMIC_TABLES_<CLIENTX>;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.DYNAMIC_TABLES_<CLIENTX>.SALES_TRANSACTIONS_DT TO SHARE SHARE_DYNAMIC_TABLES_<CLIENTX>;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.DYNAMIC_TABLES_<CLIENTX>.PRODUCTS_DT TO SHARE SHARE_DYNAMIC_TABLES_<CLIENTX>;
    
--Step 3.3 Create Listing that includes the share created above. Example below is a very basic.
--Feel free to elaborate the YML ddescription here or expand the listing information in Snowsight listings wizard
CREATE EXTERNAL LISTING IF NOT EXISTS LISTING_DYNAMIC_TABLES_<CLIENTX> SHARE SHARE_DYNAMIC_TABLES_<CLIENTX> AS $$
title: "CUSTOMER DATA WITH DYNAMIC_TABLES for customer AWS2"
description: "This listing provides access CUSTOMER DATA with DYNAMIC_TABLES"
listing_terms:
   type: "STANDARD"
targets:
    accounts: ["CUSTORG1.ACOUNTNAME1"]
$$ COMMENT = 'Change your target account name  as created in the mapping table';


-- =====================================================================
-- OPTION 4. SECURE MATERIALIZED VIEWS
-- =====================================================================
--Step 4.1 DROP ROW ACCESS POLICIES ON BASE TABLES
USE SCHEMA CORE_DATA;
ALTER TABLE CUSTOMERS DROP ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER;
ALTER TABLE SALES_TRANSACTIONS DROP ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER;
ALTER TABLE PRODUCTS DROP ROW ACCESS POLICY CUSTOMER_ACCOUNT_FILTER;

--Step 4.2 Create USER DEFINED FUNCTION TO FILTER THE ROWS TO CRESTE Secure Materialized Views from base tables
--Create seperate schema for each customer so it holds SECURE MATERIALIZED VIEWS belong to that customer
CREATE OR REPLACE SCHEMA SECURE_MATERIALIZED_VIEWS_<CLIENTX>;
USE SCHEMA SECURE_MATERIALIZED_VIEWS_<CLIENTX>;

CREATE OR REPLACE FUNCTION FILTER_CUST_ROW(CUST_KEY varchar(50), ACC_LOCATOR varchar(50)) RETURNS BOOLEAN LANGUAGE SQL AS $$
 EXISTS (SELECT 1 
        FROM CORE_DATA.CUSTOMER_ACCOUNT_MAPPING cam
        WHERE cam.IS_ACTIVE = TRUE AND CAM.CUSTOMER_KEY = CUST_KEY AND  cam.ACCOUNT_LOCATOR = ACC_LOCATOR)
 $$;
 
--Step 4.3 CREATE SECURE MATERIALIZED VIEWS
CREATE OR REPLACE SECURE MATERIALIZED VIEW CUSTOMERS_SMV AS
SELECT *
FROM CORE_DATA.CUSTOMERS c
WHERE FILTER_CUST_ROW(c.CUSTOMER_KEY, 'UZC57412');

CREATE OR REPLACE SECURE MATERIALIZED VIEW PRODUCTS_SMV AS
SELECT *
FROM CORE_DATA.PRODUCTS p
WHERE FILTER_CUST_ROW(P.CUSTOMER_KEY, 'UZC57412');

CREATE OR REPLACE SECURE MATERIALIZED VIEW SALES_TRANSACTIONS_SMV AS
SELECT *
FROM CORE_DATA.SALES_TRANSACTIONS s
WHERE FILTER_CUST_ROW(S.CUSTOMER_KEY, 'UZC57412');

--Step 4.4 Create a share with SECURE MATERIALIZED VIEWS
-- Create share for customer data. Note the share is specific to each customer
CREATE SHARE IF NOT EXISTS SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX> COMMENT = 'Secure customer data share with SECURE MATERIALIED VIEWS';

-- Grant usage on database and schemas to the share
GRANT USAGE ON DATABASE SECURE_DATA_SHARING TO SHARE SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX>;
GRANT USAGE ON SCHEMA SECURE_DATA_SHARING.SECURE_MATERIALIZED_VIEWS_<CLIENTX> TO SHARE SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX>;

-- Grant access to Dynamic Tables
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_MATERIALIZED_VIEWS_<CLIENTX>.CUSTOMERS_SMV TO SHARE SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX>;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_MATERIALIZED_VIEWS_<CLIENTX>.SALES_TRANSACTIONS_SMV TO SHARE SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX>;
GRANT SELECT ON VIEW SECURE_DATA_SHARING.SECURE_MATERIALIZED_VIEWS_<CLIENTX>.PRODUCTS_SMV TO SHARE SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX>;
    
--Step 4.5 Create Listing that includes the share created above. Example below is a very basic.
--Feel free to elaborate the YML ddescription here or expand the listing information in Snowsight listings wizard
CREATE EXTERNAL LISTING IF NOT EXISTS LISTING_SECURE_MATERIALIZED_VIEWS_<CLIENTX> SHARE SHARE_SECURE_MATERIALIZED_VIEWS_<CLIENTX> AS $$
title: "CUSTOMER DATA WITH SECURE_MATERIALIZED_VIEWS_<CLIENTX> for customer AWS2"
description: "This listing provides access CUSTOMER DATA with SECURE_MATERIALIZED_VIEWS_<CLIENTX>"
listing_terms:
   type: "STANDARD"
targets:
    accounts: ["CUSTORG1.ACOUNTNAME1"]
$$ COMMENT = 'Change your target account name  as created in the mapping table';


-- =====================================================================
-- OPTIONAL STEP: CLEANUP SCRIPT TO DROP SCHEMAS AND DATABASE CREATED
-- =====================================================================
USE DATABASE SECURE_DATA_SHARING;

-- Drop schemas
DROP SCHEMA IF NOT EXISTS CORE_DATA;
DROP SCHEMA IF NOT EXISTS SECURE_VIEWS;
DROP SCHEMA IF NOT EXISTS SECURE_MATERIALIZED_VIEWS;
DROP SCHEMA IF NOT EXISTS DYNAMIC_TABLES;
DROP SCHEMA IF NOT EXISTS SHARED_DATA;

-- Drop database created for secure data sharing
DROP DATABASE IF NOT EXISTS SECURE_DATA_SHARING;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
