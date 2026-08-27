#' Eligibility Bar Chart by Source
#'
#' @param df A `data.frame` containing the participant level dataset with eligibility
#'
#' @returns A `bars` htmlwidget
#' @export
eligibility_sourceBar <- function(df) {
  df_counts <- df %>%
    mutate(Source = .qtl_chart_order(.data$Source)) %>%
    dplyr::count(.data$Source, name = "n")

  gsm.vizr::bars(
    df_counts,
    # No fill mapping: it would only duplicate the category axis, and dropping
    # it also drops the redundant legend and position toggle.
    gsm.vizr::bars_spec(
      x = "Source",
      y = "n",
      stat = "identity",
      orientation = "horizontal",
      scales = list(
        x = list(label = "Source"),
        y = list(label = "Participant Count")
      ),
      labels = list(title = "Participant Count by Category/Source"),
      annotations = list(labels = list(total = list(display = TRUE))),
      theme = .qtl_bar_theme(),
      tooltip = list(format = "count")
    ),
    minHeight = 500
  )
}
