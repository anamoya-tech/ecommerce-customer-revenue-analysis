-- 04_cohort_analysis.sql
-- Cohort analysis based on customer's first purchase month
-- Output table: ecommerce.cohort_analysis
-- Tracks cohort activity (active customers) and revenue over time

CREATE OR REPLACE TABLE `ecommerce.cohort_analysis` AS
WITH customer_first_purchase AS (
  SELECT
    CustomerID,
    DATE_TRUNC(DATE(MIN(InvoiceDate)), MONTH) AS cohort_month
  FROM `ecommerce.online_retail_clean`
  GROUP BY CustomerID
),
transactions_with_cohort AS (
  SELECT
    t.CustomerID,
    DATE_TRUNC(DATE(t.InvoiceDate), MONTH) AS transaction_month,
    c.cohort_month,
    DATE_DIFF(
      DATE_TRUNC(DATE(t.InvoiceDate), MONTH),
      c.cohort_month,
      MONTH
    ) AS months_since_first_purchase,
    t.Revenue
  FROM `ecommerce.online_retail_clean` t
  JOIN customer_first_purchase c
    ON t.CustomerID = c.CustomerID
)
SELECT
  cohort_month,
  months_since_first_purchase,
  COUNT(DISTINCT CustomerID) AS active_customers,
  ROUND(SUM(Revenue), 2) AS total_revenue
FROM transactions_with_cohort
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;

-- Optional validation queries (run separately)

-- Cohort sizes (month 0)
-- SELECT
--   cohort_month,
--   active_customers AS cohort_size
-- FROM `ecommerce.cohort_analysis`
-- WHERE months_since_first_purchase = 0
-- ORDER BY cohort_month;

-- Check max month offset (how far cohorts extend)
-- SELECT
--   MAX(months_since_first_purchase) AS max_months_since_first_purchase
-- FROM `ecommerce.cohort_analysis`;
