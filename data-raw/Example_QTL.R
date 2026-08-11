library(gsm.qtl)
library(gsm.datasim)
library(gsm.kri)
library(dplyr)
library(purrr)
devtools::load_all(".")

# No need to resimulate everything with the advent of the internal data - scroll to bottom to just test report
# ----------------------------------------------------------------------
set.seed(1234)

# Single Study
ie_data <- gsm.datasim::generate_rawdata_for_single_study(
  SnapshotCount = 6,
  SnapshotWidth = "months",
  ParticipantCount = 1000,
  SiteCount = 50,
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
metrics_wf <- workr::MakeWorkflowList(strNames = c("qtl0001", "qtl0002"), strPath = "inst/workflow/2_metrics")
reporting_wf <- workr::MakeWorkflowList(strNames = c("Results", "Groups", "Metrics"), strPath = "workflow/3_reporting", strPackage = "gsm.reporting")


lRaw <- map_depth(ie_data, 1, gsm.mapping::Ingest, mappings_spec)
mapped <- map_depth(lRaw, 1, ~ workr::RunWorkflows(mappings_wf, .x))
# Cleanup discontinuation reasons instead of modifying gsm.datasim
mapped <- map(mapped, ~ {
  .x$Mapped_STUDCOMP <- .x$Mapped_STUDCOMP %>%
    {
      discontinued_idx <- which(.$compyn == "N")
      sampled_reasons <- rep(NA_character_, nrow(.))

      if (length(discontinued_idx) > 0) {
        sampled_reasons[discontinued_idx] <- sample(
          c("Withdrew Consent", "Death", "Lost to Follow-Up"),
          size = length(discontinued_idx),
          replace = TRUE
        )
      }

      dplyr::mutate(
        .,
        compreas = dplyr::case_when(
          compyn == "Y" ~ "",
          compyn == "N" ~ sampled_reasons,
          TRUE ~ ""
        )
      )
    } %>%
    filter(subjid %in% .x$Mapped_SUBJ$subjid)

  .x
})
analyzed <- map_depth(mapped, 1, ~workr::RunWorkflows(metrics_wf, .x))
reporting <- map2(mapped, analyzed, ~ workr::RunWorkflows(reporting_wf, c(.x, list(lAnalyzed = .y, lWorkflows = metrics_wf))))

# Fix `SnapshotDate` column in reporting results, can be addressed in https://github.com/Gilead-Public/gsm.reporting/issues/24
dates <- names(ie_data) %>% as.Date
reporting <- map2(reporting, dates, ~{
  .x$Reporting_Results$SnapshotDate <- .y
  .x
})

# Bind multiple snapshots of data together
all_reportingResults <- do.call(dplyr::bind_rows, lapply(reporting, function(x) x$Reporting_Results))
all_reportingMetrics <- reporting[[length(reporting)]]$Reporting_Metrics
# Only need 1 reporting group object
all_reportingGroups <- reporting[[length(reporting)]]$Reporting_Groups


qtl0001 = mapped[[length(mapped)]]$Mapped_EXCLUSION
qtl0002 = left_join(
  select(mapped[[length(mapped)]]$Mapped_SUBJ, subjid, country),
  mapped[[length(mapped)]]$Mapped_STUDCOMP,
  by = "subjid"
) %>%
  mutate(compreas = ifelse(is.na(compreas) | compreas == "", "Completed/Ongoing", compreas))

report_listings <- list(
  qtl0001 = qtl0001,
  qtl0001_num = qtl0001 %>% dplyr::filter(Source != "Neither"),
  qtl0002 = qtl0002,
  qtl0002_num = qtl0002 %>% dplyr::filter(compreas != "Completed/Ongoing")
)

example_lparams <- list(
  dfResults = all_reportingResults,
  dfMetrics = all_reportingMetrics,
  dfGroups = all_reportingGroups,
  lListings = report_listings
)
usethis::use_data(example_lparams, internal = TRUE, overwrite = TRUE)

gsm.kri::RenderRmd(
  lParams = list(
    dfResults = gsm.qtl:::example_lparams$dfResults,
    dfGroups = gsm.qtl:::example_lparams$dfGroups,
    dfMetrics = gsm.qtl:::example_lparams$dfMetrics,
    lListings = gsm.qtl:::example_lparams$lListings
  ),
  strOutputDir = getwd(),
  strOutputFile = "pkgdown/assets/examples/Example_QTL.html",
  strInputPath = system.file("report/Report_QTL.Rmd", package = "gsm.qtl")
)

