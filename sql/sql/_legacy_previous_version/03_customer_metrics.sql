-- 03_customer_metrics.sql
-- Customer-level metrics for advanced analysis
-- This table aggregates transactional data into customer-level features
-- to support segmentation and lifecycle analysis

CREATE OR REPLACE TABLE `ecommerce.customer_metrics` AS
SELECT
  CustomerID,

  -- Customer lifespan (days between first and last purchase)
  DATE_DIFF(
    DATE(MAX(InvoiceDate)),
    DATE(MIN(InvoiceDate)),
    DAY
  ) AS customer_lifespan_days,

  -- Recency (days since last purchase, relative to dataset end date)
  DATE_DIFF(
    DATE '2011-12-09',   -- dataset end date
    DATE(MAX(InvoiceDate)),
    DAY
  ) AS recency_days,

  -- Frequency
  COUNT(DISTINCT InvoiceNo) AS total_orders,

  -- Monetary
  SUM(Revenue) AS total_revenue,
  AVG(Revenue) AS avg_order_value

FROM `ecommerce.online_retail_clean`
GROUP BY CustomerID;

-- Validation query (executed separately during analysis)
-- SELECT
--   COUNT(*) AS customers,
--   AVG(total_revenue) AS avg_ltv,
--   AVG(total_orders) AS avg_orders
-- FROM `ecommerce.customer_metrics`;
