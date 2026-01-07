# ecommerce-customer-revenue-analysis
End-to-end e-commerce customer, cohort, and revenue analysis using SQL (BigQuery) and Tableau.
----------------------------

# E-commerce Customer & Revenue Analysis

This project analyzes customer behavior, retention, segmentation, and revenue performance for an e-commerce business using SQL (BigQuery) and Tableau Public.

Work in progress.

---------------------------
# 🛒 E-commerce Customer Analysis  
**SQL · BigQuery · Data Cleaning · Customer Analytics**

## 📌 Project Overview

This project focuses on analyzing customer purchase behavior using a real-world **e-commerce transaction dataset**.  
The goal is to move from raw transactional data to a **clean, analysis-ready customer dataset**, following a realistic workflow commonly used in data teams.

The analysis is performed entirely in **Google BigQuery (SQL)**, emphasizing data cleaning, feature engineering, and business-driven decision making.

---

## 🎯 Business Objectives

- Understand the structure and quality of raw transactional data
- Prepare a clean dataset suitable for customer-level analysis
- Build key customer metrics such as:
  - total revenue
  - order frequency
  - customer lifespan
  - recency
- Lay the foundation for advanced analyses such as:
  - RFM segmentation
  - cohort analysis
  - customer lifetime value (LTV)

---

## 🗂 Dataset Description

**Source:** Online Retail Dataset (Kaggle)  
**Size:** ~542k transaction records

### Main columns:
- `InvoiceNo` – Transaction identifier  
- `StockCode` – Product code  
- `Description` – Product description  
- `Quantity` – Number of units purchased  
- `InvoiceDate` – Transaction date and time  
- `UnitPrice` – Price per unit  
- `CustomerID` – Customer identifier  
- `Country` – Customer country  

The dataset contains missing values, negative quantities (returns), and other inconsistencies typical of real production data.

---

## 🛠️ Tech Stack

- **SQL (Standard SQL)**
- **Google BigQuery**
- **GitHub** (project documentation & versioning)

---

## 📁 Project Structure

ecommerce-customer-analysis/
│
├── sql/
│ ├── 01_data_exploration.sql
│ ├── 02_data_cleaning.sql
│ └── 03_feature_engineering.sql
│
└── README.md


---

## 🔄 Workflow & Methodology

### 1️⃣ Data Ingestion (Raw Layer)

- The dataset was converted from Excel to CSV and loaded into **BigQuery** as  
  `ecommerce.online_retail_raw`
- Schema was **auto-detected** to reflect a realistic ingestion process
- Raw data was preserved without modifications

---

### 2️⃣ Data Exploration (`01_data_exploration.sql`)

Initial checks were performed to understand data quality and limitations.

**Key findings:**
- **Total rows:** 541,909  
- **Customers with missing CustomerID:** 135,080 (~25%)  
- **Rows with invalid Quantity or UnitPrice:** 10,624 (~2%)

**Key observations:**
- Transactions without `CustomerID` cannot be used for customer-level analysis
- Negative quantities represent returns
- Zero or negative prices distort revenue metrics

---

### 3️⃣ Data Cleaning (`02_data_cleaning.sql`)

A clean analytical table was created:  
`ecommerce.online_retail_clean`

**Cleaning rules applied:**
- Excluded rows with `CustomerID IS NULL`
- Removed returns (`Quantity <= 0`)
- Removed invalid pricing (`UnitPrice <= 0`)
- Casted numeric fields safely using `SAFE_CAST`
- Created a business metric: `Revenue = Quantity * UnitPrice`

**Results after cleaning:**
- **Clean rows:** 397,884  
- **Unique customers:** 4,338  
- **Total revenue:** £820,333,393  

---

### 4️⃣ Feature Engineering (`03_feature_engineering.sql`)

Customer-level metrics were created in the table:  
`ecommerce.customer_metrics`

**Metrics engineered per customer:**
- Customer lifespan (days)
- Recency (days since last purchase)
- Total number of orders
- Total revenue (LTV proxy)
- Average order value

**Aggregated results:**
- **Customers:** 4,338  
- **Average LTV (historical):** £189,104  
- **Average orders per customer:** 4.27  

---

## 🧠 Key Analytical Decisions

- Raw data was not modified directly; all transformations were applied to derived tables
- Customers without identification were excluded only at the analysis stage
- Returns were excluded to avoid distorting revenue-based metrics
- LTV is treated as a historical proxy, not a predictive model

---

## ⚠️ Challenges Encountered

- BigQuery ingestion errors due to malformed CSV rows
- Inconsistent date formats and quoted newlines in product descriptions
- Schema mismatches during auto-detection

**Solutions applied:**
- Enabled CSV error tolerance and quoted newline handling
- Accepted auto-detected schema and corrected types during cleaning
- Used `SAFE_CAST` to prevent query failures

---

## 🚀 Next Steps

- RFM segmentation
- Cohort analysis by first purchase month
- Revenue concentration analysis
- Interactive BI dashboard

---

## 📌 Final Notes

This project was designed to simulate a **real-world e-commerce analytics task**, focusing on:
- realistic data quality issues
- business-driven cleaning decisions
- scalable SQL workflows
- clear documentation and reproducibility
