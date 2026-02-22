# Data Cleaning Script
# tidyverse workflow, janitor for column names, 
# lubridate for dates, and readr for loading.

library(tidyverse)
library(janitor)
library(lubridate)

#  Load Data 
sba_raw <- read_csv("data_raw/foia-7a-fy2020-present-asof-250630.csv",
                    show_col_types = FALSE)

#Clean Column Names 
sba_clean <- sba_raw %>%
  clean_names()

# Select Relevant Variables
sba_clean <- sba_clean %>%
  select(
    as_of_date, approval_date, approval_fy, program, borr_state, borr_city,
    gross_approval, termin_months, naics_description, processing_method, # renamed for consistency
    collateral_ind, business_type, business_age, jobs_supported,
    loan_status, paidin_full_date, chargeoff_date, gross_chargeoff_amount,
    bank_name
  )

# Parse Dates and Create Year Variable 
sba_clean <- sba_clean %>%
  mutate(
    as_of_date = mdy(as_of_date),
    approval_date = mdy(approval_date),
    paidin_full_date = mdy(paidin_full_date),
    chargeoff_date = mdy(chargeoff_date),
    year = case_when(
      !is.na(approval_fy) ~ as.numeric(approval_fy),
      !is.na(approval_date) ~ year(approval_date),
      TRUE ~ year(as_of_date)
    )
  )

# Create Derived Variables 
sba_clean <- sba_clean %>%
  mutate(
    default = case_when(
      !is.na(chargeoff_date) ~ 1,
      loan_status == "CHGOFF" ~ 1,
      TRUE ~ 0
    ),
    business_age = case_when(
      str_detect(business_age, "Existing") ~ "Existing",
      str_detect(business_age, "New") | str_detect(business_age, "Change") ~ "Startup",
      TRUE ~ "Unknown"
    ),
    collateral_ind = if_else(collateral_ind == "Y", "Yes", "No")
  )

# Filter Data for Use 
# Remove missing gross_approval and extreme outliers
sba_clean <- sba_clean %>%
  filter(!is.na(gross_approval), gross_approval > 0)

# Save Cleaned Data 
# Stored in data/ folder for Shiny app use
write_rds(sba_clean, "data/sba_cleaned.rds")

# Confirmation Messages 
cat("Data cleaning complete. Cleaned file saved to data/sba_cleaned.rds\\n")
