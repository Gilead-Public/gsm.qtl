# gsm.qtl

# Good Statistical Monitoring QTL `{gsm.qtl}` R package

This README provides a high-level overview of `gsm.qtl`; see the
[package website](https://gilead-biostats.github.io/gsm.qtl/) for
additional details.

The Good Statistical Monitoring or `gsm` suite of R packages provides a
framework for statistical data monitoring. `gsm.qtl` is an extension
package that contains the additional functions, workflows, and document
template to generate reports for quality tolerance limits (QTL). See
[`gsm.core`](https://github.com/Gilead-BioStats/gsm.core) for an
overview of the ecosystem.

# Background

The `gsm.qtl` package calculates study level metrics that can be
represented by some sort `M`/`N` value that is used to evaluate a
particular QTL of a particular study, such as inclusion/exclusion
criteria violations, early study discontinuation, etc.

# Mapping

Datasets necessary to calculate a particular QTL can be requested or
customized based off of previously existing mappings, see
[`gsm.mapping`](https://github.com/Gilead-BioStats/gsm.mapping).
Additional mappings that have been added to support `gsm.qtl` include
the `IE` and `EXCLUSION` mappings.

# Metrics

`qtlxxxx` metric yaml files have been added to calculate study level
QTLs, these files follow similar structure to those found in
[`gsm.kri`](https://github.com/Gilead-BioStats/gsm.kri).

# Reporting

`gsm.qtl` has a report template to produce the data visualizations,
widgets and tables that ultimately go into an html QTL report.

## Installation

You can install the latest release of gsm.qtl from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.qtl@*release")
```

You can install the development version of gsm.qtl from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("Gilead-BioStats/gsm.qtl")
```

## Sample Code

This is a basic example showing how to create interactive widget
visualizations based on reporting outputs from the `{gsm.reporting}`
package:

``` r

library(gsm.datasim)
library(gsm.mapping)
library(gsm.reporting)
library(gsm.core)
library(gsm.kri)
library(purrr)
library(dplyr)
library(gsm.qtl)
set.seed(1234)

# Single Study
ie_data <- generate_rawdata_for_single_study(
  SnapshotCount = 6,
  SnapshotWidth = "months",
  ParticipantCount = 1000,
  SiteCount = 10,
  StudyID = "ABC",
  workflow_path = "workflow/1_mappings",
  mappings = c("IE", "PD", "STUDCOMP"),
  package = "gsm.mapping",
  desired_specs = NULL
)

mappings_wf <- workr::MakeWorkflowList(
  strNames =c("SUBJ", "ENROLL", "IE", "PD", "STUDY", "SITE", "COUNTRY", "EXCLUSION", "STUDCOMP"),
  strPath = "workflow/1_mappings",
  strPackage = "gsm.mapping"
)
mappings_spec <- gsm.mapping::CombineSpecs(mappings_wf)
metrics_wf <- workr::MakeWorkflowList(strNames = c("qtl0001", "qtl0002"), strPath = "workflow/2_metrics", strPackage = "gsm.qtl")
reporting_wf <- workr::MakeWorkflowList(strNames = c("Results", "Groups"), strPath = "workflow/3_reporting", strPackage = "gsm.reporting")

lRaw <- map_depth(ie_data, 1, gsm.mapping::Ingest, mappings_spec)
mapped <- map_depth(lRaw, 1, ~ workr::RunWorkflows(mappings_wf, .x))
analyzed <- map_depth(mapped, 1, ~workr::RunWorkflows(metrics_wf, .x))
reporting <- map2(mapped, analyzed, ~ workr::RunWorkflows(reporting_wf, c(.x, list(lAnalyzed = .y, lWorkflows = metrics_wf))))

dates <- names(ie_data) %>% as.Date
reporting <- map2(reporting, dates, ~{
  .x$Reporting_Results$SnapshotDate <- .y
  .x
})

# Bind multiple snapshots of data together
all_reportingResults <- do.call(dplyr::bind_rows, lapply(reporting, function(x) x$Reporting_Results)) 


# Only need 1 reporting group object
all_reportingGroups <- reporting[[length(reporting)]]$Reporting_Groups

report_listings <- list(qtl0001 = mapped$`2012-06-30`$Mapped_EXCLUSION,
                        qtl0002 = left_join(mapped$`2012-06-30`$Mapped_STUDCOMP,
                                            select(mapped$`2012-06-30`$Mapped_SUBJ, subjid, country),
                                            by = "subjid"))

# Test if new Report_QTL rmd works
gsm.kri::RenderRmd(
  lParams = list(
    dfResults = all_reportingResults,
    dfGroups = all_reportingGroups,
    lListings = report_listings
  ),
  strOutputDir = getwd(),
  strOutputFile = "test.html",
  strInputPath = system.file("report/Report_QTL.Rmd", package = "gsm.qtl")
)
```
