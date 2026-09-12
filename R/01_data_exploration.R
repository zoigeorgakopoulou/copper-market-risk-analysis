# ==============================================================================
# Copper Price Dynamics: A Quantitative Analysis of 
# Commodity Market Risk
#
# Author: Zoi Georgakopoulou
# Data Source: Yahoo Finance
# Reference Source: CME Group
# Instrument: Copper Futures (HG=F)
# Period: 2007-2026 (through September 4, 2026)
# ==============================================================================

# ==============================================================================
# 1. Load Required Packages
# ==============================================================================
library(quantmod)

# ==============================================================================
# 2. Download Copper Futures Data
# ==============================================================================

copper <- getSymbols("HG=F",
                     src = "yahoo",
                     auto.assign = FALSE)

# ==============================================================================
# 3. Check for Missing Values
# ==============================================================================

sum(is.na(copper))

# ==============================================================================
# 4. Locate Missing Values
# ==============================================================================

colSums(is.na(copper))

# ==============================================================================
# 5. Identify Dates with Missing Data
# ==============================================================================

missing_dates <- index(copper)[!complete.cases(copper)]

missing_dates

# ==============================================================================
# 6. Extract Copper Closing Prices
# ==============================================================================

copper_close <- Cl(copper)

copper_close

# ==============================================================================
# 7. Calculate Daily Copper Returns
# ==============================================================================

copper_returns <- dailyReturn(copper_close, type = "arithmetic")

copper_returns

# ==============================================================================
# 8. Calculate 30-Day Rolling Volatility
# ==============================================================================

copper_volatility <- runSD(copper_returns, n = 30)

copper_volatility

# ==============================================================================
# 9. Plot 30-Day Rolling Volatility
# ==============================================================================

plot(copper_volatility,
     main = "30-Day Rolling Volatility of Copper",
     xlab = "Date",
     ylab = "Volatility")

# ==============================================================================
# 10. Calculate Annual Copper Returns
# ==============================================================================

annual_returns <- apply.yearly(copper_returns, function(x) {
  prod(1 + x, na.rm = TRUE) - 1
})

colnames(annual_returns) <- "Annual_Return"

annual_returns

# ==============================================================================
# 11. Plot Annual Copper Returns
# ==============================================================================

barplot(annual_returns * 100,
        main = "Annual Copper Futures Returns (2007-2026)",
        xlab = "Year",
        ylab = "Annual Return (%)")

# ==============================================================================
# 12. Identify Best and Worst Annual Returns
# ==============================================================================

best_year <- annual_returns[which.max(annual_returns)]
worst_year <- annual_returns[which.min(annual_returns)]

best_year
worst_year

# ==============================================================================
# 13. Calculate Annual Copper Volatility
# ==============================================================================

annual_volatility <- apply.yearly(copper_returns, sd, na.rm = TRUE)

colnames(annual_volatility) <- "Annual Volatility"

annual_volatility

# ==============================================================================
# 14. Combine Annual Return and Volatility
# ==============================================================================

annual_analysis <- merge(annual_returns, annual_volatility)

colnames(annual_analysis) <- c("Annual_Return", "Annual_Volatility")

annual_analysis

# ==============================================================================
# 15. Plot Annual Return vs. Annual Volatility
# ==============================================================================

plot(annual_analysis$Annual_Volatility * 100,
     annual_analysis$Annual_Return * 100,
     main = "Copper: Annual Return vs. Volatility",
     xlab = "Annual Volatility (%)",
     ylab = "Annual Return (%)")


# ==============================================================================
# 16. Calculate Return-Volatility Correlation
# ==============================================================================

return_volatility_correlation <- cor(
  annual_analysis$Annual_Return,
  annual_analysis$Annual_Volatility
)

return_volatility_correlation

# ==============================================================================
# 17. Identify Highest and Lowest Volatility Years
# ==============================================================================

highest_volatility_year <- annual_analysis[which.max(
  annual_analysis$Annual_Volatility),]

lowest_volatility_year <- annual_analysis[which.min(
  annual_analysis$Annual_Volatility),]

highest_volatility_year
lowest_volatility_year

# ==============================================================================
# 18. Plot Distribution of Daily Copper Returns
# ==============================================================================

hist(as.numeric(copper_returns),
     breaks = 50,
     main = "Distribution of Daily Copper Futures Returns",
     xlab = "Daily Return",
     ylab = "Frequency")

# ==============================================================================
# 19. Identify Extreme Daily Returns
# ==============================================================================

total_trading_days <- sum(!is.na(copper_returns))

extreme_returns <- copper_returns[abs(copper_returns) >= 0.05]

number_extreme_days <- length(extreme_returns)

percentage_extreme_days <- 
  number_extreme_days / total_trading_days * 100

number_extreme_days
percentage_extreme_days

# ==============================================================================
# 20. Extreme Returns by Year
# ==============================================================================

extreme_by_year <- table(format(index(extreme_returns), "%Y"))

extreme_by_year

# ==============================================================================
# 21. Calculate Downside Volatility
# ==============================================================================

negative_returns <- copper_returns[copper_returns < 0]

downside_volatility <- sd(negative_returns, na.rm = TRUE)

downside_volatility

# ==============================================================================
# 22. Create Final Risk Metrics Summary
# ==============================================================================

risk_metrics <- data.frame(
  Metric = c(
    "Daily Volatility",
    "Downside Volatility",
    "30-Day Rolling Volatility (Latest)",
    "Highest Annual Volatility",
    "Lowest Annual Volatility",
    "Extreme Return Days",
    "Extreme Return Days (%)"
  ),
  Value = c(
    sd(copper_returns, na.rm = TRUE),
    downside_volatility,
    last(copper_volatility),
    max(annual_analysis$Annual_Volatility, na.rm = TRUE),
    min(annual_analysis$Annual_Volatility, na.rm = TRUE),
    number_extreme_days,
    percentage_extreme_days
  )
)

risk_metrics

# ==============================================================================
# 23. Final Figure 1 - Copper Futures Closing Price
# ==============================================================================

plot(copper_close,
     main = "Copper Futures Closing Price (2007-2026)",
     xlab = "Date",
     ylab = "Price  (USD per pound)")

# ==============================================================================
# 24. Final Figure 2 - Daily Copper Futures Returns
# ==============================================================================

plot(copper_returns,
     main = "Daily Copper Futures Returns (2007-2026)",
     xlab = "Date",
     ylab = "Daily Return")

# ==============================================================================
# 25. Final Figure 3 - 30-Day Rolling Volatility
# ==============================================================================

plot(copper_volatility, 
     main = "30-Day Rolling Volatility of Copper Futures",
     xlab = "Date",
     ylab = "Volatility")

# ==============================================================================
# 26. Final Figure 4 - Annual Copper Futures Returns
# ==============================================================================

barplot(annual_returns * 100,
        main = "Annual Copper Futures Returns (2007-2026)",
        xlab = "Year",
        ylab = "Annual Return (%)")

# ==============================================================================
# 27. Final Figure 5 - Annual Return vs. Volatility
# ==============================================================================

plot(annual_analysis$Annual_Volatility * 100,
     annual_analysis$Annual_Return * 100,
     main = "Copper: Annual Return vs. Volatility",
     xlab = "Annual Volatility (%)",
     ylab = "Annual Return (%)")

# ==============================================================================
# 28. Save Final Figures
# ==============================================================================

png(file.path("figures", "copper_closing_price.png"),
    width = 1200, height = 800, res = 150)

plot(copper_close,
     main = "Copper Futures Closing Price (2007-2026)",
     xlab = "Date",
     ylab = "Price (USD per pound)")

dev.off()

png(file.path("figures", "daily_copper_returns.png"),
    width = 1200, height = 800, res = 150)

plot(copper_returns, 
     main = "Daily Copper Futures Returns (2007-2026)",
     xlab = "Date",
     ylab = "Daily Return")

dev.off()

png(file.path("figures", "rolling_volatility.png"),
    width = 1200, height = 800, res = 150)

plot(copper_volatility,
     main = "30-Day Rolling Volatility of Copper Futures",
     xlab = "Date",
     ylab = "Volatility")

dev.off()

png(file.path("figures", "annual_copper_returns.png"),
    width = 1200, height = 800, res = 150)

barplot(annual_returns * 100,
        main = "Annual Copper Futures Returns (2007-2026)",
        xlab = "Year",
        ylab = "Annual Return (%)")

dev.off()

png(file.path("figures", "annual_return_vs_volatility.png"),
    width = 1200, height = 800, res = 150)

plot(annual_analysis$Annual_Volatility * 100,
     annual_analysis$Annual_Return * 100,
     main = "Copper: Annual Return vs. Volatility",
     xlab = "Annual Volatility (%)",
     ylab = "Annual Return (%)")
    
dev.off()

# ==============================================================================
