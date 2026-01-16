# Ecommerce Customer Revenue Analysis (Work in Progress)
End-to-end e-commerce customer, cohort, segmentation, and revenue analysis using SQL (Google BigQuery) and Tableau Public.

## Project Status
This repository is **Work in Progress**.  
The BigQuery analytical pipeline (Steps 01–06) is implemented and reproducible. The Tableau layer is in progress: the **Executive Overview (2011)** dashboard is built (first version), and the next deliverables are the cohort retention heatmap, RFM/revenue concentration views, and the final executive narrative (insights + recommendations).

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
- **Source:** Online Retail Dataset (Kaggle)  
- **Size:** ~542k transaction records

**Key fields:**
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
```text
ecommerce-customer-revenue-analysis/
├── sql/
│   ├── 01_data_exploration.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_customer_metrics.sql
│   ├── 04_cohort_analysis.sql
│   ├── 05_rfm_segmentation.sql
│   ├── 06_revenue_ltv.sql
├── dashboards/
│   └── tableau_link.md
└── README.md

## Data Model (BigQuery Tables)

### Core Tables

- `ecommerce.online_retail_raw`  
  Raw ingestion layer (no transformations).

- `ecommerce.online_retail_clean`  
  Clean analytical layer after applying business rules (no null CustomerID, no returns, no invalid prices).

- `ecommerce.customer_metrics`  
  One row per customer with engineered metrics (recency, frequency, monetary/LTV proxy, AOV, lifespan).

- `ecommerce.cohort_analysis`  
  Cohort activity table by `cohort_month` and `months_since_first_purchase` (active customers + revenue).

- `ecommerce.customer_rfm`  
  Customer-level RFM scores (quintiles) and segment labels.

- `ecommerce.rfm_segment_summary`  
  Segment-level KPI summary for reporting (customers, revenue, avg LTV, avg orders, avg recency).

### Step 06 (BI-ready Tables)

- `ecommerce.monthly_revenue_kpis`  
  Monthly KPIs (Revenue, Orders, Active Customers, AOV, ARPU).

- `ecommerce.customer_value_tiers`  
  Customer value tiers (Top 1/5/20% and wholesale-like flags).

- `ecommerce.revenue_pareto`  
  Revenue concentration (cumulative revenue share vs customers).

- `ecommerce.rfm_segment_kpis`  
  RFM segment KPIs and revenue share.

- `ecommerce.cohort_revenue_summary`  
  Cohort size and revenue-per-customer summary.

---

## Workflow and Methodology

### 1) Data Ingestion (Raw Layer)
The dataset was converted from Excel to CSV and loaded into BigQuery as:
- `ecommerce.online_retail_raw`

Raw data is preserved without modification to maintain lineage and reproducibility.

### 2) Data Exploration (`01_data_exploration.sql`)
Profiling to understand data quality and suitability for customer analytics.

**Key findings:**
- Total rows: 541,909
- Missing CustomerID: 135,080 rows (~25%)
- Invalid Quantity or UnitPrice (≤ 0): 10,624 rows (~2%)

**Implications:**
- Rows without CustomerID cannot be used for customer-level metrics.
- Negative quantities represent returns and distort revenue if not handled.
- Non-positive prices distort revenue calculations.

### 3) Data Cleaning (`02_data_cleaning.sql`)
Creation of a clean analytical table:

**Output:** `ecommerce.online_retail_clean`

**Rules applied:**
- Exclude rows with `CustomerID IS NULL`
- Remove returns: `Quantity <= 0`
- Remove invalid pricing: `UnitPrice <= 0`
- Create `Revenue = Quantity * UnitPrice`
- Use `SAFE_CAST` to prevent query failures

**Results after cleaning:**
- Clean rows: 397,884
- Unique customers: 4,338
- Total revenue (historical, cleaned): £820,333,393

### 4) Customer Metrics / Feature Engineering (`03_customer_metrics.sql`)
Creation of customer-level features for downstream analysis:

**Output:** `ecommerce.customer_metrics`

**Metrics per customer:**
- Customer lifespan (days between first and last purchase)
- Recency (days since last purchase, relative to dataset end date)
- Total number of orders
- Total revenue (historical LTV proxy)
- Average order value

**Aggregate checks:**
- Customers: 4,338
- Average historical LTV proxy: £189,104
- Average orders per customer: 4.27

### 5) Cohort Analysis (`04_cohort_analysis.sql`)
Cohorts are defined by the customer's first purchase month (`cohort_month`), then tracked over time using `months_since_first_purchase`.

**Output:** `ecommerce.cohort_analysis`

**Metrics by cohort and month offset:**
- Active customers
- Total revenue

**Validation highlights:**
- Cohorts span Dec 2010 through Dec 2011.
- The acquisition peak occurs in Dec 2010 (largest cohort size).
- The final cohort is smaller because the dataset ends early in Dec 2011.

### 6) RFM Segmentation (`05_rfm_segmentation.sql`)
Customers are scored into quintiles using `NTILE(5)`:
- Recency (lower is better)
- Frequency (higher is better)
- Monetary (higher is better)

**Output:** `ecommerce.customer_rfm`

A segment-level summary table is also created:
- `ecommerce.rfm_segment_summary` (BI reporting support)

### 7) Revenue & LTV Analysis (`06_revenue_ltv.sql`)
This step creates business-ready tables used for BI and reporting:
- Monthly revenue KPIs (revenue, orders, AOV, ARPU)
- Customer value tiers (Top 1/5/20% customers and wholesale-like flag)
- Revenue concentration (Pareto / cumulative revenue share)
- RFM segment KPIs (revenue share, avg LTV, avg orders, avg recency)
- Cohort revenue summary (cohort size and revenue per customer)

---

## Tableau Dashboard Progress (Work in Progress)

### Executive Overview 2011 (Jan–Nov)

**Current deliverable:**
- A one-page executive dashboard summarizing monthly trends and top-level KPIs:
  - Total Revenue (Jan–Nov)
  - Total Orders (Jan–Nov)
  - Avg Monthly Active Customers
  - AOV (Global)
  - Monthly trends: Revenue, Orders, Active Customers, AOV, ARPU

**Important data note:**
- **Dec-2011 is excluded** from monthly trends and KPIs because it is a **partial month** (dataset ends early in Dec 2011).

Add the published Tableau link to:
- `dashboards/tableau_link.md`

---

## Challenges Encountered and Resolutions

### 1) BigQuery → Tableau connectivity issues (Live connection)
**Problem:** Tableau (web) returned intermittent errors (e.g., upstream connect error / disconnect before headers).  
**Resolution:** Switched to a more stable workflow:
- Exported BI-ready tables (Step 06) to CSV
- Used Tableau extracts / text-file connections instead of BigQuery live

**What I learned:** Live BI connections can fail for reasons unrelated to the SQL logic (network/auth/service). Having an export/extract fallback is a realistic production skill.

### 2) Metric scaling inconsistencies (currency magnitude)
**Problem:** Some measures appeared off by ~100x due to how values were interpreted after export and aggregation (and differences between "raw" vs "formatted" measures).  
**Resolution:** Defined explicit scaled measures in Tableau (e.g., using `/ 100` where required) and validated outputs against BigQuery results until totals matched expected magnitudes.

**What I learned:** Always validate BI layer numbers against the warehouse (BigQuery) and document any scaling assumptions. Do not rely on formatting to "fix" wrong magnitudes.

### 3) Tableau aggregation limitations with calculated fields (AGG / FIXED)
**Problem:** Some calculated fields returned `AGG(...)` and could not be re-aggregated as SUM in Tableau, leading to confusing behavior.  
**Resolution:** Created clean numeric measures designed for chart-level aggregation (e.g., `Revenue00`) and used `SUM(Revenue00)` for trends, keeping FIXED/LOD calcs only for true global KPIs.

**What I learned:** Separate "row-level measures for trends" from "LOD/global KPIs". It prevents aggregation conflicts and makes dashboards more maintainable.

### 4) Partial month distortion (Dec-2011)
**Problem:** Dec-2011 drops sharply and distorts trends because the dataset ends early in the month.  
**Resolution:** Excluded Dec-2011 from all monthly charts and KPIs and added a dashboard note:
- "Dec-2011 excluded (partial month)"

**What I learned:** Time-series dashboards need calendar completeness checks (partial months/weeks can break interpretation).

### 5) KPI display issues (####### in Tableau)
**Problem:** KPI text showed `#######` due to insufficient space or number formatting.  
**Resolution:** Adjusted KPI container width and standardized number formatting (currency, no decimals).

**What I learned:** Dashboard UX matters: formatting and layout can break readability even when data is correct.

### 6) KPI definition clarity (Active Customers)
**Problem:** "Active Customers" can mean total unique customers over the period OR average monthly active customers.  
**Resolution:** Chose and labeled explicitly:
- KPI shows **Avg Monthly Active Customers**
- The monthly chart shows **Active Customers per month**

**What I learned:** KPI definitions must be explicit (metric name + time scope + aggregation rule).

---

## How to Reproduce

### BigQuery
1. Load the raw dataset into BigQuery as `ecommerce.online_retail_raw`.
2. Execute SQL scripts in order:
   - `sql/01_data_exploration.sql`
   - `sql/02_data_cleaning.sql`
   - `sql/03_customer_metrics.sql`
   - `sql/04_cohort_analysis.sql`
   - `sql/05_rfm_segmentation.sql`
   - `sql/06_revenue_ltv.sql`

### Tableau
1. Export Step 06 BI-ready tables (CSV) or connect via BigQuery (live, if stable).
2. Build dashboards using:
   - `monthly_revenue_kpis` (Executive Overview)
   - `cohort_retention` / `cohort_analysis` (Retention heatmap)
   - `rfm_segment_kpis` / `rfm_segment_summary` (Segmentation performance)
   - `revenue_pareto` (Revenue concentration)

---

## Next Deliverables
- Publish Tableau Public dashboard(s) and add link:
  - `dashboards/tableau_link.md`
- Build remaining dashboards:
  - Cohort retention heatmap
  - RFM segments performance
  - Revenue Pareto / concentration curve
- Write final executive narrative:
  - Key insights
  - Risks/opportunities
  - Retention/reactivation recommendations

