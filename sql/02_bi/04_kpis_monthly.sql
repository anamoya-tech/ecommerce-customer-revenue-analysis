-- 02_bi/04_kpis_monthly.sql
-- Monthly KPI table for BI/Tableau (includes scale standardization)

CREATE OR REPLACE TABLE `ecommerce-customer-analysis.ecommerce.ecommerce_bi_01_kpis_monthly` AS
SELECT
  month,

  -- Revenue in minor units (raw)
  SUM(net_revenue_month) AS net_revenue_raw,
  SUM(gross_revenue_month) AS gross_revenue_raw,
  SUM(returns_value_month) AS returns_value_raw,

  -- Revenue standardized (assumed minor units -> major units)
  SUM(net_revenue_month) / 100.0 AS net_revenue,
  SUM(gross_revenue_month) / 100.0 AS gross_revenue,
  SUM(returns_value_month) / 100.0 AS returns_value,

  COUNT(DISTINCT CustomerID) AS active_customers,
  SUM(orders_month) AS orders,

  SAFE_DIVIDE(SUM(net_revenue_month) / 100.0, SUM(orders_month)) AS aov,
  SAFE_DIVIDE(SUM(net_revenue_month) / 100.0, COUNT(DISTINCT CustomerID)) AS arpu,

  SAFE_DIVIDE(
    ABS(SUM(returns_value_month) / 100.0),
    (SUM(gross_revenue_month) / 100.0)
  ) AS return_rate_value
FROM `ecommerce-customer-analysis.ecommerce.ecommerce_clean_03_customers_monthly`
GROUP BY month
ORDER BY month;
