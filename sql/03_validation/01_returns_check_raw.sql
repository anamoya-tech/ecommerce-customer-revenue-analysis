-- 03_validation/01_returns_check_raw.sql
-- Verify returns exist in raw data

SELECT
  COUNT(*) AS rows_total,
  COUNTIF(Quantity < 0) AS rows_returns,
  COUNTIF(Quantity = 0) AS rows_qty_zero,
  COUNTIF(Quantity > 0) AS rows_sales
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_raw_00`;
