
# SBA Loan Insights Dashboard

**Author:** Esha Teware  
**Course:** DATA 613 – Introduction to Data Science (Section 004)  
**Semester:** Fall 2025  
**Institution:** American University  
 

## Project Overview

The **SBA Loan Insights Dashboard** is an interactive R Shiny application built to analyze and visualize U.S. Small Business Administration (SBA) 7(a) 
loans issued from **FY 2020–Present**.It helps users explore how federally guaranteed small-business 
loans have evolved across **states, industries, and business types** in the post-COVID era.

This app is designed for **policy analysts, researchers, and small-business advocates** who want to evaluate regional lending equity, loan performance, and default risk.  
All data and code are open-source and reproducible following **DATA 613** best practices.



##  Repository Structure


├── app.R # Main Shiny app file
├── R_scripts/
│ ├── data_cleaning.R # Data cleaning and preprocessing
│ ├── helpers.R # Helper functions for analysis
├── data/
│ ├── sba_cleaned.rds # Cleaned dataset used by the app
├── data_raw/ 
│ ├── foia-7a-fy2020-present-asof-250630.csv (raw data)
├── vignette/
│ ├── Project_Plan_Esha.qmd
│ ├── Progress_Report_Esha.qmd
| ├── Vignette_Esha_final.qmd
│ └── HTML outputs
└── README.md




## Features

- **Overview Tab:** Interactive U.S. map showing total loans, average loan size, and total approval amount by state.  
- **Regional Trends:** Visualize top lending states and time trends (2020–2025).  
- **Business Insights:** Compare lending patterns by business age, type, and NAICS industry.  
- **Loan Outcomes:** Explore loan status distributions and run a logistic regression model predicting default likelihood.  
- **About & Ethics Tab:** Summarizes data sources, ethical guidelines, and reproducibility notes.



## Data Source

- **Dataset:** SBA 7(a) FOIA Public Data (FY 2020–Present)  
- **Source:** [https://data.sba.gov](https://data.sba.gov)  
- **Update Frequency:** Quarterly  
- **Last As-of Date:** June 30, 2025  
- **Size:** ~330,000 observations, 43 variables  
- **Format:** CSV -> cleaned and saved as `.rds` for faster app performance  



##  Setup Instructions

### 1. Clone the Repository


git clone https://github.com/Esha7498/gp02-25f-Esha7498.git
cd gp02-25f-Esha7498


# 2. Install Required Packages

install.packages(c("tidyverse", "janitor", "lubridate", "plotly",
                   "usmap", "DT", "bslib", "scales", "shiny"))

# 3. Run the App

shiny::runApp("app.R")


API Keys

This version of the dashboard uses only public static data and does not require any API keys.
In a future extension (Phase 2), the app may integrate Census Bureau ACS data to include state-level equity indicators (e.g., income, unemployment).


## Author Information

Esha Teware
Graduate Student, M.S. in Data Science
American University - Washington, D.C.
et6756a@american.edu


Acknowledgment:

This dashboard was developed as part of DATA 613 – Introduction to Data Science (Fall 2025).
The project follows American University’s standards for reproducible, ethical, and transparent data science.



