# E-commerce Customer Revenue Analysis

## Project Overview
This project analyzes historical e-commerce transaction data to identify the **key drivers of revenue growth** in an online retail business.

The analysis follows a **fully reproducible, SQL-first pipeline in BigQuery**, ending with a **BI-ready monthly KPI table** connected directly to **Tableau** for executive reporting.

During development, the project was intentionally **rebuilt from raw transactional data** after identifying conceptual and data consistency issues in an earlier approach.  
The original README and SQL scripts are preserved under the `/old` folder for full traceability.

---

## Business Context (Hypothetical)
The stakeholder is a **Head of E-commerce / General Manager** of a UK-based online retailer.

The objective is to understand **what factors drove revenue performance in 2011** in order to inform strategic priorities for the following year.

---

## Business Question (SMART)
**Between January and November 2011, is revenue growth primarily driven by:**
- an increase in **active customers**,
- a higher number of **orders**, or
- higher **customer or order value** (AOV / ARPU)?

**Specific:** Revenue drivers  
**Measurable:** Revenue, customers, orders, AOV, ARPU  
**Actionable:** Strategic prioritization  
**Relevant:** Business growth  
**Time-bound:** Jan–Nov 2011

---

## Scope & Timeframe
- **Dataset availability:** 2010–2011 (includes December 2011)
- **Analysis period:** January–November 2011
- **December 2011 explicitly excluded**

**Reason for exclusion:**  
December 2011 is a **partial month** in the dataset and shows **abnormally high return behavior**, which would bias monthly KPI comparisons (particularly return-related metrics).

All SQL logic and Tableau visualizations **strictly reflect Jan–Nov 2011 only**.

---

## North Star Metric
### Net Revenue

**Definition:**  
Net Revenue represents the true economic outcome of transactions and **includes the impact of product returns**.
Net Revenue = Gross Revenue − Returns Value

Net Revenue is treated as the **single North Star metric** across all layers (SQL and BI).

---

## Why the Project Was Rebuilt

### Issues Identified During Early Validation
Initial exploratory analysis and sanity checks revealed multiple inconsistencies:
- Revenue magnitudes off by a factor of ~100
- Returns excluded from cleaned datasets
- BI-level corrections masking upstream data issues

### Root Cause
The original pipeline filtered out negative quantities (`Quantity < 0`), effectively analyzing **gross revenue only**, while KPIs were interpreted as **net revenue**.

### Decision
The pipeline was rebuilt from raw transactional data to:
- Preserve returns correctly
- Redefine KPIs with full transparency
- Enforce a **single source of truth** across SQL and BI

The original approach remains available under `/old` for traceability.

---

## Data Pipeline Architecture

### Source
- `online_retail_raw` — original dataset ingestion  
  (dataset reference documented in `docs/data_source.md`)

### Working Raw Copy
- `ecommerce_raw_00`  
  Created via `sql/00_setup/00_create_raw_working_copy.sql`

### Clean Layer
- `ecommerce_clean_01_transactions`
- `ecommerce_clean_02_orders`
- `ecommerce_clean_03_customers_monthly`  

(SQL scripts under `sql/01_clean/`)

### BI Layer
- `ecommerce_bi_01_kpis_monthly`  

(SQL script under `sql/02_bi/04_kpis_monthly.sql`)

This table contains **one row per month (monthly aggregation)** and serves as the **only data source for Tableau**.

---

## Final KPI Definitions (BI Layer)

### Gross Revenue
Sum of `(Quantity × UnitPrice)` for `Quantity > 0`

### Returns Value
Total value of returns:
- Sum of `(Quantity × UnitPrice)` where `Quantity < 0`
- Represented as an **absolute (positive) value**

### Net Revenue (North Star)
Net Revenue = Gross Revenue − Returns Value

### Orders
Number of **unique invoices** with at least one purchase line (`Quantity > 0`)  
(Return credit notes are excluded)

### Active Customers
Number of **unique customers** with at least one purchase (`Quantity > 0`) in the month

### Return Rate (Value)
Return Rate = Returns Value / Gross Revenue

**Interpretation:**  
“What percentage of sold value was returned?”

### AOV and ARPU
AOV and ARPU are calculated **at the monthly level in SQL** and treated as **final KPIs** in Tableau.  
No ratio recalculation is performed at the BI layer.

---

## Data Validation & Quality Checks
Validation scripts are stored under `sql/03_validation/` and include:
- Presence of returns in raw data
- Gross vs Net revenue reconciliation
- Monthly return impact analysis
- Invoice-level outlier inspection (January 2011)

Cross-validation confirms:
- Net revenue is consistent across transaction, order, and BI layers
- All KPIs are mathematically and conceptually aligned
- No BI-level calculations are used to mask upstream issues

---

## Tableau Validation & BI Decisions

Before building dashboards, KPIs were **validated individually** in Tableau at a monthly level:
- Gross Revenue
- Net Revenue
- Returns Value
- Return Rate Value

This validation confirmed:
- Returns must be represented as **positive values**
- Return Rate must use **Gross Revenue** as the denominator
- Orders and Active Customers must reflect **purchases only**

All corrections were applied **in SQL**, reinforcing the principle of **fixing logic upstream**.

---

## Visualization
The table `ecommerce_bi_01_kpis_monthly` is connected directly to BigQuery and visualized in **Tableau Web**.

All visualizations are **monthly time series** aligned to the same temporal scope (Jan–Nov 2011).

### Executive Dashboard
**Revenue Drivers – 2011 (Jan–Nov)**

Structure:
- **Top:** Net Revenue (North Star)
- **Bottom:** Revenue drivers
  - Active Customers
  - Orders
  - AOV
  - ARPU

A small insights panel summarizes key findings without overloading the visuals.

Dashboard screenshots are stored under `/dashboards`.

---

## Key Insights (Jan–Nov 2011)
- Net Revenue accelerates strongly in **September–November**
- Growth aligns with rising **Active Customers** and **Orders** (volume-led)
- **AOV and ARPU remain relatively stable**, indicating value-based drivers are secondary

### Executive Conclusion
**Revenue growth in 2011 (Jan–Nov) is primarily driven by increased customer and order volume, while value-based metrics (AOV and ARPU) remain relatively stable.**
<img width="893" height="716" alt="image" src="https://github.com/user-attachments/assets/784eb3e5-fcd6-464f-a1c9-f6d2734e7519" />

In simple terms:  
**Growth came more from volume than from value.**

---

## Assumptions & Limitations

### Currency
The dataset does not explicitly specify transaction currency.  
Based on dataset origin and sanity checks, values are treated as **GBP**.  
No currency symbol is shown in the dashboard to avoid introducing unverified assumptions.

### Data Limitations
- No product cost data → profitability analysis out of scope
- No customer demographics beyond `CustomerID`
- December 2011 excluded due to incomplete data

---

## Use of AI Assistance
AI tools were used to support:
- SQL drafting and refactoring
- Validation logic and sanity checks
- Documentation structure and clarity

All analytical decisions, assumptions, and interpretations were made by the author.  
AI tools were used strictly as a **productivity and reasoning aid**, not as a substitute for analytical judgment.

---

## Repository Structure
```text
dashboards/
docs/
old/
sql/

---

Potential Future Analyses

Cohort-based customer retention analysis

RFM segmentation for customer value profiling

Product-level revenue and return drivers

Country-level performance analysis

Profitability analysis if cost data becomes available
