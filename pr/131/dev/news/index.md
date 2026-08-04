# Changelog

## gsm.qtl (development version)

## gsm.qtl v1.3.0

#### Key Enhancements:

- QTL workflows now run on the new `workr` engine. Workflow helpers
  ([`MakeWorkflowList()`](https://gilead-biostats.github.io/gsm.core/reference/MakeWorkflowList.html),
  [`RunWorkflows()`](https://gilead-biostats.github.io/gsm.core/reference/RunWorkflows.html),
  and
  [`RunQuery()`](https://gilead-biostats.github.io/gsm.core/reference/RunQuery.html))
  are now provided by `workr` instead of `gsm.core`, and the bundled
  QTL, metric, and reporting workflows have been updated to match. If
  you run these workflows in your own pipelines, update your calls to
  use `workr::` in place of `gsm.core::`.
- Standardized the metadata on all bundled workflows: every workflow now
  declares an `Active` flag, and the QTL metric workflows (`qtl0001`,
  `qtl0002`) declare a `GenerateRiskSignal` flag, bringing QTL workflows
  in line with the broader `gsm` workflow framework.

#### Other Updates:

- Added `workr` as a package dependency and updated related dependency
  references.

## gsm.qtl v1.2.2

This patch release updates the GitHub action workflows to align with the
new federated action framework in `gsm.utils`

## gsm.qtl v1.2.1

#### Bug Fixes:

- Adds early return for zero-row df to prevent crash in
  [`eligibility_listing()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/eligibility_listing.md)

## gsm.qtl v1.2.0

#### Bug Fixes:

- Fixed issue
  [\#90](https://github.com/Gilead-BioStats/gsm.qtl/issues/90): Updated
  [`eligibility_groupBar()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/eligibility_groupBar.md),
  [`discontinuation_groupBar()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/discontinuation_groupBar.md),
  and
  [`reasons_groupBar()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/reasons_groupBar.md)
  to accept separate `dfNum`/`dfDenom` inputs, correcting count
  alignment for discontinued and ineligible participants.
- Fixed footnote rendering logic so footnotes always display in report
  charts.

#### Key Enhancements:

- Added `bSwapAxes` parameter to
  [`criteria_groupBar()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/criteria_groupBar.md)
  to support swapped axis views (Site/Criteria and Country/Criteria
  tabs).
- Added `calc_plotly_footnote_layout()` utility for consistent plotly
  footnote positioning across charts.
- Removed completed/ongoing categories from reasons bar charts to focus
  on actionable discontinuation reasons.
- Fully namespaced all function calls in QTL report templates
  (`QTL0001.Rmd`, `QTL0002.Rmd`, `Report_QTL.Rmd`) with `gsm.qtl::`
  prefix.
- Expanded test coverage for eligibility, analysis utilities, and QTL
  reporting.

## gsm.qtl v1.1.1

- Updated `critera_groupBar()` and
  [`reasons_groupBar()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/reasons_groupBar.md)
  address small bugs that were affecting barchart’s tooltip text.
- Added
  [`QTL_lineplot_v2()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/QTL_lineplot_v2.md)
  as the new report-facing time-series API using the htmlwidget stack.
- Updated QTL report templates to use
  [`QTL_lineplot_v2()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/QTL_lineplot_v2.md)
  for time-series rendering.
- Kept legacy
  [`QTL_lineplot()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/QTL_lineplot.md)
  available for backward compatibility.

## gsm.qtl v1.1.0

#### Key Enhancements:

- Updated
  [`eligibility_groupBar()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/eligibility_groupBar.md)
  to support counts and percentage bar charts
- Removed suggests of `gsm.mapping`, `gsm.kri`, and `gsm.reporting`

## gsm.qtl v1.0.1

Updated Qualification Report and streamlined qualification tests
structure for the `gsm.qtl` package.

## gsm.qtl v1.0.0

We are excited to announce the first major production ready release of
the `gsm.qtl` package.

#### Key Enhancements:

- Enhance reporting features such as downloads for listings, dynamic
  figure sizing
- A new Github Actions workflow for generation of qualification reports
  has been added
- A new vignette that walks through and describes the QTL flagging
  calculation
- Updated issue templates and contributor gudielines

#### Other Updates:

- Backend related codebase was restructured to fit more closely with
  pre-existing `gsm` data model

For more details on the changes and new features, please refer to the
documentation and pull requests linked to this release.

## gsm.qtl v0.1.0

We are excited to announce the first minor release of the `gsm.qtl`
package, which serves as an extension package that contains the
additional functions, workflows, and document template to generate
reports for quality tolerance limits (QTL). See our `README` for a full
overview and introduction.
