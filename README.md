# Mortgage Delinquency Migration & Cure-Risk Analysis

**Fannie Mae Single-Family Loan Performance Data — 2018 Q1 Cohort**

## The Problem

When a homeowner misses mortgage payments, it doesn't automatically mean they're headed to foreclosure. Many borrowers catch up within a few months on their own. For a lender or credit risk team, knowing which borrowers are likely to self-correct versus which need early intervention is a real, practical question — it shapes where servicing effort and resources go.

Fannie Mae's **HomeReady** program is built for lower-income borrowers, with smaller down payments and more flexible underwriting than a standard loan. This raises a natural question for a risk team: **if a HomeReady borrower falls behind, do they recover at a different rate than a standard borrower — and is that actually about the program, or just about who it tends to attract (lower credit scores, higher loan-to-value)?**

This project answers that question end to end: SQL for cleaning and building delinquency episodes, Python for the statistics, Power BI for presenting the result.

## Business Questions

1. How often do delinquent loans return to current status within 3 months?
2. Is there a real difference in cure rate between HomeReady and standard loans, or could the raw numbers just be noise?
3. How much of that difference is actually explained by borrower risk factors (credit score, loan-to-value, debt-to-income) rather than the program itself?
4. Which loan characteristics are most strongly associated with curing?
5. Is the remaining, adjusted gap between the two groups still meaningful once those factors are accounted for?

## What I Found

| Question | Answer |
|---|---|
| Raw cure rate — HomeReady | 61.6% |
| Raw cure rate — Standard | 69.0% |
| Raw gap | 6.6 percentage points |
| Is the raw gap statistically real? | Yes — chi-square test, p = 1.19 × 10⁻³⁴ |
| Odds ratio (HomeReady vs Standard), adjusted | 0.88 (95% CI: 0.83–0.94) |
| Adjusted cure rate — HomeReady | 50.39% |
| Adjusted cure rate — Standard | 53.53% |
| Adjusted gap | 3.14 percentage points |
| Is the adjusted gap still statistically significant? | Yes, p < 0.001 |

**In plain terms:** HomeReady borrowers do cure less often than standard borrowers. But about half of that gap disappears once you account for the fact that HomeReady borrowers tend to carry more risk on paper (lower credit scores, higher loan-to-value ratios). A smaller, but still real, gap remains even after that adjustment — meaning HomeReady status itself is associated with a somewhat lower chance of recovering from delinquency, independent of those other factors.

## Why This Matters

This is the exact kind of split a credit risk or servicing team needs before making a decision: is a program riskier on its own merits, or does it just attract a riskier population? Mixing those two up leads to the wrong conclusion — over-blaming a program, or under-pricing its actual risk. Separating them is what this analysis does.

## Data

| Item | Detail |
|---|---|
| Source | Fannie Mae Single-Family Loan Performance Data |
| Cohort | 2018 Q1 acquisitions |
| Raw loan-month records | 23,563,399 |
| Columns used (of 113 available) | 22 |
| Unique loans in cohort | H = 30,863, F = 14,291, Standard (7) = 413,676 |
| Eligible delinquency episodes analyzed | 72,555 (verified: COUNT(\*) = COUNT(DISTINCT LOAN_ID) = 72,555) |
| Episodes by group | H = 6,645, Standard = 62,339, F (HFA Preferred) = 3,571 |

F (HFA Preferred) loans are a separate affordability program and were excluded from the core H-vs-standard comparison — they're included in the full population count on the dashboard's Overview page, but not in the regression.

The original raw source file (several gigabytes, pipe-delimited, 113 columns) is not included in this repository — Fannie Mae's terms of use don't permit redistributing it. The CSVs in `Dataset_for_PBi/` and `Sql Output/` are the project's own processed, loan-level outputs (episode data and model results), not the raw source file.

## How I Did It

**1. Cleaning the data (`Sql Codes/SQLQuery1.sql`)**
Converted the raw text file into proper data types, validated the row count matched the source exactly, and checked category values (like delinquency status codes) against Fannie Mae's official glossary.

**2. Building delinquency episodes (`Sql Codes/SQLQuery2.sql`)**
This was the core and hardest step. A loan doesn't have "a delinquency" as a single flag — it has a run of consecutive delinquent months, starting from some earlier "current" month. I identified where these runs actually began, excluded loans that were already delinquent the first time they appear in the data (since there's no way to know their true starting point), and for each episode, checked the following 3 months to classify the outcome as Cured, Not Cured, Exited before completion, or Unknown — using both the delinquency status and the loan's exit reason code, so a loan that cured and then paid off still gets correctly counted as cured. Output: `Sql Output/p1_primary_analysis.csv`.

**3. Statistical analysis (`Python codes for Data Cleaning/P1.ipynb`, `P2.ipynb`)**
- 95% confidence intervals for each group's raw cure rate.
- A correlation/VIF check across loan characteristics — OLTV and OCLTV turned out to be about 98% redundant with each other, so OLTV was kept and OCLTV dropped.
- A chi-square test confirming the raw gap is statistically real, not noise.
- A logistic regression predicting cure outcome from program group plus credit score, loan-to-value, debt-to-income, loan age, starting delinquency severity, loan purpose, occupancy, and a before/after-COVID flag — run on the full sample with no train/test split, since this is meant to measure an adjusted association rather than build a predictive model, and each loan contributes only one episode.
- Exported three files to `Dataset_for_PBi/`: `Full_Population_Data.csv` (all H+7+F episodes, for the dashboard's Overview page), `H7_Comparison_Data.csv` (H vs standard only, for the group comparison and risk-factor pages), and `Regression_Summary.csv` (the final model results).

**4. Power BI dashboard (`Power BI Report/Mortgage-Delinquency-Migration-Cure-Risk-Analysis.pbix`)**
A 4-page dashboard — Overview, Group Comparison, Risk Factor Breakdown, Statistical Findings. All statistics were calculated in Python beforehand; Power BI's job here is purely presentation.

## What This Analysis Can't Tell You

- **It's correlational, not causal.** This shows an association between HomeReady status and cure rate, not proof that the program itself causes a lower cure rate.
- **It's one quarter.** Results are specific to loans originated in 2018 Q1 and may not hold for a different year or different market conditions.
- **"Standard" (coded 7) isn't a clean, verified baseline** — it just means "not flagged under any special eligibility program," which includes a wide range of borrowers, not a single uniform group.
- **The data runs through the COVID-19 period**, when loan performance was affected by forbearance programs and broader economic disruption. A before/after-COVID flag was included as a control, but this remains a real caveat on the comparison.

## Tools Used

T-SQL · Python (Pandas, NumPy, SciPy, statsmodels) · Power BI (Power Query, DAX)

## Repository Structure

```
Dataset_for_PBi/              — processed CSVs feeding the Power BI dashboard
Power BI Report/               — the .pbix dashboard file
Python codes for Data Cleaning/ — Jupyter notebooks (statistics + regression)
Sql Codes/                     — T-SQL scripts for cleaning and episode construction
Sql Output/                    — the episode-level dataset output from SQL
README.md
.gitignore
```
