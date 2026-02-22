# SBA Loan Insights Dashboard

**Live app:** https://fpqndl-esha-teware.shinyapps.io/SBA-Loan-Insights-R_Shiny-Dashboard/

An interactive R Shiny dashboard for exploring U.S. SBA **7(a)** lending activity from **FY 2020–Present**. The app supports quick, policy- and business-focused analysis of lending patterns across **states, industries (NAICS), and business characteristics**, with built-in views for trends and outcomes.

---

## What you can do

- **Geographic overview:** Compare lending volume and approval dollars across U.S. states via an interactive map.
- **Trends & rankings:** Track lending over time and identify top lending states.
- **Borrower & industry insights:** Slice lending by business type, business age, and NAICS industry.
- **Outcomes & risk modeling:** Review loan status distributions and run a baseline logistic regression to explore factors associated with default risk.

---

## Data

- **Source:** SBA 7(a) FOIA Public Data (FY 2020–Present), published via data.sba.gov  
- **As-of date:** June 30, 2025  
- **Pipeline:** Raw CSV → cleaned dataset stored as `.rds` for faster app performance

> Note: The dashboard uses public, static data and does not require API keys.

---

