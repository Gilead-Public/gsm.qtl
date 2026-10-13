# Report_QTL function

**\[stable\]**

This function generates a QTL report based on the provided inputs.

## Usage

``` r
Report_QTL(
  dfResults = NULL,
  dfMetrics = NULL,
  dfGroups = NULL,
  lListings = NULL,
  strOutputDir = getwd(),
  strOutputFile = NULL,
  strInputPath = system.file("report", "Report_QTL.Rmd", package = "gsm.qtl")
)
```

## Arguments

- dfResults:

  A results `data.frame` from the output of
  `gsm.reporting::BindResults()` used to create a variety of
  visualizations like the line plot, bar plot.

- dfMetrics:

  A results `data.frame` from the output of
  `gsm.reporting::MakeMetric()`

- dfGroups:

  A groups `data.frame` from the output of the `Groups.yaml` of
  `gsm.reporting`used to create a variety of visualizations like the
  line plot, bar plot.

- lListings:

  A `list` of `data.frame`s that are used as listings to represent
  participants that are the numerators of the visualizations from
  `dfResults`.

- strOutputDir:

  The output directory path for the generated report. If not provided,
  the report will be saved in the current working directory.

- strOutputFile:

  The output file name for the generated report. If not provided, the
  report will be named based on the study ID, Group Level and Date.

- strInputPath:

  Path to template of the report

## Value

File path of the saved report html is returned invisibly. Save to object
to view absolute output path.
