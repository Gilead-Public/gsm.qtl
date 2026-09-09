# Renders the QTL report fixture for the Playwright specs.
# Run from the package root: Rscript tests/playwright/render-fixture.R
devtools::load_all(".", quiet = TRUE)
dir.create("tests/playwright/fixture", showWarnings = FALSE, recursive = TRUE)
# The report template lives inside the package, and rmarkdown resolves a
# relative output path against the template rather than the working directory,
# so the output directory has to be absolute.
output_dir <- normalizePath("tests/playwright/fixture", mustWork = TRUE)
params <- gsm.qtl:::example_lparams
Report_QTL(
  dfResults = params$dfResults,
  dfMetrics = params$dfMetrics,
  dfGroups = params$dfGroups,
  lListings = params$lListings,
  strOutputDir = output_dir,
  strOutputFile = "qtl-report.html"
)
cat("Rendered tests/playwright/fixture/qtl-report.html\n")
