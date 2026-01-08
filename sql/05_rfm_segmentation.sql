-- 05_rfm_segmentation.sql
-- RFM Scoring and Customer Segmentation
-- Output tables:
--   - ecommerce.customer_rfm (customer-level RFM scores + segment)
--   - ecommerce.rfm_segment_summary (segment-level KPIs for reporting)
-- Source table: ecommerce.customer_metrics

CREATE OR REPLACE TABLE `ecommerce.customer_rfm` AS
WITH rfm_scores AS (
  SELECT
    CustomerID,
    recency_days,
    total_orders,
    total_revenue,

    -- RFM scores (1 = worst, 5 = best)
    -- Recency: lower recency_days is better
    NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,

    -- Frequency: higher total_orders is better
    NTILE(5) OVER (ORDER BY total_orders DESC) AS f_score,

    -- Monetary: higher total_revenue is better
    NTILE(5) OVER (ORDER BY total_revenue DESC) AS m_score

  FROM `ecommerce.customer_metrics`
)
SELECT
  CustomerID,
  recency_days,
  total_orders,
  total_revenue,
  r_score,
  f_score,
  m_score,
  CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS rfm_score,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customers'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Potential Loyalists'
    WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
    ELSE 'Others'
  END AS rfm_segment
FROM rfm_scores;

--------------------------------------------------------------------------------
-- Segment summary (recommended for Tableau / reporting)
--------------------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecommerce.rfm_segment_summary` AS
SELECT
  rfm_segment,
  COUNT(*) AS customers,
  ROUND(SUM(total_revenue), 2) AS revenue,
  ROUND(AVG(total_revenue), 2) AS avg_ltv,
  ROUND(AVG(total_orders), 2) AS avg_orders,
  ROUND(AVG(recency_days), 1) AS avg_recency_days
FROM `ecommerce.customer_rfm`
GROUP BY rfm_segment
ORDER BY revenue DESC;

-- Optional validation queries (run separately)

-- Row count (should match number of customers in customer_metrics)
-- SELECT COUNT(*) AS customers
-- FROM `ecommerce.customer_rfm`;

-- Segment distribution and revenue contribution
-- SELECT
--   rfm_segment,
--   COUNT(*) AS customers,
--   ROUND(SUM(total_revenue), 2) AS revenue
-- FROM `ecommerce.customer_rfm`
-- GROUP BY rfm_segment
-- ORDER BY revenue DESC;
