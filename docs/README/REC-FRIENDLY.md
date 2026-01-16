# E-commerce Customer Revenue Analysis

## Overview
End-to-end data analysis project focused on understanding **what drives revenue growth** in an e-commerce business.

Using transactional data from a UK-based online retailer, the project builds a **reproducible SQL pipeline in BigQuery** and delivers a **BI-ready dataset connected to Tableau** for executive reporting.

---

## Business Question
**What drove revenue growth between January and November 2011?**
- More active customers?
- More orders?
- Higher value per customer or per order (AOV / ARPU)?

---

## Approach
- Rebuilt the analysis **from raw data** after identifying data consistency issues
- Preserved **product returns** to correctly measure **net revenue**
- Standardized monetary values and validated KPIs across multiple layers
- Designed a clean **SQL → BI pipeline** ready for Tableau consumption

---

## Data Pipeline
- **Raw:** `ecommerce_raw_00`
- **Clean:** transactions, orders, customer-month tables
- **BI:** monthly KPIs table (`ecommerce_bi_01_kpis_monthly`)
- **Validation:** reconciliation and sanity checks at each step

---

## Key Metrics
- Net Revenue (North Star)
- Orders
- Active Customers
- AOV & ARPU
- Return Rate (value-based)

---

## Tools
- SQL (BigQuery)
- Tableau
- GitHub
- AI-assisted workflow (used for code drafting and validation support)

---

## Data Source
Public *Online Retail Dataset* from Kaggle  
(Reference and link available in `docs/data_source.md`)

---

## Notes
- Currency assumed to be GBP (not explicitly specified in the dataset)
- Revenue values standardized from minor units
- December 2011 excluded due to incomplete data

---

## Next Steps
- Cohort-based retention analysis
- RFM segmentation
- Product- and country-level revenue drivers
- Profitability analysis if cost data becomes available
