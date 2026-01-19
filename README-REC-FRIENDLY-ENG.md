# Revenue Drivers Analysis – E-commerce (2011)

## Project Summary

This project analyzes historical e-commerce transaction data to understand **what drove revenue growth** in an online retail business.

Using a **SQL-first, reproducible pipeline in BigQuery**, I built a **monthly KPI dataset** and an **executive-level Tableau dashboard** to identify whether growth was driven by:

* more customers,
* more orders, or
* higher value per customer/order.

---

## Business Problem

**Stakeholder:** Head of E-commerce / General Manager
**Question:**

> Between January and November 2011, was revenue growth driven primarily by volume (customers/orders) or by value (AOV/ARPU)?

This insight is critical for deciding whether future growth should focus on **acquisition, frequency, or pricing/value strategies**.

---

## Approach

1. **Rebuilt the data pipeline from raw transactions** after identifying inconsistencies in an initial version (returns handling and revenue definition).
2. Defined a **single source of truth** for KPIs in SQL:

   * Net Revenue (North Star)
   * Active Customers
   * Orders
   * AOV / ARPU
   * Return Rate
3. Aggregated KPIs at a **monthly level** to ensure consistent comparisons.
4. Connected the BI table directly to **Tableau**, keeping all business logic in SQL.
5. Designed a **clean executive dashboard** with a clear hierarchy:

   * Net Revenue on top
   * Key drivers below

December 2011 was excluded due to partial data and anomalous return behavior.

---

## Key Decisions

* **Net Revenue** chosen as the North Star metric (includes returns).
* **Returns handled explicitly** (negative quantities converted to positive return value for BI).
* **Orders and Active Customers** count purchases only (returns excluded).
* No currency symbol shown in the dashboard, as the dataset does not explicitly specify currency.

All decisions are documented and reproducible.

---

## Key Insights (Jan–Nov 2011)

* **Net Revenue accelerates strongly in Sep–Nov.**
* Growth closely aligns with increases in **Active Customers** and **Orders**.
* **AOV and ARPU remain relatively stable**, showing no sustained upward trend.

### Executive Conclusion

**Revenue growth in 2011 was primarily driven by increased customer and order volume rather than higher value per order or per customer.**

In short:
**Growth came more from volume than from value.**

---

## Deliverables

* SQL-based data pipeline in BigQuery
* Monthly BI KPI table
* Tableau dashboard: **“Revenue Drivers – 2011 (Jan–Nov)”**
* Technical README + recruiter-friendly summary

---

## Tools & Skills

* **SQL (BigQuery)** – data cleaning, aggregation, KPI design
* **Tableau** – executive dashboards & data storytelling
* **Data validation & QA** – sanity checks, metric consistency
* **Business analysis** – translating data into decisions

---

## Next Steps

* Cohort-based retention analysis
* RFM segmentation
* Product- and country-level revenue drivers
* Profitability analysis if cost data becomes available
