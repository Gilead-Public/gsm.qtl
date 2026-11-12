test_that("Analyze One Side Prop works for Study, when nProRate is clearly violated (#5, #11, #46)", {
  test_transformed <- tibble::tribble(
    ~GroupID, ~GroupLevel, ~Numerator, ~Denominator, ~Metric,
    "ABC", "Study", 25, 100, 0.25
  )
  nPropRate <- 0.01
  nNumDeviations <- 3

  res <- Analyze_OneSideProp(test_transformed, nPropRate = nPropRate, nNumDeviations = nNumDeviations)
  # There should only be 1 QTL Metric per study
  expect_equal(nrow(res), 1)

  flag_crit <- nPropRate + 3*sqrt( (nPropRate*(1-nPropRate)) / res$Denominator)
  actual_flag <- res$Flag
  expected_flag <- case_when(res$Metric >= flag_crit ~ 2,
                             res$Metric < flag_crit & res$Metric > nPropRate ~ 1,
                             .default = 0)

  # The flagging should be working as expected
  expect_equal(actual_flag, expected_flag)
})


test_that("Analyze One Side Prop works for Study, when nPropRate is the same (#5, #11, #46)", {
  test_transformed <- tibble::tribble(
    ~GroupID, ~GroupLevel, ~Numerator, ~Denominator, ~Metric,
    "ABC", "Study", 25, 100, 0.25
  )
  nPropRate <- 0.25
  nNumDeviations <- 1

  res <- Analyze_OneSideProp(test_transformed, nPropRate = nPropRate, nNumDeviations = nNumDeviations)
  # There should only be 1 QTL Metric per study
  expect_equal(nrow(res), 1)

  flag_crit <- nPropRate + 3*sqrt( (nPropRate*(1-nPropRate)) / res$Denominator)
  actual_flag <- res$Flag
  expected_flag <- case_when(res$Metric >= flag_crit ~ 2,
                             res$Metric < flag_crit & res$Metric >= nPropRate ~ 1,
                             .default = 0)

  # The flagging should be working as expected
  expect_equal(actual_flag, expected_flag)
})


test_that("Analyze_OneSideProp returns two or three flags based on nNumDeviations (#145)", {
  test_transformed <- tibble::tribble(
    ~GroupID, ~GroupLevel, ~Numerator, ~Denominator, ~Metric,
    "A", "Study", 1, 100, 0.01,
    "B", "Study", 4, 100, 0.04,
    "C", "Study", 6, 100, 0.06
  )

  flags_with_deviations <- Analyze_OneSideProp(
    test_transformed,
    nPropRate = 0.03,
    nNumDeviations = 3
  )$Flag
  flags_without_deviations <- Analyze_OneSideProp(
    test_transformed,
    nPropRate = 0.03,
    nNumDeviations = 0
  )$Flag

  expect_setequal(unique(flags_with_deviations), c(0, 1, 2))
  expect_setequal(unique(flags_without_deviations), c(0, 2))
  expect_error(
    Analyze_OneSideProp(
      test_transformed,
      nPropRate = 0.03,
      nNumDeviations = -1
    ),
    "`nNumDeviations` must be non-negative"
  )
})
