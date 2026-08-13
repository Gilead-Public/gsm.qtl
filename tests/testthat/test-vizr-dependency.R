test_that("gsm.qtl declares and can reach gsm.vizr (#134)", {
  # The migration is meaningless if the renderer is not actually reachable, and
  # a bare Remotes ref would silently resolve to a different branch than the one
  # this work is developed against.
  desc <- read.dcf(system.file("DESCRIPTION", package = "gsm.qtl"))
  expect_true(grepl("gsm.vizr", desc[1, "Imports"], fixed = TRUE))
  expect_true(requireNamespace("gsm.vizr", quietly = TRUE))
  expect_true(is.function(gsm.vizr::bars))
})
