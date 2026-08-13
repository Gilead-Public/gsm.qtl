#' Time Series Widget for QTL
#'
#' A widget that generates a time series of study-level results over time, plotting snapshot
#' date on the x-axis and the outcome, metric, on the y-axis, also drawing an upper funnel and flat line based on
#' an threshold, cited by `nPropRate` of `Analyze_OneSideProp()`.
#'
#' @param dfResults `data.frame` A stacked summary of analysis pipeline output.
#'   Created by passing a list of results returned by [Summarize()] to
#'   [gsm.reporting::BindResults()]. Expected columns: `GroupID`, `GroupLevel`, `Numerator`,
#'   `Denominator`, `Metric`, `Score`, `Flag`, `MetricID`, `StudyID`,
#'   `SnapshotDate`.
#' @param lMetric `list` Metric-specific metadata for use in charts and
#'   reporting. Created by passing an `lWorkflow` object to [gsm.reporting::MakeMetric()] and
#'   turing it into a list. Expected columns: `File`,`MetricID`, `Group`,
#'   `Abbreviation`, `Metric`, `Numerator`, `Denominator`, `Model`, `Score`, and
#'   `strThreshold`. For more details see the Data Model vignette:
#'   `vignette("DataModel", package = "gsm.kri")`.
#' @param dfGroups `data.frame` Group-level metadata dictionary. Created by
#'   passing CTMS site and study data to [gsm.mapping::MakeLongMeta()]. Expected columns:
#'   `GroupID`, `GroupLevel`, `Param`, `Value`.
#' @param vThreshold unused
#' @param strOutcome unused
#' @param bAddGroupSelect unused
#' @param strShinyGroupSelectID unused
#' @param bDebug  `logical` Print debug messages? Default: `FALSE`
#' @noRd

Widget_TimeSeriesQTL <- function(
  dfResults,
  lMetric = NULL,
  dfGroups = NULL,
  vThreshold = NULL,
  strOutcome = "Metric",
  bAddGroupSelect = TRUE,
  strShinyGroupSelectID = "GroupID",
  bDebug = FALSE
) {
  gsm.core::stop_if(
    cnd = !is.data.frame(dfResults),
    "dfResults is not a data.frame"
  )
  gsm.core::stop_if(
    cnd = !(is.null(lMetric) || (is.list(lMetric) && !is.data.frame(lMetric))),
    "lMetric must be a list, but not a data.frame"
  )
  gsm.core::stop_if(
    cnd = !(is.null(dfGroups) || is.data.frame(dfGroups)),
    "dfGroups is not a data.frame"
  )
  gsm.core::stop_if(
    cnd = length(strOutcome) != 1,
    "strOutcome must be length 1"
  )
  gsm.core::stop_if(
    cnd = !is.character(strOutcome),
    "strOutcome is not a character"
  )
  gsm.core::stop_if(
    cnd = !is.logical(bAddGroupSelect),
    "bAddGroupSelect is not a logical"
  )
  gsm.core::stop_if(
    cnd = !is.character(strShinyGroupSelectID),
    "strShinyGroupSelectID is not a character"
  )
  gsm.core::stop_if(cnd = !is.logical(bDebug), "bDebug is not a logical")

  # Parse `vThreshold` from comma-delimited character string to numeric vector.
  if (!is.null(vThreshold)) {
    if (is.character(vThreshold)) {
      vThreshold <- strsplit(vThreshold, ",")[[1]] %>% as.numeric()
    }
  }

  # Disable threshold if outcome is not 'Score'.
  if (strOutcome != "Score") {
    vThreshold <- NULL
  }

  # define widget inputs
  input <- list(
    dfResults = dfResults,
    lMetric = lMetric,
    dfGroups = dfGroups,
    vThreshold = vThreshold,
    strOutcome = strOutcome,
    bAddGroupSelect = bAddGroupSelect,
    strShinyGroupSelectID = strShinyGroupSelectID,
    bDebug = bDebug
  )

  # create widget
  # The bundle is served by gsm.vizr so the report loads exactly one copy of
  # gsm.viz; a widget yaml cannot call a function, so it is attached here.
  widget <- htmlwidgets::createWidget(
    name = "Widget_TimeSeriesQTL",
    purrr::map(
      input,
      ~ jsonlite::toJSON(
        .x,
        null = "null",
        na = "string",
        auto_unbox = TRUE
      )
    ),
    package = "gsm.qtl",
    dependencies = list(gsm.vizr::html_dependency_gsm_viz())
  )

  if (bDebug) {
    viewer <- getOption("viewer")
    options(viewer = NULL)
    print(widget)
    options(viewer = viewer)
  }

  return(widget)
}

#' Shiny bindings for Widget_TimeSeries
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Output and render functions for using Widget_TimeSeries within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a Widget_TimeSeries
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name Widget_TimeSeries-shiny
#'
#' @noRd
Widget_TimeSeriesQTLOutput <- function(
  outputId,
  width = "100%",
  height = "400px"
) {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    "Widget_TimeSeriesQTL",
    width,
    height,
    package = "gsm.qtl"
  )
}

#' @rdname Widget_TimeSeries-shiny
#' @noRd
renderWidget_TimeSeriesQTL <- function(
  expr,
  env = parent.frame(),
  quoted = FALSE
) {
  if (!quoted) {
    expr <- substitute(expr)
  } # force quoted
  htmlwidgets::shinyRenderWidget(
    expr,
    Widget_TimeSeriesQTLOutput,
    env,
    quoted = TRUE
  )
}
