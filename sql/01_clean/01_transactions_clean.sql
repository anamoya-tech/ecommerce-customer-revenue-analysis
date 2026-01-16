-- 01_clean/01_transactions_clean.sql
-- Creates clean transaction-line table (keeps returns)

CREATE OR REPLACE TABLE `ecommerce-customer-analysis.ecommerce.ecommerce_clean_01_transactions` AS
SELECT
  InvoiceNo,
  StockCode,
  Description,
  CAST(Quantity AS INT64) AS Quantity,
  TIMESTAMP(InvoiceDate) AS InvoiceTimestamp,
  DATE(TIMESTAMP(InvoiceDate)) AS InvoiceDate,
  CAST(UnitPrice AS FLOAT64) AS UnitPrice,
  CustomerID,
  Country,
  CASE WHEN CAST(Quantity AS INT64) < 0 THEN TRUE ELSE FALSE END AS is_return,
  CAST(Quantity AS INT64) * CAST(UnitPrice AS FLOAT64) AS line_revenue
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_raw_00`
WHERE CustomerID IS NOT NULL
  AND UnitPrice IS NOT NULL
  AND CAST(UnitPrice AS FLOAT64) > 0
  AND Quantity IS NOT NULL
  AND CAST(Quantity AS INT64) != 0;
