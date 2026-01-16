-- 01. Basic dataset overview
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT InvoiceNo) AS total_invoices,
  COUNT(DISTINCT CustomerID) AS total_customers
FROM `ecommerce.online_retail_raw`;

-- 02. Null values by column
SELECT
  COUNTIF(CustomerID IS NULL) AS customerid_nulls,
  COUNTIF(Description IS NULL) AS description_nulls
FROM `ecommerce.online_retail_raw`;

-- 03. Check negative and zero values
SELECT
  COUNTIF(Quantity <= 0) AS invalid_quantity_rows,
  COUNTIF(UnitPrice <= 0) AS invalid_price_rows
FROM `ecommerce.online_retail_raw`;
