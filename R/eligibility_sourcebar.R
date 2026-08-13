#' Eligibility Bar Chart by Source
#'
#' @param df A `data.frame` containing the participant level dataset with eligibility
#'
#' @returns A `bars` htmlwidget
#' @export
eligibility_sourceBar <- function(df) {
  fill_colors <- .qtl_ggplot_hue(df$Source)

  df_counts <- df %>%
    mutate(Source = .qtl_chart_order(.data$Source)) %>%
    dplyr::count(.data$Source, name = "n")

  gsm.vizr::bars(
    df_counts,
    gsm.vizr::bars_spec(
      x = "Source",
      y = "n",
      fill = "Source",
      stat = "identity",
      orientation = "horizontal",
      scales = list(
        x = list(label = "Source"),
        y = list(label = "Participant Count"),
        fill = list(label = "Source", colors = fill_colors)
      ),
      labels = list(title = "Participant Count by Category/Source"),
      annotations = list(labels = list(total = list(display = TRUE))),
      theme = .qtl_bar_theme(),
      tooltip = list(
        formatter = gsm.vizr::js_hook(
          "function (value, context, details) {
             var d = (details && details.datum) || {};
             return ['Source: ' + d.Source];
           }"
        )
      )
    ),
    minHeight = 500
  )
}
