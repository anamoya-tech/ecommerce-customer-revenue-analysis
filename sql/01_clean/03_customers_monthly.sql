-- 01_clean/03_customers_monthly.sql
-- Creates customer-month table (1 row per CustomerID per month)

CREATE OR REPLACE TABLE `ecommerce-customer-analysis.ecommerce.ecommerce_clean_03_customers_monthly` AS
SELECT
  DATE_TRUNC(InvoiceDate, MONTH) AS month,
  CustomerID,
  COUNT(DISTINCT InvoiceNo) AS orders_month,
  SUM(line_revenue) AS net_revenue_month,
  SUM(CASE WHEN is_return = FALSE THEN line_revenue ELSE 0 END) AS gross_revenue_month,
  SUM(CASE WHEN is_return = TRUE THEN line_revenue ELSE 0 END) AS returns_value_month,
  TRUE AS is_active_month
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_clean_01_transactions`
GROUP BY month, CustomerID;
