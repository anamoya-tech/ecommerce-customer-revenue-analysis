-- 03_validation/02_returns_impact_monthly.sql
-- Monthly impact of returns on revenue (raw data)

SELECT
  DATE_TRUNC(DATE(InvoiceDate), MONTH) AS month,
  SUM(Quantity * UnitPrice) AS net_revenue,
  SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END) AS gross_revenue,
  SUM(CASE WHEN Quantity < 0 THEN Quantity * UnitPrice ELSE 0 END) AS returns_value,
  SAFE_DIVIDE(
    SUM(ABS(CASE WHEN Quantity < 0 THEN Quantity * UnitPrice ELSE 0 END)),
    SUM(CASE WHEN Quantity > 0 THEN Quantity * UnitPrice ELSE 0 END)
  ) AS return_rate_value
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_raw_00`
WHERE InvoiceDate >= '2011-01-01'
  AND InvoiceDate < '2011-12-01'
GROUP BY month
ORDER BY month;
