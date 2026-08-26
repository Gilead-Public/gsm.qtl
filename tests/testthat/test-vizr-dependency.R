test_that("gsm.qtl declares and can reach gsm.vizr (#134)", {
  # The migration is meaningless if the renderer is not actually reachable.
  desc <- read.dcf(system.file("DESCRIPTION", package = "gsm.qtl"))
  expect_true(grepl("gsm.vizr", desc[1, "Imports"], fixed = TRUE))
  expect_true(requireNamespace("gsm.vizr", quietly = TRUE))
  expect_true(is.function(gsm.vizr::bars))
})

test_that("the gsm.vizr Remotes entry pins an explicit ref (#134)", {
  # A bare `pkg=owner/repo` ref resolves to whatever the default branch happens
  # to be, so an install could silently pick up a different build than the one
  # this package is developed and released against.
  desc <- read.dcf(system.file("DESCRIPTION", package = "gsm.qtl"))
  skip_if_not("Remotes" %in% colnames(desc), "DESCRIPTION declares no Remotes")

  entries <- trimws(strsplit(desc[1, "Remotes"], ",")[[1]])
  gsm_vizr <- grep("gsm\\.vizr", entries, value = TRUE)

  expect_length(gsm_vizr, 1)
  expect_match(gsm_vizr, "@[^@]+$")
})

test_that("gsm.qtl ships no vendored gsm.viz bundle of its own (#134)", {
  # Two bundles on one page means two top-level `var gsmViz` declarations and the
  # later script silently wins; the report renders bars and the time series
  # together, so the only safe number of vendored copies is zero.
  lib <- system.file("htmlwidgets", "lib", package = "gsm.qtl")
  skip_if(!nzchar(lib), "htmlwidgets/lib not installed")
  bundles <- grep(
    "^gsm\\.viz-",
    list.dirs(lib, full.names = FALSE, recursive = FALSE),
    value = TRUE
  )
  expect_identical(bundles, character(0))
  expect_false(file.exists(file.path(lib, "barChartQTL.js")))
})

test_that("the time series widget carries the shared gsm.viz dependency (#134)", {
  w <- QTL_lineplot_v2(
    dfResults = qtl_test_results_df(),
    strQTL = "Ineligibility Rate"
  )
  dep_names <- vapply(w$dependencies, function(d) d$name, character(1))

  expect_true("gsmViz" %in% dep_names)
  gsmviz <- w$dependencies[[which(dep_names == "gsmViz")[1]]]
  expect_identical(gsmviz$version, "2.4.1")
})

test_that("the shared widget shims survive the barchart widget deletion (#134)", {
  # Five of the six lib shims are also declared by Widget_TimeSeriesQTL.yaml.
  lib <- system.file("htmlwidgets", "lib", package = "gsm.qtl")
  skip_if(!nzchar(lib), "htmlwidgets/lib not installed")
  expect_true(all(file.exists(file.path(
    lib,
    c(
      "clickCallback.js",
      "addWidgetControls2.js",
      "widgetControls.css",
      "addSelectControl2.js",
      "getGroups.js",
      "addOutcomeSelect2.js",
      "timeSeriesQTL.js"
    )
  ))))
})
