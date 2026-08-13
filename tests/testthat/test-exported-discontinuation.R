test_that("discontinuation_groupBar builds a horizontal identity stack (#14, #21, #22, #76, #90, #134)", {
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(compyn == "N")

  out <- discontinuation_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  )
  spec <- bars_spec_of(out)

  expect_s3_class(out, "bars")
  expect_identical(
    spec$mapping,
    list(x = "invid", y = "totals", fill = "fillcol")
  )
  expect_identical(spec$stat, "identity")
  expect_identical(spec$orientation, "horizontal")
  expect_identical(spec$position, "stack")
  expect_identical(spec$labels$title, "Participant Count by Site")
  expect_identical(spec$scales$fill$label, "Study Status")
  expect_identical(
    spec$scales$fill$colors$`Premature Discontinuation`,
    "#FF5859"
  )
  expect_identical(spec$scales$fill$colors$`Completed/Ongoing`, "#00BFC4")
  # Stack order comes from the colour-map key order, not scales$fill$order, so
  # the keys must stay in the published ggplot fill order.
  expect_identical(
    names(spec$scales$fill$colors),
    c("Completed/Ongoing", "Premature Discontinuation")
  )
  expect_match(spec$labels$captions, "Excludes .* site\\(s\\)")
  expect_match(spec$labels$captions, "prematurely discontinued participants")
  expect_match(
    spec$tooltip$formatter,
    "'Discontinuation Status: '",
    fixed = TRUE
  )
})

test_that("discontinuation_groupBar honours varStatus and valuesDiscontinued (#76, #134)", {
  df <- qtl_test_participant_df()
  dfNum <- df %>% dplyr::filter(compyn == "N")

  pd_count <- function(rows, group) {
    hit <- Filter(
      function(r) r$invid == group && r$fillcol == "Premature Discontinuation",
      rows
    )
    if (length(hit) == 0) 0 else hit[[1]]$totals
  }

  default_rows <- bars_data_of(discontinuation_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site"
  ))
  custom_rows <- bars_data_of(discontinuation_groupBar(
    dfNum = dfNum,
    dfDenom = df,
    varGroupID = invid,
    strGroupLabel = "Site",
    varStatus = compyn,
    valuesDiscontinued = c("Y", "N")
  ))

  # S02 is one compyn == "N" participant and one compyn == "Y" participant, so
  # counting "Y" as a discontinuation too moves the second one across.
  expect_equal(pd_count(default_rows, "S02"), 1)
  expect_equal(pd_count(custom_rows, "S02"), 2)
})

test_that("discontinuation_reasonBar counts by reason with total labels (#14, #21, #22, #134)", {
  df <- qtl_test_participant_df()
  out <- discontinuation_reasonBar(df = df, varCompreas = compreas)
  spec <- bars_spec_of(out)
  rows <- bars_data_of(out)

  expect_s3_class(out, "bars")
  expect_identical(
    spec$mapping,
    list(x = "compreas", y = "n", fill = "compreas")
  )
  expect_identical(spec$stat, "identity")
  expect_identical(spec$orientation, "horizontal")
  expect_identical(spec$labels$title, "Participant Count by Reasons")
  expect_identical(spec$scales$x$label, "Discontinuation Reasons")
  expect_identical(spec$scales$y$label, "Participant Count")
  expect_identical(spec$scales$fill$label, "Discontinuation Reasons")
  # compreas is blank for two fixture rows. A blank level cannot carry a named
  # colour through the spec because jsonlite substitutes the positional index
  # for an empty JSON key, so assert the named levels that do round-trip.
  expected <- .qtl_ggplot_hue(df$compreas)
  named <- names(expected)[nzchar(names(expected))]
  expect_identical(spec$scales$fill$colors[named], as.list(expected[named]))
  expect_true(spec$annotations$labels$total$display)

  reasons <- vapply(rows, function(r) r$compreas, character(1))
  expect_true("Adverse event" %in% reasons)
})

test_that("reasons_groupBar stacks reasons by group (#14, #21, #22, #134)", {
  df <- qtl_test_participant_df()

  out <- reasons_groupBar(
    df = df,
    varGroupID = invid,
    varCompreas = compreas,
    strGroupLabel = "Site"
  )
  spec <- bars_spec_of(out)

  expect_s3_class(out, "bars")
  expect_identical(spec$mapping, list(x = "compreas", y = "n", fill = "invid"))
  expect_identical(spec$stat, "identity")
  expect_identical(spec$orientation, "horizontal")
  expect_identical(spec$labels$title, "Discontinuation Reason by Site")
  expect_identical(spec$scales$x$label, "Reason")
  expect_identical(spec$scales$y$label, "Reason Count")
  expect_identical(spec$scales$fill$label, "Site")
  expect_identical(unlist(spec$scales$fill$colors), .qtl_ggplot_hue(df$invid))
  expect_true(spec$annotations$labels$total$display)
  expect_match(
    spec$tooltip$formatter,
    "'Discontinuation Reason: '",
    fixed = TRUE
  )
  expect_match(spec$tooltip$formatter, "'Site: '", fixed = TRUE)
})

test_that("reasons_groupBar swaps category and fill when bSwapAxes is TRUE (#90, #134)", {
  df <- qtl_test_participant_df()

  spec <- bars_spec_of(reasons_groupBar(
    df = df,
    varGroupID = invid,
    varCompreas = compreas,
    strGroupLabel = "Site",
    bSwapAxes = TRUE
  ))

  expect_identical(spec$mapping, list(x = "invid", y = "n", fill = "compreas"))
  expect_identical(spec$labels$title, "Site by Discontinuation Reason")
  expect_identical(spec$scales$x$label, "Site")
  expect_identical(spec$scales$fill$label, "Reason")
  # The fixture carries blank compreas values, which cannot round-trip as a
  # named JSON key; assert the named levels that do.
  expected <- .qtl_ggplot_hue(df$compreas)
  named <- names(expected)[nzchar(names(expected))]
  expect_identical(spec$scales$fill$colors[named], as.list(expected[named]))
})

test_that("discontinuation_map_reasons respects yaml_path (#21, #22)", {
  df <- qtl_test_participant_df()

  yaml_file <- tempfile(fileext = ".yaml")
  writeLines(
    c(
      "steps:",
      "  - params:",
      "      reasons:",
      "        - Adverse event",
      "        - Withdrawal"
    ),
    con = yaml_file
  )

  out <- discontinuation_map_reasons(df = df, yaml_path = yaml_file)

  expect_s3_class(out, "data.frame")
  expect_true(all(out$compreas %in% c("Adverse event", "Withdrawal")))
  expect_false("Protocol deviation" %in% out$compreas)
})
