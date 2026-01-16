-- 03_validation/03_outliers_jan2011.sql
-- Identify invoices driving unusually high negative revenue (Jan 2011)

SELECT
  InvoiceNo,
  SUM(Quantity * UnitPrice) AS invoice_net_value,
  COUNT(*) AS lines
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_raw_00`
WHERE InvoiceDate >= '2011-01-01'
  AND InvoiceDate < '2011-02-01'
GROUP BY InvoiceNo
ORDER BY invoice_net_value ASC
LIMIT 20;
