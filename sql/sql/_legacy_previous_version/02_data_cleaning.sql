-- 02_data_cleaning.sql
-- Create a clean version of the online retail dataset
-- This table will be used for all downstream analysis

CREATE OR REPLACE TABLE `ecommerce.online_retail_clean` AS
SELECT
  InvoiceNo,
  StockCode,
  Description,
  SAFE_CAST(Quantity AS INT64) AS Quantity,
  TIMESTAMP(InvoiceDate) AS InvoiceDate,
  SAFE_CAST(UnitPrice AS FLOAT64) AS UnitPrice,
  CustomerID,
  Country,

  -- Business metrics
  SAFE_CAST(Quantity AS INT64) * SAFE_CAST(UnitPrice AS FLOAT64) AS Revenue

FROM `ecommerce.online_retail_raw`

WHERE
  CustomerID IS NOT NULL        -- only identified customers
  AND Quantity > 0              -- remove returns
  AND UnitPrice > 0;            -- remove free / invalid prices

-- Check new Table
SELECT
  COUNT(*) AS clean_rows,
  COUNT(DISTINCT CustomerID) AS clean_customers,
  SUM(Revenue) AS total_revenue
FROM `ecommerce.online_retail_clean`;
