# Mortgage Delinquency Migration & Cure-Risk Analysis

### Fannie Mae Single-Family Loan Performance Data | 2018 Q1 Cohort

## Overview

A mortgage becoming delinquent does not necessarily mean it will end in default. Some borrowers catch up on their payments within a few months, while others remain behind or fall further into delinquency. Understanding these transitions is useful for credit-risk monitoring and loan-servicing decisions.

This project looks at **what happens after a mortgage first becomes delinquent**, with a particular focus on Fannie Mae's **HomeReady** program. The main question is whether HomeReady loans have a different likelihood of returning to current payment status within three months compared with loans that are not classified under a special eligibility program, after accounting for factors such as credit score, loan-to-value ratio (LTV), and debt-to-income ratio (DTI).

The analysis is observational. It aims to identify patterns and associations, not establish that participation in HomeReady causes a particular repayment outcome.

> **Project status:** In progress. Data extraction, SQL Server loading, and initial schema checks are complete. Delinquency episode construction and outcome labeling are next. No final cure-rate or modeling results are reported yet.

## Business Questions

- How often do newly delinquent loans return to current status within three months?
- How do three-month cure rates compare between HomeReady loans and the non-special-eligibility comparison group?
- What share of delinquency episodes remain delinquent, worsen, or exit the observed loan history?
- Are differences between the groups still present after adjusting for borrower and loan characteristics?
- Which characteristics are associated with a higher or lower likelihood of curing?

## Data Source

**Source:** [Fannie Mae Single-Family Loan Performance Data](https://capitalmarkets.fanniemae.com/credit-risk-transfer/single-family-credit-risk-transfer/single-family-loan-performance-data)

The source contains monthly performance records for individual mortgages. A loan can therefore appear in many rows, one for each reporting month. The working dataset uses the **2018 Q1 acquisition cohort**, with monthly records extending through December 2025.

| Item | Working dataset |
| --- | --- |
| Source file | `2018Q1.csv` |
| SQL Server database | `MortgageAnalytics` |
| SQL Server table | `dbo.p1_2018q1` |
| Filtered records | 23,563,399 loan-month rows |
| Selected columns | 22 |
| Reporting periods | January 2018–December 2025 |
| Record grain | One loan per reporting month |

The original pipe-delimited file contains 113 fields. I used Python to retain the 22 fields relevant to the analysis, then loaded the filtered CSV into SQL Server. The dataset is not included in this repository because of its size and the source's applicable terms of use.

### Program identification

The current Fannie Mae file layout identifies field 79 as **Special Eligibility Program**. In the working table, that field retains the earlier column name `HOMEREADY_PROGRAM_INDICATOR`.

| Value | Definition | Use in this analysis |
| --- | --- | --- |
| `H` | HomeReady / Home Possible | HomeReady group |
| `7` | Not Applicable | Primary comparison group |
| `F` | HFA Preferred | Excluded from primary comparison |
| `R`, `O`, `9` | RefiNow, Other, Not Available | Excluded from primary comparison |

The comparison group is described as **loans without an applicable special eligibility program**, rather than assuming every loan is otherwise identical to a HomeReady loan.

## Tools and Technologies

| Tool | Purpose |
| --- | --- |
| SQL Server / T-SQL | Store the monthly loan records, validate data, and inspect loan histories |
| Python, Pandas, NumPy | Prepare delinquency episodes and calculate outcome labels |
| SciPy | Descriptive and statistical comparisons |
| statsmodels | Logistic regression for adjusted cure-risk analysis |
| Power Query, DAX, Power BI | Data modeling, measures, and dashboard development |

## Methodology

### 1. Data preparation and validation

The original CSV was read in chunks to avoid loading the entire file into memory. I selected 22 columns covering loan identifiers, reporting periods, balances, origination characteristics, delinquency status, loan exits, modification status, and special eligibility program classification.

I then imported the filtered data into SQL Server and checked the total row count, sample records, field positions against the Fannie Mae glossary, and duplicate loan-month combinations. An important part of this step was explicitly preserving the output column order after using Pandas `usecols`, so that the CSV aligned with the SQL table schema.

One source-data detail is that **Current Actual UPB can be reported as zero during the early life of a loan because of masking**. It should not automatically be treated as a payoff. The official glossary notes that the value is masked for the first six months of the loan's life.

### 2. Delinquency migration and episode construction — next

I plan to order each loan's monthly records chronologically and identify transitions from current (`DLQ_STATUS = '00'`) to delinquent (`'01'` and above). The primary analysis will use the first qualifying delinquency episode per loan to keep the initial comparison straightforward.

The outcome window will cover the next three calendar months after delinquency begins. Each episode will be evaluated for:

- **Cured:** Returned to `00` within the three-month window.
- **Remained delinquent:** Did not return to current status and remained delinquent during the observed window.
- **Worsened:** Reached a more severe delinquency status during the window.
- **Incomplete or exited:** Missing required follow-up, unknown status, payoff, liquidation, or another exit requiring separate treatment.

These categories need carefully defined rules. In particular, *worsened* can overlap with *remained delinquent*, so the final dataset will keep the binary three-month cure outcome separate from the migration/severity classification. A loan will not automatically be labeled as a non-cure simply because its records stop appearing.

### 3. Statistical analysis — planned

After the episode-level dataset is ready, I will calculate cure rates for each group and examine how they vary by credit score, LTV, DTI, and other relevant characteristics.

A chi-square test will be used for an initial comparison of cure outcomes between groups, subject to the independence assumptions of the episode sample. I will also inspect relationships among numeric predictors before fitting an adjusted logistic regression using `statsmodels`.

The regression will estimate the association between program classification and the probability of curing within three months, while controlling for available loan characteristics. Model evaluation will use a time-aware holdout strategy and safeguards against the same loan leaking between training and test samples.

### 4. Power BI dashboard — planned

The dashboard will be designed around the questions a mortgage servicing or credit-risk analyst would ask:

- Delinquency entry volume and trends
- Three-month cure rates by program group
- Delinquency migration and severity patterns
- Cure rates by borrower and loan segments
- Summary of adjusted model findings, with appropriate caveats

## Current Progress

- [x] Selected the Fannie Mae 2018 Q1 dataset
- [x] Extracted 22 analysis fields from the 113-field source file
- [x] Loaded 23,563,399 loan-month records into SQL Server
- [x] Checked the field mapping against the Fannie Mae glossary
- [x] Checked for duplicate `(LOAN_ID, ACT_PERIOD)` records
- [ ] Finalize delinquency entry and follow-up rules
- [ ] Build the episode-level analysis dataset
- [ ] Calculate cure and migration outcomes
- [ ] Run statistical tests and logistic regression
- [ ] Build the Power BI dashboard
- [ ] Document results, limitations, and business implications

## Important Limitations

This is a single acquisition-quarter cohort, not a representative sample of all mortgages. The HomeReady and comparison groups may differ in ways that are not fully captured by the available fields. Results will therefore be reported as **associations**, not causal effects.

Other considerations include the handling of missing months, unknown delinquency statuses, loan modifications, prepayments and liquidation events, and the choice of observation window. The final analysis will document these decisions and, where practical, test how sensitive the findings are to them.

## Expected Deliverables

1. Reproducible SQL and Python scripts for preparing the data and defining delinquency episodes.
2. An episode-level analysis dataset or a reproducible process for generating it.
3. Statistical comparison and adjusted logistic regression results.
4. A Power BI dashboard for exploring delinquency and cure patterns.
5. A short findings report explaining the results in business terms.

## References

- [Fannie Mae — Single-Family Loan Performance Data](https://capitalmarkets.fanniemae.com/credit-risk-transfer/single-family-credit-risk-transfer/single-family-loan-performance-data)
- Fannie Mae, *Single-Family Loan Performance Dataset and Credit Risk Transfer — Glossary and File Layout* (September 10, 2026), supplied with the project materials.

---

*This README will be updated as the analysis progresses. Results and screenshots will be added only after they have been calculated and validated.*
