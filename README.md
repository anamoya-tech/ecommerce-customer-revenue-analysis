# Ecommerce Customer Revenue Analysis (Work in Progress)

End-to-end e-commerce customer, cohort, segmentation, and revenue analysis using SQL (Google BigQuery) and Tableau Public.

## Project Status
This repository is **Work in Progress**. The BigQuery analytical pipeline (Steps 01–06) is implemented and reproducible. The next deliverables are the Tableau Public dashboard and a final executive narrative (insights + recommendations).

## Overview
This project follows a realistic analytics workflow commonly used in data teams: ingesting raw transactional data, profiling data quality, creating a clean analytical layer, engineering customer features, and generating business-ready tables for segmentation (RFM), retention (cohorts), and revenue/LTV analysis.

All transformations are performed in BigQuery using Standard SQL. The repository is structured so the analysis is reproducible and easy to review.

## Business Objectives
- Assess the structure and quality of raw transactional data.
- Produce a clean dataset suitable for customer-level analytics.
- Build customer metrics to support decision-making:
  - Recency, purchase frequency, historical revenue (LTV proxy), average order value.
- Evaluate retention and revenue performance over time through cohort analysis.
- Segment customers using an RFM framework for CRM/retention targeting.
- Quantify revenue concentration and customer value tiers.
- Provide BI-ready tables for Tableau dashboards.

## Dataset
- Source: Online Retail Dataset (Kaggle)
- Size: ~542k transaction records
- Key fields:
  - `InvoiceNo` (transaction identifier)
  - `StockCode`, `Description` (product info)
  - `Quantity` (units; includes returns)
  - `InvoiceDate` (timestamp)
  - `UnitPrice`
  - `CustomerID` (customer identifier; missing in a substantial portion of rows)
  - `Country`

The dataset contains missing values, returns (negative quantities), and inconsistent formatting typical of production-like data.

## Tech Stack
- SQL (BigQuery Standard SQL)
- Google BigQuery (storage + compute)
- Tableau Public (visualization)
- GitHub (versioning + documentation)

## Repository Structure

ecommerce-customer-revenue-analysis/
├── sql/
│ ├── 01_data_exploration.sql
│ ├── 02_data_cleaning.sql
│ ├── 03_customer_metrics.sql
│ ├── 04_cohort_analysis.sql
│ ├── 05_rfm_segmentation.sql
│ ├── 06_revenue_ltv.sql
├── dashboards/
│ └── tableau_link.md
└── README.md


## Data Model (BigQuery Tables)
- `ecommerce.online_retail_raw`  
  Raw ingestion layer (no transformations).

- `ecommerce.online_retail_clean`  
  Clean analytical layer after applying business rules.

- `ecommerce.customer_metrics`  
  One row per customer with engineered metrics (recency, frequency, monetary).

- `ecommerce.cohort_analysis`  
  Cohort performance table by acquisition month and months since first purchase (active customers and revenue).

- `ecommerce.customer_rfm`  
  Customer-level RFM scores and segments.

- `ecommerce.rfm_segment_summary`  
  Segment-level KPI summary (customers, revenue, avg LTV, avg orders, avg recency) for reporting/Tableau.

- Step 06 business-ready tables:
  - `ecommerce.monthly_revenue_kpis`
  - `ecommerce.customer_value_tiers`
  - `ecommerce.revenue_pareto`
  - `ecommerce.rfm_segment_kpis`
  - `ecommerce.cohort_revenue_summary`

## Workflow and Methodology

### 1) Data Ingestion (Raw Layer)
- The dataset was converted from Excel to CSV and loaded into BigQuery as:
  - `ecommerce.online_retail_raw`
- Raw data is preserved without modification to maintain lineage and reproducibility.

### 2) Data Exploration (`01_data_exploration.sql`)
Initial profiling to understand data quality and suitability for customer analytics.

Key findings:
- Total rows: 541,909
- Missing `CustomerID`: 135,080 rows (~25%)
- Invalid `Quantity` or `UnitPrice` (≤ 0): 10,624 rows (~2%)

Implications:
- Rows without `CustomerID` cannot be used for customer-level metrics.
- Negative quantities represent returns and distort revenue if not handled.
- Non-positive prices distort revenue calculations.

### 3) Data Cleaning (`02_data_cleaning.sql`)
Creation of a clean analytical table:
- Output: `ecommerce.online_retail_clean`

Rules applied:
- Exclude rows with `CustomerID IS NULL`
- Remove returns: `Quantity <= 0`
- Remove invalid pricing: `UnitPrice <= 0`
- Create `Revenue = Quantity * UnitPrice`
- Use safe casting to prevent query failures

Results after cleaning:
- Clean rows: 397,884
- Unique customers: 4,338
- Total revenue (historical, cleaned): £820,333,393

### 4) Customer Metrics / Feature Engineering (`03_customer_metrics.sql`)
Creation of customer-level features for downstream analysis:
- Output: `ecommerce.customer_metrics`

Metrics per customer:
- Customer lifespan (days between first and last purchase)
- Recency (days since last purchase, relative to dataset end date)
- Total number of orders
- Total revenue (historical LTV proxy)
- Average order value

Aggregate checks:
- Customers: 4,338
- Average historical LTV proxy: £189,104
- Average orders per customer: 4.27

### 5) Cohort Analysis (`04_cohort_analysis.sql`)
Cohorts are defined by the customer's first purchase month (`cohort_month`), then tracked over time using `months_since_first_purchase`.

Output: `ecommerce.cohort_analysis`

Metrics by cohort and month offset:
- Active customers
- Total revenue

Validation highlights:
- Cohorts span Dec 2010 through Dec 2011.
- The acquisition peak occurs in Dec 2010 (largest cohort size).
- The final cohort is smaller because the dataset ends early in Dec 2011.

### 6) RFM Segmentation (`05_rfm_segmentation.sql`)
Customers are scored into quintiles using `NTILE(5)`:
- Recency (lower is better)
- Frequency (higher is better)
- Monetary (higher is better)

Output: `ecommerce.customer_rfm`

In addition to the customer-level segmentation table, a segment-level summary table (`ecommerce.rfm_segment_summary`) is created to support BI reporting and Tableau visualizations.

### 7) Revenue & LTV Analysis (`06_revenue_ltv.sql`)
This step creates business-ready tables used for reporting and BI:
- Monthly revenue KPIs (revenue, orders, AOV, ARPU)
- Customer value tiers (Top 1/5/20% customers and wholesale-like flag)
- Revenue concentration (Pareto / cumulative revenue share)
- RFM segment KPIs (revenue share, avg LTV, avg orders, avg recency)
- Cohort revenue summary (cohort size and revenue per customer)

## Key Analytical Decisions
- Raw data is never modified directly; transformations are applied to derived tables.
- Missing `CustomerID` rows are excluded at the analysis layer to preserve ingestion integrity.
- Returns are excluded from the clean analytical table to avoid distorting revenue-based metrics.
- LTV is treated as a historical proxy (observed revenue), not a predictive model.

## Challenges and Resolutions
- BigQuery ingestion errors caused by malformed CSV rows and quoted newlines in text fields.
- Schema inconsistencies and type inference issues during auto-detection.
- Mitigations:
  - Enabled quoted newline handling and appropriate ingestion tolerance.
  - Used `SAFE_CAST` and staged cleaning to prevent query failures and enforce consistent types.

## How to Reproduce
1. Load the raw dataset into BigQuery as `ecommerce.online_retail_raw`.
2. Execute SQL scripts in order:
   - `01_data_exploration.sql`
   - `02_data_cleaning.sql`
   - `03_customer_metrics.sql`
   - `04_cohort_analysis.sql`
   - `05_rfm_segmentation.sql`
   - `06_revenue_ltv.sql`

## Tableau (Planned)
A Tableau Public dashboard will be connected to the Step 06 tables (monthly KPIs, cohort performance, RFM summary/KPIs, and revenue concentration) to visualize retention, segmentation, and revenue performance.

Add the published Tableau link to:
- `dashboards/tableau_link.md`
- and this README once available.

## Next Deliverables
- Tableau Public dashboard (retention heatmap, revenue trends, RFM segment KPIs, Pareto curve)
- Final executive summary with insights and recommended retention/reactivation actions


