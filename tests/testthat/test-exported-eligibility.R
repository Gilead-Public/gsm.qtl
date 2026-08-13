test_that("eligibility_groupBar builds a horizontal identity stack (#14, #15, #21, #22, #60, #134)", {
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(Source != "Neither")

  out <- eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  )
  spec <- bars_spec_of(out)

  expect_s3_class(out, "bars")
  expect_s3_class(out, "htmlwidget")
  expect_identical(
    spec$mapping,
    list(x = "invid", y = "totals", fill = "fillcol")
  )
  expect_identical(spec$stat, "identity")
  expect_identical(spec$orientation, "horizontal")
  expect_identical(spec$position, "stack")
  expect_identical(spec$labels$title, "Participant Count by Site")
  expect_identical(spec$scales$x$label, "Site")
  expect_identical(spec$scales$y$label, "Participant Count")
  expect_identical(spec$scales$fill$label, "Eligibility")
  expect_identical(spec$scales$fill$colors$Ineligible, "#FF5859")
  # expect_equal, not expect_identical: jsonlite parses a whole JSON number back
  # as an integer, so an identical() check against 25 would fail on type alone.
  expect_true(spec$theme$dynamicSizing)
  expect_equal(spec$theme$pxPerCategory, 25)
  expect_identical(out$x$minHeight, 500)
})

test_that("eligibility_groupBar aggregates counts and percentages per group (#60, #134)", {
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(Source != "Neither")

  rows <- bars_data_of(eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  ))
  s01 <- Filter(function(r) r$invid == "S01", rows)

  # S01 has 2 ineligible participants and 1 "Neither" out of 3.
  expect_equal(sum(vapply(s01, function(r) r$totals, numeric(1))), 3)
  ineligible <- Filter(function(r) r$fillcol == "Ineligible", s01)[[1]]
  expect_equal(ineligible$totals, 2)
  expect_equal(ineligible$perc, 66.7)
})

test_that("eligibility_groupBar bPercentage switches to a filled stack (#60, #134)", {
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(Source != "Neither")

  spec <- bars_spec_of(eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site",
    bPercentage = TRUE
  ))

  expect_identical(spec$position, "fill")
  # stat must be ABSENT here: gsm.viz only rewrites fill -> {stack, percent}
  # when stat is unset, so pinning "identity" would draw raw counts.
  expect_null(spec$stat)
  expect_identical(spec$labels$title, "Participant Percentage by Site")
  expect_identical(spec$scales$y$label, "Participant Percentage")
})

test_that("eligibility_groupBar carries the exclusion footnote as a caption (#90, #134)", {
  df <- dplyr::bind_rows(
    qtl_test_participant_df(),
    tibble::tribble(
      ~invid , ~country , ~subjid    , ~Source   , ~ietestcd_concat , ~dvdtm       , ~eligibility_criteria , ~compyn , ~compreas ,
      "S04"  , "US"     , "SUBJ-007" , "Neither" , ""               , "2024-04-01" , ""                    , "Y"     , ""        ,
      "S04"  , "US"     , "SUBJ-008" , "Neither" , ""               , "2024-04-02" , ""                    , ""      , ""
    )
  )
  dfNum <- df %>% dplyr::filter(Source != "Neither")

  with_excluded <- bars_spec_of(eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  ))
  without_excluded <- bars_spec_of(eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = dfNum,
    varGroupID = invid,
    strGroupLabel = "Site"
  ))

  expect_match(with_excluded$labels$captions, "Excludes 1 site\\(s\\)")
  expect_match(with_excluded$labels$captions, "no ineligible participants")
  expect_null(without_excluded$labels$captions)
})

test_that("eligibility_groupBar orders categories most-frequent-first (#134)", {
  # Chart.js draws scales.x.order[1] at the top of a horizontal chart, so the
  # order array is today's ggplot y-axis read top-to-bottom.
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(Source != "Neither")

  spec <- bars_spec_of(eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  ))

  expect_identical(unlist(spec$scales$x$order), c("S01", "S02", "S03"))
})

test_that("eligibility_groupBar tooltip reads the datum row (#134)", {
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(Source != "Neither")

  spec <- bars_spec_of(eligibility_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  ))

  expect_true(is.character(spec$tooltip$formatter))
  expect_match(spec$tooltip$formatter, "details.datum", fixed = TRUE)
  expect_match(spec$tooltip$formatter, "'Count: '", fixed = TRUE)
  expect_match(spec$tooltip$formatter, "'Percentage: '", fixed = TRUE)
  expect_match(spec$tooltip$formatter, "'Site: '", fixed = TRUE)
  expect_match(spec$tooltip$formatter, "'Eligibility Status: '", fixed = TRUE)
})

test_that("eligibility_sourceBar returns plotly object (#14, #21, #22)", {
  df <- qtl_test_participant_df()
  out <- eligibility_sourceBar(df = df)
  built <- plotly::plotly_build(out)

  expect_s3_class(out, "plotly")

  source_text <- plotly_trace_text(out)

  expect_true(any(grepl("Source: EDC", source_text, fixed = TRUE)))
  expect_match(
    built$x$layout$title$text,
    "Participant Count by Category/Source",
    fixed = TRUE
  )
})

test_that("criteria_groupBar uses grouping and label arguments (#14, #21, #22, #23)", {
  df <- qtl_test_participant_df() %>%
    dplyr::mutate(
      ietestcd_concat = gsub(";;;", ",", ietestcd_concat, fixed = TRUE)
    )

  out <- criteria_groupBar(df = df, varGroupID = invid, strGroupLabel = "Site")
  built <- plotly::plotly_build(out)

  expect_s3_class(out, "plotly")

  criteria_text <- plotly_trace_text(out)
  expect_true(any(grepl("Criteria:", criteria_text, fixed = TRUE)))
  expect_true(any(grepl("Site:", criteria_text, fixed = TRUE)))
  expect_true(any(grepl("Criteria: I001", criteria_text, fixed = TRUE)))
  expect_true(any(grepl("Criteria: E010", criteria_text, fixed = TRUE)))
  expect_false(any(grepl("Criteria: I001, E010", criteria_text, fixed = TRUE)))
  expect_match(built$x$layout$title$text, "Criteria by Site", fixed = TRUE)
})

test_that("criteria_groupBar uses grouping and label arguments correctly when swapping axes (#90)", {
  df <- qtl_test_participant_df() %>%
    dplyr::mutate(
      ietestcd_concat = gsub(";;;", ",", ietestcd_concat, fixed = TRUE)
    )

  out <- criteria_groupBar(
    df = df,
    varGroupID = invid,
    strGroupLabel = "Site",
    bSwapAxes = TRUE
  )
  built <- plotly::plotly_build(out)

  expect_s3_class(out, "plotly")

  criteria_text <- plotly_trace_text(out)
  expect_true(any(grepl("Criteria:", criteria_text, fixed = TRUE)))
  expect_true(any(grepl("Site:", criteria_text, fixed = TRUE)))
  expect_match(built$x$layout$title$text, "Site by Criteria", fixed = TRUE)
})

test_that("eligibility_listing covers df and download arguments (#21, #22, #24, #25)", {
  df <- qtl_test_participant_df()

  out_download <- eligibility_listing(df = df, download = TRUE)
  out_gt <- eligibility_listing(df = df, download = FALSE)

  expect_s3_class(out_download, "data.frame")
  expect_true(
    inherits(out_gt, "shiny.tag") || inherits(out_gt, "shiny.tag.list")
  )
  expect_true(all(
    c("Country", "Site", "Participant ID", "Which I/E") %in% names(out_download)
  ))
  expect_true(nrow(out_download) > 0)
})

test_that("eligibility_listing handles zero-row data frame (#108)", {
  df <- qtl_test_participant_df()[0, ]

  out_download <- eligibility_listing(df = df, download = TRUE)
  out_gt <- eligibility_listing(df = df, download = FALSE)

  expect_s3_class(out_download, "data.frame")
  expect_equal(nrow(out_download), 0)
  expect_s3_class(out_gt, "gt_tbl")
})

test_that("eligibility_listing handles all-NA dvdtm and eligibility_criteria (#108)", {
  df <- tibble::tribble(
    ~invid , ~country , ~subjid    , ~Source , ~ietestcd_concat , ~dvdtm        , ~eligibility_criteria , ~compyn , ~compreas ,
    "S01"  , "US"     , "SUBJ-001" , "EDC"   , "I001"           , NA_character_ , NA_character_         , "N"     , "AE"
  )

  out <- eligibility_listing(df = df, download = TRUE)

  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 1)
  expect_true("PD Date1" %in% names(out))
  expect_true("PD Term1" %in% names(out))
})

test_that("scrollable_gt uses height and width arguments (#21, #22)", {
  gt_tbl <- gt::gt(head(qtl_test_participant_df(), 2))
  out <- scrollable_gt(
    gt_tbl = gt_tbl,
    height = "200px",
    min_table_width = "800px"
  )

  expect_true(inherits(out, "shiny.tag") || inherits(out, "shiny.tag.list"))
  out_html <- as.character(out)
  expect_match(out_html, "max-height: 200px", fixed = TRUE)
  expect_match(out_html, "min-width: 800px", fixed = TRUE)
})

test_that("Eligibility_Overview uses all arguments (#21, #22, #70)", {
  df_results <- qtl_test_results_df()

  out <- Eligibility_Overview(
    dfResults = df_results,
    dSnapshot = as.Date("2024-01-01"),
    strNum = "Numerator N",
    strDenom = "Denominator N",
    strQTL = "Eligibility Rate"
  )

  expect_s3_class(out, "gt_tbl")
})
