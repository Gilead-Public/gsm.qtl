#' Discontinuation Reasons Bar Chart
#'
#' @param df A `data.frame` containing the participant level dataset with eligibility
#' @param varCompreas A variable to identify study completion/discontinuation reasons
#'
#' @returns A `bars` htmlwidget
#' @export
discontinuation_reasonBar <- function(df, varCompreas) {
  reason_sym <- rlang::ensym(varCompreas)
  reason_name <- rlang::as_string(reason_sym)

  df_counts <- df %>%
    mutate(!!reason_sym := .qtl_chart_order(!!reason_sym)) %>%
    dplyr::count(!!reason_sym, name = "n")

  gsm.vizr::bars(
    df_counts,
    # No fill mapping: it would only duplicate the category axis, and dropping
    # it also drops the redundant legend and position toggle.
    gsm.vizr::bars_spec(
      x = reason_name,
      y = "n",
      stat = "identity",
      orientation = "horizontal",
      scales = list(
        x = list(label = "Discontinuation Reasons"),
        y = list(label = "Participant Count")
      ),
      labels = list(title = "Participant Count by Reasons"),
      annotations = list(labels = list(total = list(display = TRUE))),
      theme = .qtl_bar_theme(),
      tooltip = list(format = "count")
    ),
    minHeight = 500
  )
}
