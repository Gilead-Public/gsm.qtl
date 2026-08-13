bars_spec_of <- function(w) {
  jsonlite::fromJSON(as.character(w$x$spec), simplifyVector = FALSE)
}

bars_data_of <- function(w) {
  jsonlite::fromJSON(as.character(w$x$data), simplifyVector = FALSE)
}

plotly_trace_text <- function(plotly_obj) {
  unlist(
    lapply(plotly_obj$x$data, function(trace) {
      if (is.null(trace$text)) {
        character(0)
      } else {
        trace$text
      }
    }),
    use.names = FALSE
  )
}

plotly_trace_names <- function(plotly_obj) {
  unlist(
    lapply(plotly_obj$x$data, function(trace) {
      if (is.null(trace$name)) {
        NA_character_
      } else {
        trace$name
      }
    }),
    use.names = FALSE
  )
}

qtl_test_participant_df <- function() {
  tibble::tribble(
    ~invid , ~country , ~subjid    , ~Source               , ~ietestcd_concat , ~dvdtm                    , ~eligibility_criteria       , ~compyn , ~compreas            ,
    "S01"  , "US"     , "SUBJ-001" , "EDC"                 , "I001;;;E010"    , "2024-01-01;;;2024-01-03" , "Criterion A;;;Criterion B" , "N"     , "Adverse event"      ,
    "S01"  , "US"     , "SUBJ-002" , "Eligibility PD Only" , ""               , "2024-01-02"              , "Criterion C"               , ""      , "Lost to Follow-Up"  ,
    "S01"  , "US"     , "SUBJ-003" , "Neither"             , ""               , "2024-01-04"              , ""                          , "Y"     , ""                   ,
    "S02"  , "CA"     , "SUBJ-004" , "EDC"                 , "I002"           , "2024-02-01"              , "Criterion D"               , "N"     , "Protocol deviation" ,
    "S02"  , "CA"     , "SUBJ-005" , "Neither"             , ""               , "2024-02-03"              , ""                          , "Y"     , ""                   ,
    "S03"  , "GB"     , "SUBJ-006" , "EDC"                 , "I003;;;E020"    , "2024-03-01;;;2024-03-09" , "Criterion E;;;Criterion F" , ""      , "Withdrawal"
  )
}

qtl_test_results_df <- function() {
  tibble::tribble(
    ~GroupID       , ~GroupLevel , ~Numerator , ~Denominator , ~Metric , ~SnapshotDate         , ~Upper_funnel , ~Flag ,
    "StudyA"       , "Study"     ,         10 ,          100 , 0.10    , as.Date("2024-01-01") , 0.12          ,     0 ,
    "Upper_funnel" , "Study"     , NA         , NA           , 0.12    , as.Date("2024-01-01") , NA            , NA    ,
    "Flatline"     , "Study"     , NA         , NA           , 0.05    , as.Date("2024-01-01") , NA            , NA    ,
    "StudyA"       , "Study"     ,         16 ,          100 , 0.16    , as.Date("2024-02-01") , 0.13          ,     2 ,
    "Upper_funnel" , "Study"     , NA         , NA           , 0.13    , as.Date("2024-02-01") , NA            , NA    ,
    "Flatline"     , "Study"     , NA         , NA           , 0.05    , as.Date("2024-02-01") , NA            , NA
  )
}

qtl_test_processor_inputs <- function() {
  df_results <- tibble::tribble(
    ~MetricID , ~GroupID , ~GroupLevel , ~Numerator , ~Denominator , ~Metric , ~SnapshotDate         ,
    "qtl0001" , "StudyA" , "Study"     ,         10 ,          100 , 0.10    , as.Date("2024-01-01") ,
    "qtl0001" , "StudyB" , "Study"     ,         20 ,          120 , 0.1667  , as.Date("2024-01-01")
  )

  df_metrics <- tibble::tribble(
    ~MetricID , ~nPropRate , ~nNumDeviations ,
    "qtl0001" , 0.05       ,               3
  )

  list(dfResults = df_results, dfMetrics = df_metrics)
}

qtl_test_report_params <- function(
  include_metric_ids = c("Analysis_qtl0001", "Analysis_qtl0002")
) {
  df_results <- tibble::tribble(
    ~MetricID          , ~GroupID , ~GroupLevel , ~Numerator , ~Denominator , ~Metric , ~SnapshotDate         , ~Flag ,
    "Analysis_qtl0001" , "StudyA" , "Study"     ,         10 ,          100 , 0.10    , as.Date("2024-01-01") ,     1 ,
    "Analysis_qtl0001" , "StudyA" , "Study"     ,         12 ,          100 , 0.12    , as.Date("2024-02-01") ,     2 ,
    "Analysis_qtl0002" , "StudyA" , "Study"     ,          5 ,          100 , 0.05    , as.Date("2024-01-01") ,     1 ,
    "Analysis_qtl0002" , "StudyA" , "Study"     ,          9 ,          100 , 0.09    , as.Date("2024-02-01") ,     2
  ) %>%
    dplyr::filter(.data$MetricID %in% include_metric_ids)

  df_metrics <- tibble::tribble(
    ~MetricID          , ~nPropRate , ~nNumDeviations ,
    "Analysis_qtl0001" , 0.08       ,               3 ,
    "Analysis_qtl0002" , 0.04       ,               3
  ) %>%
    dplyr::filter(.data$MetricID %in% include_metric_ids)

  df_groups <- tibble::tibble(
    GroupID = "StudyA",
    GroupLevel = "Study"
  )

  listing <- qtl_test_participant_df() %>%
    dplyr::mutate(studyid = "StudyA")

  l_listings <- list()
  if ("Analysis_qtl0001" %in% include_metric_ids) {
    l_listings$qtl0001 <- listing
    l_listings$qtl0001_num <- listing %>% dplyr::filter(Source != "Neither")
  }
  if ("Analysis_qtl0002" %in% include_metric_ids) {
    qtl0002_listing <- listing %>%
      dplyr::mutate(
        compreas = ifelse(compreas == "", "Completed/Ongoing", compreas)
      )
    l_listings$qtl0002 <- qtl0002_listing
    l_listings$qtl0002_num <- qtl0002_listing %>%
      dplyr::filter(compreas != "Completed/Ongoing")
  }

  if (length(l_listings) == 0) {
    l_listings$qtl0001 <- listing
    l_listings$qtl0001_num <- listing %>% dplyr::filter(Source != "Neither")
  }

  list(
    dfResults = df_results,
    dfMetrics = df_metrics,
    dfGroups = df_groups,
    lListings = l_listings
  )
}
