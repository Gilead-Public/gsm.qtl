#' Funnel Plot Analysis with Normal Approximation for Binary and Rate Outcomes.
#'
#' @description `r lifecycle::badge("stable")`
#'
#' Creates analysis results data for percentage/rate data using funnel plot
#' method with normal approximation.
#'
#'
#' @section Statistical Methods: This function applies funnel plots using
#'   a fixed proportion/rate and number of standard deviations according to the
#'   one-sided Z proportion test.
#'
#' @param dfTransformed `data.frame` Transformed data for analysis. Data should
#'   have one record per site with expected columns: `GroupID`, `GroupLevel`,
#'   `Numerator`, `Denominator`, and `Metric`. For more details see the Data
#'   Model vignette: `vignette("DataModel", package = "gsm.core")`. For this
#'   function, `dfTransformed` should typically be created using
#'   [`gsm.core::Transform_Rate()`].
#' @param nPropRate a numeric, between 0 and 1, that represents a proportion of
#' comparison, e.g. a historic screen failure rate
#' @param nNumDeviations a non-negative numeric, e.g. '3', standard deviations away from the value
#' provided in `nPropRate` to calculate a threshold to which the `Metric` should be flagged
#'
#' @return `data.frame` with one row per study-snapshot with columns: GroupID, GroupLevel, Numerator,
#'   Denominator, Metric, Flag, Score
#'
#' @examples
#' # Binary
#' dftransformed <- tibble::tribble(
#'   ~GroupID, ~GroupLevel, ~Numerator, ~Denominator, ~Metric,
#'   "ABC", "Study", 25, 100, 0.25
#' )
#'
#' dfAnalyzed <- Analyze_OneSideProp(dftransformed, nPropRate = 0.01, nNumDeviations = 3)
#'
#' @export

Analyze_OneSideProp <- function(
  dfTransformed,
  nPropRate = 0.1,
  nNumDeviations = 3
) {
  stop_if(cnd = !is.data.frame(dfTransformed), message = "dfTransformed is not a data.frame")
  stop_if(
    cnd = !all(c("GroupID", "GroupLevel", "Denominator", "Numerator", "Metric") %in% names(dfTransformed)),
    message = "One or more of these columns not found: GroupID, GroupLevel, Denominator, Numerator, Metric"
  )
  stop_if(cnd = !all(!is.na(dfTransformed[["GroupID"]])), message = "NA value(s) found in GroupID")
  stop_if(cnd = (nPropRate >= 1 | nPropRate <= 0), message = "`nPropRate` must be a value between 0 and 1 (exclusive).")
  stop_if(cnd = nNumDeviations < 0, message = "`nNumDeviations` must be non-negative.")

  dfScore <- dfTransformed %>%
    mutate(
      vMu = nPropRate,  # nPropRate is what we're trying to compare against
      z_0 =  (.data$Metric - .data$vMu) / sqrt(.data$vMu * (1 - .data$vMu) / .data$Denominator), # z-star value that is dependent on number of participants
      Upper_funnel = nPropRate + nNumDeviations * sqrt(nPropRate * (1 - nPropRate) / sum(.data$Denominator)), # calculates upper funnel, lower one doesn't matter
      Flag = case_when(
        .data$Metric >= .data$Upper_funnel ~ 2, # Flag instances where the metric exceeds the funnel
        (.data$Metric >= .data$vMu & .data$Metric < .data$Upper_funnel) ~ 1, # Do we need a flag for the middle, break nPropRate but less than funnel?
        TRUE ~ 0 # otherwise no flag
      )
    )

  # dfAnalyzed -----------------------------------------------------------------
  dfAnalyzed <- dfScore %>%
    select(
      "GroupID",
      "GroupLevel",
      "Numerator",
      "Denominator",
      "Metric",
      "Flag",
      "Score" = z_0
    )
  return(dfAnalyzed)
}
