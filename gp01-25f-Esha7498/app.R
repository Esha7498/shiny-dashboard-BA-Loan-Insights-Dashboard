

library(shiny)
library(tidyverse)
library(plotly)
library(DT)
library(bslib)
library(usmap)
library(shinycssloaders)
library(scales)

# Load Cleaned Data
#sba_data <- readRDS("data/sba_cleaned.rds") this wa og cleaned data but too big to push to git
sba_data <- readRDS("data/sba_cleaned_compressed.rds")


# UI

ui <- fluidPage(
  theme = bs_theme(
    bootswatch = "flatly",
    base_font = font_google("Inter"),
    heading_font = font_google("Poppins")
    #bg = "#f8fafc"
  ),
  
  # App Header 
  div(
    style = "background-color:#003366; color:white; padding:20px; text-align:center; border-radius:8px; margin-bottom:10px;",
    h2("SBA Loan Insights Dashboard"),
    p(style = "font-size:16px; color:#f0f0f0;",
      "Exploring U.S. Small Business Administration Lending Trends (2020–Present)")
  ),
  
  # Navbar Tabs 
  navbarPage(
    title = NULL,
    id = "main_tabs",
    inverse = TRUE,
    collapsible = TRUE,
  
    # Overview Tab
    #################################
    tabPanel("Overview",
             sidebarLayout(
               sidebarPanel(
                 helpText("Tip: Use the year range and metric selector to explore trends."),
                 sliderInput("year", "Select Year Range:",
                             min = min(sba_data$year, na.rm = TRUE),
                             max = max(sba_data$year, na.rm = TRUE),
                             value = c(min(sba_data$year, na.rm = TRUE), max(sba_data$year, na.rm = TRUE)),
                             sep = ""),
                 selectInput("metric", "Select Metric:",
                             choices = c("Total Loans", "Average Loan Size", "Total Approval Amount"),
                             selected = "Total Loans"),
                 downloadButton("download_filtered", "⬇Download Filtered Data")
               ),
               mainPanel(
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; box-shadow:0 2px 6px rgba(0,0,0,0.05); margin-bottom:20px;",
                   h3("Overall Lending Overview", style = "color:#003366; font-weight:bold;"),
                   withSpinner(plotlyOutput("usMapPlot", height = "550px"))
                 ),
                 uiOutput("kpiBoxes"),
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; background-color:#f9fafb;",
                   h4("Summary Insights", style = "color:#003366; font-weight:bold;"),
                   p("This overview highlights how SBA loans are distributed across U.S. states and time. 
               Hover over states for loan details and adjust filters to observe patterns.")
                 )
               )
             )
    ),
    
  
    # Regional Trends Tab
    ##########################
    tabPanel("Regional Trends",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("region_year", "Select Year Range:",
                             min = min(sba_data$year, na.rm = TRUE),
                             max = max(sba_data$year, na.rm = TRUE),
                             value = c(min(sba_data$year, na.rm = TRUE), max(sba_data$year, na.rm = TRUE)),
                             sep = ""),
                 selectInput("region_state", "Select State(s):", choices = sort(unique(sba_data$borr_state)), multiple = TRUE)
               ),
               mainPanel(
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; margin-bottom:20px;",
                   h3("Top 10 States by Loan Volume", style = "color:#003366; font-weight:bold;"),
                   withSpinner(plotlyOutput("topStatesPlot", height = "450px"))
                 ),
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; margin-bottom:20px;",
                   h3("Loan Trends Over Time", style = "color:#003366; font-weight:bold;"),
                   withSpinner(plotlyOutput("timeTrendPlot", height = "450px"))
                 ),
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px;",
                   h3("Regional Loan Summary", style = "color:#003366; font-weight:bold;"),
                   DTOutput("regionalTable")
                 )
               )
             )
    ),
    

    # Business Insights Tab
    #################################
    tabPanel("Business Insights",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("biz_year", "Select Year Range:",
                             min = min(sba_data$year, na.rm = TRUE),
                             max = max(sba_data$year, na.rm = TRUE),
                             value = c(min(sba_data$year, na.rm = TRUE), max(sba_data$year, na.rm = TRUE)),
                             sep = ""),
                 selectInput("biz_var", "Select Business Variable:",
                             choices = c("Business Age" = "business_age",
                                         "Business Type" = "business_type",
                                         "Industry (Top 10)" = "naics_description")),
                 selectInput("biz_metric", "Select Metric:",
                             choices = c("Total Loans", "Average Loan Size"),
                             selected = "Total Loans")
               ),
               mainPanel(
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; margin-bottom:20px;",
                   h3("Business Profile Insights", style = "color:#003366; font-weight:bold;"),
                   withSpinner(plotlyOutput("bizBarPlot", height = "500px"))
                 ),
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; margin-bottom:20px;",
                   h3("Loan Distribution by Group", style = "color:#003366; font-weight:bold;"),
                   withSpinner(plotlyOutput("bizBoxPlot", height = "500px"))
                 ),
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px;",
                   h3("Summary Table", style = "color:#003366; font-weight:bold;"),
                   DTOutput("bizSummaryTable")
                 )
               )
             )
    ),
    
   
    # Loan Outcomes Tab
    ##################################
    tabPanel("Loan Outcomes",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("outcome_year", "Select Year Range:",
                             min = min(sba_data$year, na.rm = TRUE),
                             max = max(sba_data$year, na.rm = TRUE),
                             value = c(min(sba_data$year, na.rm = TRUE), max(sba_data$year, na.rm = TRUE)),
                             sep = ""),
                 
                 helpText(" Note: Selecting multiple predictors may take up to a minute to load model results."),
                 selectInput("predictor", "Select Predictor Variable(s):",
                             choices = c("Gross Approval" = "gross_approval",
                                         "Term (Months)" = "termin_months",
                                         "Business Age" = "business_age",
                                         "Collateral" = "collateral_ind",
                                         "Delivery Method" = "delivery_method",
                                         "State" = "borr_state"),
                             selected = c("gross_approval"),
                             multiple = TRUE)
                 
               ),
               mainPanel(
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; margin-bottom:20px;",
                   h3("Loan Status Distribution", style = "color:#003366; font-weight:bold;"),
                   withSpinner(plotlyOutput("loanStatusPlot", height = "500px"))
                 ),
                 div(
                   style = "border:1px solid #dce3eb; border-radius:10px; padding:15px; background-color:#f9fafb;",
                   h3("Logistic Regression Model Summary", style = "color:#003366; font-weight:bold;"),
                   verbatimTextOutput("logitSummary"),
                   p("This model estimates how each selected predictor influences the likelihood of a loan default (1 = Charged Off, 0 = Paid/Active).")
                 )
               )
             )
    ),
    
    # About & Ethics Tab
    ##################################
    tabPanel("About & Ethics",
             fluidPage(
               h2("About This Dashboard", style = "color:#003366; font-weight:bold;"),
               p("This dashboard was developed as part of the DATA 613 – Introduction to Data Science course at American University (Fall 2025)."),
               p("It provides an interactive exploration of the U.S. Small Business Administration (SBA)Loan Program using public FOIA data."),
               h3("Ethical Considerations", style = "color:#003366; font-weight:bold;"),
               tags$ul(
                 tags$li( strong("Transparency:"), " All analyses are reproducible using public data and open-source R packages."),
                 tags$li(strong("Privacy:"), " Personally identifiable borrower data has been excluded."),
                 tags$li(strong("Fairness:"), " Visualizations are aggregated by state or business type to prevent bias."),
                 tags$li( strong("Context:"), " Results should be interpreted within broader economic contexts.")
               ),
               h3("Authorship & Acknowledgment", style = "color:#003366; font-weight:bold;"),
               p(strong("Author:"), "Esha Teware"),
               p("Graduate Student, MS in Data Science, American University"),
               p("2025 DATA 613 Project – SBA Loan Analytics Dashboard")
             )
    )
  ),
  

  # Footer
  ##################################
  tags$footer(
    style = "text-align:center; padding:10px; background-color:#003366; color:white; border-radius:8px; margin-top:20px;",
    HTML("&copy; 2025 Esha Teware | DATA 613 – Introduction to Data Science | American University")
  )
)


############# SERVER

server <- function(input, output, session) {
  
  # Reactives 
  filtered_data <- reactive({
    sba_data %>% filter(year >= input$year[1], year <= input$year[2])
  })
  
  regional_filtered <- reactive({
    sba_data %>%
      filter(year >= input$region_year[1], year <= input$region_year[2]) %>%
      {if (length(input$region_state) > 0) filter(., borr_state %in% input$region_state) else .}
  })
  

  # Overview Map
  ##################################
  output$usMapPlot <- renderPlotly({
    df <- filtered_data() %>%
      group_by(borr_state) %>%
      summarise(
        total_loans = n(),
        total_approval = sum(gross_approval, na.rm = TRUE),
        avg_loan = mean(gross_approval, na.rm = TRUE)
      ) %>%
      rename(state = borr_state)
    
    df <- df %>%
      mutate(Metric = case_when(
        input$metric == "Total Loans" ~ total_loans,
        input$metric == "Average Loan Size" ~ avg_loan,
        input$metric == "Total Approval Amount" ~ total_approval
      ))
    
    colnames(df)[colnames(df) == "Metric"] <- input$metric
    
    plot <- plot_usmap(data = df, values = input$metric, regions = "states") +
      scale_fill_continuous(name = input$metric, label = scales::comma,
                            low = "#a6cee3", high = "#1f78b4") +
      labs(title = paste(input$metric, "by State")) +
      theme(legend.position = "right")
    
    ggplotly(plot, tooltip = c("state", input$metric))
  })
  

  # KPI Summary Boxes
  ##################################
  output$kpiBoxes <- renderUI({
    df <- filtered_data()
    total_loans <- nrow(df)
    avg_loan <- mean(df$gross_approval, na.rm = TRUE)
    total_approval <- sum(df$gross_approval, na.rm = TRUE)
    
    fluidRow(
      column(4, div(style="background:#0072B2; color:white; padding:15px; border-radius:8px; text-align:center;",
                    h4("Total Loans"), h3(scales::comma(total_loans)))),
      column(4, div(style="background:#238b45; color:white; padding:15px; border-radius:8px; text-align:center;",
                    h4("Total Approval"), h3(paste0("$", scales::comma(round(total_approval)))))),
      column(4, div(style="background:#cc4c02; color:white; padding:15px; border-radius:8px; text-align:center;",
                    h4("Avg Loan Size"), h3(paste0("$", scales::comma(round(avg_loan))))))
    )
  })
  
  
  # Download Filtered Data
  ##################################
  output$download_filtered <- downloadHandler(
    filename = function() paste0("sba_filtered_", Sys.Date(), ".csv"),
    content = function(file) write_csv(filtered_data(), file)
  )
  
  
    

  
  # Regional Bar Chart (Top States) 
  output$topStatesPlot <- renderPlotly({
    df <- regional_filtered() %>%
      group_by(borr_state) %>%
      summarise(total_loans = n(), total_approval = sum(gross_approval, na.rm = TRUE)) %>%
      arrange(desc(total_loans)) %>%
      slice_head(n = 10)
    
    p <- ggplot(df, aes(x = reorder(borr_state, total_loans), y = total_loans, fill = borr_state)) +
      geom_col() +
      coord_flip() +
      labs(title = "Top 10 States by Loan Count", x = "State", y = "Total Loans") +
      theme_minimal() + theme(legend.position = "none")
    ggplotly(p)
  })
  
  # Regional Time Trend 
  output$timeTrendPlot <- renderPlotly({
    df <- regional_filtered() %>%
      group_by(year, borr_state) %>%
      summarise(total_loans = n(), .groups = 'drop')
    
    p <- ggplot(df, aes(x = year, y = total_loans, color = borr_state)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      labs(title = "Loan Volume Over Time by State", x = "Year", y = "Number of Loans") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Regional Table
  output$regionalTable <- renderDT({
    df <- regional_filtered() %>%
      group_by(borr_state) %>%
      summarise(
        total_loans = n(),
        total_approval = sum(gross_approval, na.rm = TRUE),
        avg_loan = mean(gross_approval, na.rm = TRUE)
      ) %>% arrange(desc(total_loans))
    
    datatable(df, options = list(pageLength = 10), caption = 'Regional Summary of SBA Loans')
  })

  # Business Insights Reactives 
  business_filtered <- reactive({
    sba_data %>%
      filter(year >= input$biz_year[1], year <= input$biz_year[2])
  })
  
  # Bar Plot
  output$bizBarPlot <- renderPlotly({
    df <- business_filtered() %>%
      group_by(.data[[input$biz_var]]) %>%
      summarise(
        total_loans = n(),
        avg_loan = mean(gross_approval, na.rm = TRUE),
        .groups = "drop"
      )
    
    # Limit to top 10 if industry
    if (input$biz_var == "naics_description") {
      df <- df %>% arrange(desc(total_loans)) %>% slice_head(n = 10)
    }
    
    metric_col <- if (input$biz_metric == "Total Loans") "total_loans" else "avg_loan"
    
    p <- ggplot(df, aes(x = reorder(.data[[input$biz_var]], .data[[metric_col]]),
                        y = .data[[metric_col]], fill = .data[[input$biz_var]])) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      labs(
        title = paste(input$biz_metric, "by", str_to_title(gsub("_", " ", input$biz_var))),
        x = str_to_title(gsub("_", " ", input$biz_var)),
        y = input$biz_metric
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Box Plot (Loan Distribution) 
  output$bizBoxPlot <- renderPlotly({
    df <- business_filtered()
    
    # avoid overplotting for industry
    if (input$biz_var == "naics_description") {
      df <- df %>% filter(naics_description %in%
                            (df %>% count(naics_description, sort = TRUE) %>% slice_head(n = 10))$naics_description)
    }
    
    p <- ggplot(df, aes(x = .data[[input$biz_var]], y = gross_approval, fill = .data[[input$biz_var]])) +
      geom_boxplot(outlier.alpha = 0.2, show.legend = FALSE) +
      coord_flip() +
      labs(
        title = paste("Loan Amount Distribution by", str_to_title(gsub("_", " ", input$biz_var))),
        x = str_to_title(gsub("_", " ", input$biz_var)),
        y = "Gross Approval ($)"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Summary Table
  output$bizSummaryTable <- renderDT({
    df <- business_filtered() %>%
      group_by(.data[[input$biz_var]]) %>%
      summarise(
        Total_Loans = n(),
        Avg_Loan = round(mean(gross_approval, na.rm = TRUE), 0),
        Jobs_Supported = round(mean(jobs_supported, na.rm = TRUE), 1),
        .groups = "drop"
      ) %>%
      arrange(desc(Total_Loans))
    
    if (input$biz_var == "naics_description") {
      df <- df %>% slice_head(n = 10)
    }
    
    datatable(df, options = list(pageLength = 10),
              caption = paste("Loan Summary by", str_to_title(gsub('_', ' ', input$biz_var))))
  })
  
  # Loan Outcomes Reactives 
  outcome_filtered <- reactive({
    sba_data %>%
      filter(year >= input$outcome_year[1], year <= input$outcome_year[2])
  })
  
  # Loan Status Distribution
  output$loanStatusPlot <- renderPlotly({
    df <- outcome_filtered() %>%
      group_by(loan_status) %>%
      summarise(count = n(), .groups = 'drop') %>%
      arrange(desc(count))
    
    p <- ggplot(df, aes(x = reorder(loan_status, count), y = count, fill = loan_status)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      labs(
        title = "Distribution of Loan Statuses",
        x = "Loan Status",
        y = "Count of Loans"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$logitSummary <- renderPrint({
    df <- outcome_filtered() %>%
      select(default, all_of(input$predictor)) %>%
      drop_na()
    df <- df %>%
      mutate(across(where(is.character) | where(is.logical), as.factor))
    formula <- as.formula(paste("default ~", paste(input$predictor, collapse = " + ")))
    model <- glm(formula, data = df, family = "binomial")
    cat("Logistic Regression Model Summary:\n")
    summary(model)
  })
  

  
  
  }

shinyApp(ui, server)
