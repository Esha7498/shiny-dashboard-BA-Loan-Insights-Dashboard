# R/helpers.R
# Helper Functions for SBA Loan Insights Dashboard

library(tidyverse)

# Summary Metrics 
get_summary_metrics <- function(data) {
  # Return total number of loans, total approved amount, and average loan size
  tibble(
    total_loans = nrow(data),
    total_amount = sum(data$gross_approval, na.rm = TRUE),
    avg_loan = mean(data$gross_approval, na.rm = TRUE)
  )
}

# Top States Summary 
state_summary <- function(data) {
  data %>%
    group_by(borr_state) %>%
    summarise(
      total_loans = n(),
      total_approval = sum(gross_approval, na.rm = TRUE),
      avg_approval = mean(gross_approval, na.rm = TRUE)
    ) %>%
    arrange(desc(total_loans)) %>%
    slice_head(n = 10)
}

# Top Industries Summary 
industry_summary <- function(data) {
  data %>%
    group_by(naics_description) %>%
    summarise(
      total_loans = n(),
      total_approval = sum(gross_approval, na.rm = TRUE),
      avg_approval = mean(gross_approval, na.rm = TRUE)
    ) %>%
    arrange(desc(total_approval)) %>%
    slice_head(n = 10)
}

#  Yearly Trend 
loan_trend <- function(data) {
  data %>%
    group_by(year) %>%
    summarise(total_loans = n()) %>%
    arrange(year)
}

# Default Rate by Variable 
default_rate_by <- function(data, var) {
  data %>%
    group_by({{ var }}) %>%
    summarise(
      default_rate = mean(default, na.rm = TRUE),
      n = n()
    ) %>%
    filter(n > 50) %>%
    arrange(desc(default_rate))
}

# Clean Labels 
pretty_number <- function(x) {
  scales::comma(x, accuracy = 1)
}

# Message
cat("Helper functions loaded successfully.\n")


