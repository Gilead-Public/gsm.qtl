# Funnel Plot Analysis with Normal Approximation for Binary and Rate Outcomes.

**\[stable\]**

Creates analysis results data for percentage/rate data using funnel plot
method with normal approximation.

## Usage

``` r
Analyze_OneSideProp(dfTransformed, nPropRate = 0.1, nNumDeviations = 3)
```

## Arguments

- dfTransformed:

  `data.frame` Transformed data for analysis. Data should have one
  record per site with expected columns: `GroupID`, `GroupLevel`,
  `Numerator`, `Denominator`, and `Metric`. For more details see the
  Data Model vignette: `vignette("DataModel", package = "gsm.core")`.
  For this function, `dfTransformed` should typically be created using
  [`gsm.core::Transform_Rate()`](https://gilead-biostats.github.io/gsm.core/reference/Transform_Rate.html).

- nPropRate:

  a numeric, between 0 and 1, that represents a proportion of
  comparison, e.g. a historic screen failure rate

- nNumDeviations:

  a numeric, e.g. '3', standard deviations away from the value provided
  in `nPropRate` to calculate a threshold to which the `Metric` should
  be flagged

## Value

`data.frame` with one row per study-snapshot with columns: GroupID,
GroupLevel, Numerator, Denominator, Metric, Flag, Score

## Statistical Methods

This function applies funnel plots using a fixed proportion/rate and
number of standard deviations according to the one-sided Z proportion
test.

## Examples

``` r
# Binary
dftransformed <- tibble::tribble(
  ~GroupID, ~GroupLevel, ~Numerator, ~Denominator, ~Metric,
  "ABC", "Study", 25, 100, 0.25
)

dfAnalyzed <- Analyze_OneSideProp(dftransformed, nPropRate = 0.01, nNumDeviations = 3)
```
