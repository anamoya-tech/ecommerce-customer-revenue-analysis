-- 02_bi/04_kpis_monthly.sql
-- Monthly KPI table for BI/Tableau (single source of truth from cleaned transactions)
--
-- Notes:
-- - Returns are defined as Quantity < 0 and represented as an absolute (positive) value in BI.
-- - Orders and Active Customers are based on purchases only (Quantity > 0).
-- - Return Rate (Value) is calculated as Returns Value / Gross Revenue.
-- - Tableau applies the reporting scope filter (Jan–Nov 2011) and excludes Dec 2011.

CREATE OR REPLACE TABLE `ecommerce-customer-analysis.ecommerce.ecommerce_bi_01_kpis_monthly` AS
WITH base AS (
  SELECT
    EXTRACT(YEAR FROM InvoiceDate) AS year,
    EXTRACT(MONTH FROM InvoiceDate) AS month_num,
    CustomerID,
    InvoiceNo,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS line_revenue
  FROM `ecommerce-customer-analysis.ecommerce.ecommerce_clean_01_transactions`
  WHERE CustomerID IS NOT NULL
),

monthly AS (
  SELECT
    year,
    month_num,

    -- Revenue components
    SUM(IF(Quantity > 0, line_revenue, 0)) AS gross_revenue,
    ABS(SUM(IF(Quantity < 0, line_revenue, 0))) AS returns_value,

    -- Volume metrics (purchases only)
    COUNT(DISTINCT IF(Quantity > 0, InvoiceNo, NULL)) AS orders,
    COUNT(DISTINCT IF(Quantity > 0, CustomerID, NULL)) AS active_customers
  FROM base
  GROUP BY 1,2
)

SELECT
  year,
  month_num,

  gross_revenue,
  returns_value,

  -- North Star metric
  gross_revenue - returns_value AS net_revenue,

  -- Return rate (value-based)
  SAFE_DIVIDE(returns_value, gross_revenue) AS return_rate_value,

  orders,
  active_customers,

  -- Value metrics
  SAFE_DIVIDE(gross_revenue - returns_value, orders) AS aov,
  SAFE_DIVIDE(gross_revenue - returns_value, active_customers) AS arpu,

  -- Month label for Tableau
  FORMAT_DATE('%b', DATE(year, month_num, 1)) AS month_en

FROM monthly
ORDER BY year, month_num;
