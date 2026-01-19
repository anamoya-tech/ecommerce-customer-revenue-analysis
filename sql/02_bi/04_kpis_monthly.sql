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

    -- Revenue
    SUM(IF(Quantity > 0, line_revenue, 0)) AS gross_revenue,
    ABS(SUM(IF(Quantity < 0, line_revenue, 0))) AS returns_value,

    -- Orders & customers (purchases only)
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

  -- North Star
  gross_revenue - returns_value AS net_revenue,

  -- Return rate (value)
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
