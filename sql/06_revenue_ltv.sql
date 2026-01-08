-- 06_revenue_ltv.sql
-- Revenue & LTV analysis (business-ready tables)
-- Sources:
--   - ecommerce.online_retail_clean (transaction level)
--   - ecommerce.customer_metrics (customer level)
--   - ecommerce.customer_rfm (RFM segments)
--   - ecommerce.cohort_analysis (cohort activity & revenue)

--------------------------------------------------------------------------------
-- 1) Monthly revenue KPIs (trend)
--------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecommerce.monthly_revenue_kpis` AS
SELECT
  DATE_TRUNC(DATE(InvoiceDate), MONTH) AS month,
  ROUND(SUM(Revenue), 2) AS revenue,
  COUNT(DISTINCT InvoiceNo) AS orders,
  COUNT(DISTINCT CustomerID) AS active_customers,
  ROUND(SAFE_DIVIDE(SUM(Revenue), COUNT(DISTINCT InvoiceNo)), 2) AS avg_order_value,
  ROUND(SAFE_DIVIDE(SUM(Revenue), COUNT(DISTINCT CustomerID)), 2) AS arpu
FROM `ecommerce.online_retail_clean`
GROUP BY month
ORDER BY month;


--------------------------------------------------------------------------------
-- 2) Customer value tiers (top 1%, 5%, 20%) + basic outlier flag
--------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecommerce.customer_value_tiers` AS
WITH ranked AS (
  SELECT
    CustomerID,
    total_orders,
    total_revenue,
    recency_days,

    -- Percentile bucket: 1 = top 1% (highest revenue), 100 = lowest
    NTILE(100) OVER (ORDER BY total_revenue DESC) AS revenue_percentile_bucket
  FROM `ecommerce.customer_metrics`
)
SELECT
  *,
  CASE
    WHEN revenue_percentile_bucket <= 1 THEN 'Top 1%'
    WHEN revenue_percentile_bucket <= 5 THEN 'Top 5%'
    WHEN revenue_percentile_bucket <= 20 THEN 'Top 20%'
    ELSE 'Bottom 80%'
  END AS value_tier,

  -- Simple "wholesale-like" flag (not removing, just labeling)
  CASE
    WHEN total_orders >= 50 THEN TRUE
    ELSE FALSE
  END AS is_wholesale_like
FROM ranked;


--------------------------------------------------------------------------------
-- 3) Pareto table (cumulative revenue share by customer)
--------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecommerce.revenue_pareto` AS
WITH base AS (
  SELECT
    CustomerID,
    total_revenue
  FROM `ecommerce.customer_metrics`
),
ordered AS (
  SELECT
    CustomerID,
    total_revenue,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    SUM(total_revenue) OVER () AS total_revenue_all,
    SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cum_revenue
  FROM base
)
SELECT
  CustomerID,
  total_revenue,
  revenue_rank,
  cum_revenue,
  ROUND(SAFE_DIVIDE(cum_revenue, total_revenue_all), 6) AS cum_revenue_share
FROM ordered
ORDER BY revenue_rank;


--------------------------------------------------------------------------------
-- 4) Revenue & LTV summary by RFM segment
--------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecommerce.rfm_segment_kpis` AS
WITH seg AS (
  SELECT
    rfm_segment,
    CustomerID,
    recency_days,
    total_orders,
    total_revenue
  FROM `ecommerce.customer_rfm`
),
tot AS (
  SELECT SUM(total_revenue) AS total_rev
  FROM seg
)
SELECT
  rfm_segment,
  COUNT(*) AS customers,
  ROUND(SUM(total_revenue), 2) AS revenue,
  ROUND(SAFE_DIVIDE(SUM(total_revenue), (SELECT total_rev FROM tot)), 6) AS revenue_share,
  ROUND(AVG(total_revenue), 2) AS avg_ltv,
  ROUND(AVG(total_orders), 2) AS avg_orders,
  ROUND(AVG(recency_days), 1) AS avg_recency_days
FROM seg
GROUP BY rfm_segment
ORDER BY revenue DESC;


--------------------------------------------------------------------------------
-- 5) Cohort revenue summary (cohort size + total revenue + avg revenue per customer)
--------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecommerce.cohort_revenue_summary` AS
WITH cohort_size AS (
  SELECT
    cohort_month,
    active_customers AS cohort_size
  FROM `ecommerce.cohort_analysis`
  WHERE months_since_first_purchase = 0
),
cohort_rev AS (
  SELECT
    cohort_month,
    ROUND(SUM(total_revenue), 2) AS cohort_total_revenue
  FROM `ecommerce.cohort_analysis`
  GROUP BY cohort_month
)
SELECT
  s.cohort_month,
  s.cohort_size,
  r.cohort_total_revenue,
  ROUND(SAFE_DIVIDE(r.cohort_total_revenue, s.cohort_size), 2) AS avg_revenue_per_customer
FROM cohort_size s
JOIN cohort_rev r
  USING (cohort_month)
ORDER BY cohort_month;


--------------------------------------------------------------------------------
-- Optional validation queries (run separately)
--------------------------------------------------------------------------------
-- Monthly KPI preview
-- SELECT * FROM `ecommerce.monthly_revenue_kpis` ORDER BY month LIMIT 24;

-- How concentrated is revenue? (Top 20% customers -> cum share near ~80% if Pareto-like)
-- SELECT * FROM `ecommerce.revenue_pareto` WHERE revenue_rank IN (10, 50, 100, 500, 1000);

-- Segment KPIs preview
-- SELECT * FROM `ecommerce.rfm_segment_kpis` ORDER BY revenue DESC;

