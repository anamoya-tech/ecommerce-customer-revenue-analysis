-- 01_clean/02_orders_clean.sql
-- Creates invoice-level table (1 row per InvoiceNo)

CREATE OR REPLACE TABLE `ecommerce-customer-analysis.ecommerce.ecommerce_clean_02_orders` AS
SELECT
  InvoiceNo,
  ANY_VALUE(CustomerID) AS CustomerID,
  DATE(MIN(InvoiceDate)) AS InvoiceDate,
  DATE_TRUNC(DATE(MIN(InvoiceDate)), MONTH) AS month,
  SUM(line_revenue) AS order_net_revenue,
  SUM(CASE WHEN is_return = FALSE THEN line_revenue ELSE 0 END) AS order_gross_revenue,
  SUM(CASE WHEN is_return = TRUE THEN line_revenue ELSE 0 END) AS order_returns_value,
  COUNT(*) AS lines_count,
  COUNT(DISTINCT StockCode) AS distinct_skus
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_clean_01_transactions`
GROUP BY InvoiceNo;
