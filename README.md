# E-commerce Customer Revenue Analysis

## Project Overview
This project analyzes historical e-commerce transaction data to understand **what drives revenue growth** in an online retail business.

The analysis follows a **fully reproducible SQL-based pipeline in BigQuery**, ending with a BI-ready dataset connected directly to Tableau for executive reporting.

During development, the project was **intentionally restarted from scratch** after identifying data consistency issues. The full reasoning behind this decision and its implications are documented below.  
The original README and SQL scripts remain available in the `/old` folder for reference.

---

## Business Context (Hypothetical)
The stakeholder is a **Head of E-commerce / General Manager** of a UK-based online retailer.

The goal is to understand **what factors drove revenue performance in 2011** in order to inform strategic decisions for the following year.

---

## Business Question (SMART)
> **Between January and November 2011, is revenue growth primarily driven by an increase in active customers, a higher number of orders, or higher customer/order value (AOV / ARPU)?**

- **Specific:** Revenue drivers  
- **Measurable:** Revenue, customers, orders, AOV, ARPU  
- **Actionable:** Strategic prioritization  
- **Relevant:** Business growth  
- **Time-bound:** Jan–Nov 2011  

---

## Scope & Timeframe
- Dataset availability: **2010–2011 (includes December 2011)**
- **Analysis period:** January–November 2011  
- **December 2011 excluded** because it is a **partial month** in the dataset and would bias monthly KPI comparisons.

---

## North Star Metric
**Net Revenue**

Defined as total transaction revenue **including the impact of product returns**, reflecting the true economic outcome.

---

## Why the Project Was Restarted

### Issues identified during early validation
During early validation and exploratory analysis, multiple **sanity checks revealed inconsistencies**, including:
- Revenue magnitudes off by a factor of ~100
- Returns being excluded in cleaned datasets
- BI-level corrections masking upstream data issues

### Root cause
The original pipeline removed negative quantities (`Quantity < 0`), effectively analyzing **gross revenue** while KPIs were interpreted as **net revenue**.

### Decision
The pipeline was **rebuilt starting from the raw dataset** to:
- Preserve returns correctly
- Redefine KPIs with full transparency
- Ensure a **single source of truth** across SQL and BI

> The original approach and scripts are preserved under `/old` for traceability.

---

## Data Pipeline

### Source
- `online_retail_raw` — original dataset ingestion  
  (dataset reference and link documented in `docs/data_source.md`)

### Working Raw Copy
- `ecommerce_raw_00`  
  Created via `sql/00_setup/00_create_raw_working_copy.sql`

### Clean Layer
- `ecommerce_clean_01_transactions`  
- `ecommerce_clean_02_orders`  
- `ecommerce_clean_03_customers_monthly`  

(SQL scripts in `sql/01_clean/`)

### BI Layer
- `ecommerce_bi_01_kpis_monthly`  

(SQL script in `sql/02_bi/`)

---

## KPI Definitions (Summary)
- **Net Revenue:** Gross sales minus returns  
- **Orders:** Count of unique invoices  
- **Active Customers:** Customers with ≥1 order in the month  
- **AOV:** Net Revenue / Orders  
- **ARPU:** Net Revenue / Active Customers  
- **Return Rate (Value):** Returns value / Gross revenue  

---

## Data Validation
Validation scripts are stored under `sql/03_validation/` and include:
- Returns presence checks in raw data
- Gross vs Net revenue reconciliation
- Monthly return impact analysis
- Invoice-level outlier inspection (January 2011)

Cross-validation confirms that:
- Net revenue at order level matches net revenue at BI level
- All KPIs are consistent across layers

---

## Assumptions & Limitations

### Currency
The dataset does not explicitly specify transaction currency.  
Based on dataset origin (UK-based retailer), unit price distributions, and revenue magnitude sanity checks, monetary values are treated as **GBP**.

### Monetary Scale
Revenue values were stored in **minor units (×100)** and standardized in the BI layer.

### Data Limitations
- No product cost data → margin/profit analysis out of scope  
- No customer demographic attributes beyond CustomerID  
- December 2011 excluded due to incomplete data  

---

## Visualization
The BI table `ecommerce_bi_01_kpis_monthly` is connected **directly to BigQuery** and visualized in Tableau.

Dashboard workbooks and screenshots are stored under `dashboards/`.

---

## Use of AI Assistance
Parts of this project were developed with the assistance of AI tools to support:
- SQL code drafting and refactoring
- Validation logic and sanity checks
- Documentation structure and clarity

All analytical decisions, assumptions, and interpretations were made by the author.  
AI tools were used as a productivity and reasoning aid, not as a substitute for analytical judgment.

---

## Repository Structure
```text
dashboards/
docs/
old/
sql/

---

## Next Steps
- Cohort-based retention analysis  
- RFM segmentation  
- Product- and country-level revenue drivers  
- Profitability analysis if cost data becomes available  
