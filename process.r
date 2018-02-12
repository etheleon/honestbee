#!/usr/bin/env Rscript

library(tidyverse)
#" @params
xform_data <- function(x) {
  x$UnknownNumberOfDependents <- as.integer(is.na(x$NumberOfDependents))
  x$UnknownMonthlyIncome <- as.integer(is.na(x$MonthlyIncome))

  x$NoDependents <- as.integer(x$NumberOfDependents == 0)
  x$NoDependents[is.na(x$NoDependents)] <- 0

  x$NumberOfDependents[x$UnknownNumberOfDependents==1] <- 0

  x$NoIncome <- as.integer(x$MonthlyIncome == 0)
  x$NoIncome[is.na(x$NoIncome)] <- 0

  x$MonthlyIncome[x$UnknownMonthlyIncome==1] <- 0

  x$ZeroDebtRatio <- as.integer(x$DebtRatio == 0)
  x$UnknownIncomeDebtRatio <- x$DebtRatio
  x$UnknownIncomeDebtRatio[x$UnknownMonthlyIncome == 0] <- 0
  x$DebtRatio[x$UnknownMonthlyIncome == 1] <- 0

  x$WeirdRevolvingUtilization <- x$RevolvingUtilizationOfUnsecuredLines
  x$WeirdRevolvingUtilization[!(log(x$RevolvingUtilizationOfUnsecuredLines) > 3)] <- 0
  x$ZeroRevolvingUtilization <- as.integer(x$RevolvingUtilizationOfUnsecuredLines == 0)
  x$RevolvingUtilizationOfUnsecuredLines[log(x$RevolvingUtilizationOfUnsecuredLines) > 3] <- 0

  x$Log.Debt <- log(pmax(x$MonthlyIncome, rep(1, nrow(x))) * x$DebtRatio)
  x$Log.Debt[!is.finite(x$Log.Debt)] <- 0

  x$RevolvingLines <- x$NumberOfOpenCreditLinesAndLoans - x$NumberRealEstateLoansOrLines

  x$HasRevolvingLines <- as.integer(x$RevolvingLines > 0)
  x$HasRealEstateLoans <- as.integer(x$NumberRealEstateLoansOrLines > 0)
  x$HasMultipleRealEstateLoans <- as.integer(x$NumberRealEstateLoansOrLines > 2)
  x$EligibleSS <- as.integer(x$age >= 60)
  x$DTIOver33 <- as.integer(x$NoIncome == 0 & x$DebtRatio > 0.33)
  x$DTIOver43 <- as.integer(x$NoIncome == 0 & x$DebtRatio > 0.43)
  x$DisposableIncome <- (1 - x$DebtRatio) * x$MonthlyIncome
  x$DisposableIncome[x$NoIncome == 1] <- 0

  x$RevolvingToRealEstate <- x$RevolvingLines / (1 + x$NumberRealEstateLoansOrLines)

  #column 4
  x$NumberOfTime30.59DaysPastDueNotWorseLarge <- as.integer(x$NumberOfTime30.59DaysPastDueNotWorse > 90)
  x$NumberOfTime30.59DaysPastDueNotWorse96 <- as.integer(x$NumberOfTime30.59DaysPastDueNotWorse == 96)
  x$NumberOfTime30.59DaysPastDueNotWorse98 <- as.integer(x$NumberOfTime30.59DaysPastDueNotWorse == 98)
  x$Never30.59DaysPastDueNotWorse <- as.integer(x$NumberOfTime30.59DaysPastDueNotWorse == 0)
  x$NumberOfTime30.59DaysPastDueNotWorse[x$NumberOfTime30.59DaysPastDueNotWorse > 90] <- 0
  #column 9
  x$NumberOfTime60.89DaysPastDueNotWorseLarge <- as.integer(x$NumberOfTime60.89DaysPastDueNotWorse > 90)
  x$NumberOfTime60.89DaysPastDueNotWorse96 <- as.integer(x$NumberOfTime60.89DaysPastDueNotWorse == 96)
  x$NumberOfTime60.89DaysPastDueNotWorse98 <- as.integer(x$NumberOfTime60.89DaysPastDueNotWorse == 98)
  x$Never60.89DaysPastDueNotWorse <- as.integer(x$NumberOfTime60.89DaysPastDueNotWorse == 0)
  x$NumberOfTime60.89DaysPastDueNotWorse[x$NumberOfTime60.89DaysPastDueNotWorse > 90] <- 0

  x$NumberOfTimes90DaysLateLarge <- as.integer(x$NumberOfTimes90DaysLate > 90)
  x$NumberOfTimes90DaysLate96 <- as.integer(x$NumberOfTimes90DaysLate == 96)
  x$NumberOfTimes90DaysLate98 <- as.integer(x$NumberOfTimes90DaysLate == 98)
  x$Never90DaysLate <- as.integer(x$NumberOfTimes90DaysLate == 0)
  x$NumberOfTimes90DaysLate[x$NumberOfTimes90DaysLate > 90] <- 0

  x$IncomeDivBy10 <- as.integer(x$MonthlyIncome %% 10 == 0)
  x$IncomeDivBy100 <- as.integer(x$MonthlyIncome %% 100 == 0)
  x$IncomeDivBy1000 <- as.integer(x$MonthlyIncome %% 1000 == 0)
  x$IncomeDivBy5000 <- as.integer(x$MonthlyIncome %% 5000 == 0)
  x$Weird0999Utilization <- as.integer(x$RevolvingUtilizationOfUnsecuredLines == 0.9999999)
  x$FullUtilization <- as.integer(x$RevolvingUtilizationOfUnsecuredLines == 1)
  x$ExcessUtilization <- as.integer(x$RevolvingUtilizationOfUnsecuredLines > 1)

  x$NumberOfTime30.89DaysPastDueNotWorse <- x$NumberOfTime30.59DaysPastDueNotWorse + x$NumberOfTime60.89DaysPastDueNotWorse
  x$Never30.89DaysPastDueNotWorse <- x$Never60.89DaysPastDueNotWorse * x$Never30.59DaysPastDueNotWorse

  x$NumberOfTimesPastDue <- x$NumberOfTime30.59DaysPastDueNotWorse + x$NumberOfTime60.89DaysPastDueNotWorse + x$NumberOfTimes90DaysLate
  x$NeverPastDue <- x$Never90DaysLate * x$Never60.89DaysPastDueNotWorse * x$Never30.59DaysPastDueNotWorse
  x$Log.RevolvingUtilizationTimesLines <- log1p(x$RevolvingLines * x$RevolvingUtilizationOfUnsecuredLines)

  x$Log.RevolvingUtilizationOfUnsecuredLines <- log(x$RevolvingUtilizationOfUnsecuredLines)
  x$Log.RevolvingUtilizationOfUnsecuredLines[is.na(x$Log.RevolvingUtilizationOfUnsecuredLines)] <- 0
  x$Log.RevolvingUtilizationOfUnsecuredLines[!is.finite(x$Log.RevolvingUtilizationOfUnsecuredLines)] <- 0
  x$RevolvingUtilizationOfUnsecuredLines <- NULL

  x$DelinquenciesPerLine <- x$NumberOfTimesPastDue / x$NumberOfOpenCreditLinesAndLoans
  x$DelinquenciesPerLine[x$NumberOfOpenCreditLinesAndLoans == 0] <- 0
  x$MajorDelinquenciesPerLine <- x$NumberOfTimes90DaysLate / x$NumberOfOpenCreditLinesAndLoans
  x$MajorDelinquenciesPerLine[x$NumberOfOpenCreditLinesAndLoans == 0] <- 0
  x$MinorDelinquenciesPerLine <- x$NumberOfTime30.89DaysPastDueNotWorse / x$NumberOfOpenCreditLinesAndLoans
  x$MinorDelinquenciesPerLine[x$NumberOfOpenCreditLinesAndLoans == 0] <- 0

  # Now delinquencies per revolving
  x$DelinquenciesPerRevolvingLine <- x$NumberOfTimesPastDue / x$RevolvingLines
  x$DelinquenciesPerRevolvingLine[x$RevolvingLines == 0] <- 0
  x$MajorDelinquenciesPerRevolvingLine <- x$NumberOfTimes90DaysLate / x$RevolvingLines
  x$MajorDelinquenciesPerRevolvingLine[x$RevolvingLines == 0] <- 0
  x$MinorDelinquenciesPerRevolvingLine <- x$NumberOfTime30.89DaysPastDueNotWorse / x$RevolvingLines
  x$MinorDelinquenciesPerRevolvingLine[x$RevolvingLines == 0] <- 0


  x$Log.DebtPerLine <- x$Log.Debt - log1p(x$NumberOfOpenCreditLinesAndLoans)
  x$Log.DebtPerRealEstateLine <- x$Log.Debt - log1p(x$NumberRealEstateLoansOrLines)
  x$Log.DebtPerPerson <- x$Log.Debt - log1p(x$NumberOfDependents)
  x$RevolvingLinesPerPerson <- x$RevolvingLines / (1 + x$NumberOfDependents)
  x$RealEstateLoansPerPerson <- x$NumberRealEstateLoansOrLines / (1 + x$NumberOfDependents)
  x$UnknownNumberOfDependents <- as.integer(x$UnknownNumberOfDependents)
  x$YearsOfAgePerDependent <- x$age / (1 + x$NumberOfDependents)

  x$Log.MonthlyIncome <- log(x$MonthlyIncome)
  x$Log.MonthlyIncome[!is.finite(x$Log.MonthlyIncome)|is.na(x$Log.MonthlyIncome)] <- 0
  x$MonthlyIncome <- NULL
  x$Log.IncomePerPerson <- x$Log.MonthlyIncome - log1p(x$NumberOfDependents)
  x$Log.IncomeAge <- x$Log.MonthlyIncome - log1p(x$age)

  x$Log.NumberOfTimesPastDue <- log(x$NumberOfTimesPastDue)
  x$Log.NumberOfTimesPastDue[!is.finite(x$Log.NumberOfTimesPastDue)] <- 0

  x$Log.NumberOfTimes90DaysLate <- log(x$NumberOfTimes90DaysLate)
  x$Log.NumberOfTimes90DaysLate[!is.finite(x$Log.NumberOfTimes90DaysLate)] <- 0

  x$Log.NumberOfTime30.59DaysPastDueNotWorse <- log(x$NumberOfTime30.59DaysPastDueNotWorse)
  x$Log.NumberOfTime30.59DaysPastDueNotWorse[!is.finite(x$Log.NumberOfTime30.59DaysPastDueNotWorse)] <- 0

  x$Log.NumberOfTime60.89DaysPastDueNotWorse <- log(x$NumberOfTime60.89DaysPastDueNotWorse)
  x$Log.NumberOfTime60.89DaysPastDueNotWorse[!is.finite(x$Log.NumberOfTime60.89DaysPastDueNotWorse)] <- 0

  x$Log.Ratio90to30.59DaysLate <- x$Log.NumberOfTimes90DaysLate - x$Log.NumberOfTime30.59DaysPastDueNotWorse
  x$Log.Ratio90to60.89DaysLate <- x$Log.NumberOfTimes90DaysLate - x$Log.NumberOfTime60.89DaysPastDueNotWorse

  x$AnyOpenCreditLinesOrLoans <- as.integer(x$NumberOfOpenCreditLinesAndLoans > 0)
  x$Log.NumberOfOpenCreditLinesAndLoans <- log(x$NumberOfOpenCreditLinesAndLoans)
  x$Log.NumberOfOpenCreditLinesAndLoans[!is.finite(x$Log.NumberOfOpenCreditLinesAndLoans)] <- 0
  x$Log.NumberOfOpenCreditLinesAndLoansPerPerson <- x$Log.NumberOfOpenCreditLinesAndLoans - log1p(x$NumberOfDependents)

  x$Has.Dependents <- as.integer(x$NumberOfDependents > 0)
  x$Log.HouseholdSize <- log1p(x$NumberOfDependents)
  x$NumberOfDependents <- NULL

  x$Log.DebtRatio <- log(x$DebtRatio)
  x$Log.DebtRatio[!is.finite(x$Log.DebtRatio)] <- 0
  x$DebtRatio <- NULL

  x$Log.DebtPerDelinquency <- x$Log.Debt - log1p(x$NumberOfTimesPastDue)
  x$Log.DebtPer90DaysLate <- x$Log.Debt - log1p(x$NumberOfTimes90DaysLate)


  x$Log.UnknownIncomeDebtRatio <- log(x$UnknownIncomeDebtRatio)
  x$Log.UnknownIncomeDebtRatio[!is.finite(x$Log.UnknownIncomeDebtRatio)] <- 0
  x$IntegralDebtRatio <- NULL
  x$Log.UnknownIncomeDebtRatioPerPerson <- x$Log.UnknownIncomeDebtRatio - x$Log.HouseholdSize
  x$Log.UnknownIncomeDebtRatioPerLine <- x$Log.UnknownIncomeDebtRatio - log1p(x$NumberOfOpenCreditLinesAndLoans)
  x$Log.UnknownIncomeDebtRatioPerRealEstateLine <- x$Log.UnknownIncomeDebtRatio - log1p(x$NumberRealEstateLoansOrLines)
  x$Log.UnknownIncomeDebtRatioPerDelinquency <- x$Log.UnknownIncomeDebtRatio - log1p(x$NumberOfTimesPastDue)
  x$Log.UnknownIncomeDebtRatioPer90DaysLate <- x$Log.UnknownIncomeDebtRatio - log1p(x$NumberOfTimes90DaysLate)

  x$Log.NumberRealEstateLoansOrLines <- log(x$NumberRealEstateLoansOrLines)
  x$Log.NumberRealEstateLoansOrLines[!is.finite(x$Log.NumberRealEstateLoansOrLines)] <- 0
  x$NumberRealEstateLoansOrLines <- NULL

  x$NumberOfOpenCreditLinesAndLoans <- NULL

  x$NumberOfTimesPastDue <- NULL
  x$NumberOfTimes90DaysLate <- NULL
  x$NumberOfTime30.59DaysPastDueNotWorse <- NULL
  x$NumberOfTime60.89DaysPastDueNotWorse <- NULL

  x$LowAge <- as.integer(x$age < 18)
  x$Log.age <- log(x$age - 17)
  x$Log.age[x$LowAge == 1] <- 0
  x$age <- NULL

  x
}

trainDF = read.csv("./cs-training.csv")
trainDF_xformed = xform_data(trainDF)
write.csv(trainDF_xformed, "./cs-training_transformed.csv", row.names=F)
testDF = read.csv("./cs-test.csv")
testDF_xformed = xform_data(testDF)
write.csv(testDF_xformed, "./cs-test_transformed.csv", row.names=F)

continuous = function(df, filename){
    #p75 = df %>% select(-X, -SeriousDlqin2yrs) %>% apply(2, function(x) quantile(x, c(.75), na.rm=T))
    p75 = df %>% select(-X, -SeriousDlqin2yrs) %>% apply(2, function(x) sd(x))
    df2 = df %>% select(-X, -SeriousDlqin2yrs)
    df3 = df2[,p75>1]
    df4 = df %>% select(X, SeriousDlqin2yrs) %>% cbind(df3)
    write.csv(df4, filename, row.names=F)
}

continuous(trainDF_xformed, "./cs-training_transformed_continuous.csv")
continuous(testDF_xformed, "./cs-test_transformed_continuous.csv")
