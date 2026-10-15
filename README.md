# Mortgage Delinquency Roll-Rate & Collections Prioritization

## Project Overview

This project analyzes mortgage loan performance data to understand what happens after a mortgage becomes delinquent and to support data-driven collections prioritization.

The main business question is:

> **Among mortgages that have recently become delinquent, which loans are more likely to recover and which are more likely to remain delinquent or deteriorate further?**

The analysis uses historical mortgage performance data from Fannie Mae's Single-Family Loan Performance Dataset.

The project combines SQL, Python, statistical analysis, logistic regression, and Power BI to move from raw loan-level data to an interpretable collections-prioritization framework.

---

## Business Problem

Mortgage servicing teams have limited time and resources when managing delinquent loans. Not every delinquent mortgage has the same likelihood of recovery or the same level of financial exposure.

A useful analytical approach is to identify characteristics associated with different delinquency outcomes and use those patterns to help prioritize collections attention.

This project therefore focuses on three questions:

1. What characteristics are associated with mortgage delinquency and recovery?
2. Which newly delinquent mortgages show a higher observed likelihood of recovering versus deteriorating?
3. Does the resulting prioritization behave consistently across geographic areas?

The objective is **not** to automatically make servicing decisions. The analysis is intended to provide an evidence-based prioritization framework that can support human decision-making.

---

## Dataset

The project uses the:

**Fannie Mae Single-Family Loan Performance Dataset**

The dataset contains loan-level monthly performance information for mortgages, including variables related to:

- Loan characteristics
- Interest rates
- Original and current unpaid principal balance
- Loan age
- Loan-to-value ratio
- Debt-to-income ratio
- Borrower credit score
- Occupancy status
- Property location
- Loan purpose
- Mortgage product
- Delinquency status
- Modification status
- Zero-balance information

The original performance files are very large, so the project uses a filtered subset of the fields required for the analysis.

### Selected variables

The Python data-processing workflow retains the following fields:

- `LOAN_ID`
- `ACT_PERIOD`
- `CURR_RATE`
- `ORIG_UPB`
- `CURRENT_UPB`
- `LOAN_AGE`
- `OLTV`
- `DTI`
- `CSCORE_B`
- `PURPOSE`
- `OCC_STAT`
- `STATE`
- `MSA`
- `ZIP`
- `PRODUCT`
- `DLQ_STATUS`
- `MOD_FLAG`
- `Zero_Bal_Code`

---

## Analytical Approach

The project follows this workflow:

```text
Fannie Mae Loan Performance Data
                ↓
        Data Extraction
                ↓
        SQL Data Analysis
                ↓
       Python / Pandas Cleaning
                ↓
        Exploratory Analysis
                ↓
       Statistical Analysis
                ↓
       Logistic Regression
                ↓
   Collections Prioritization
                ↓
     Geographic Comparison
                ↓
          Power BI
