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
  fill_colors <- .qtl_ggplot_hue(dplyr::pull(df, !!reason_sym))

  df_counts <- df %>%
    mutate(!!reason_sym := .qtl_chart_order(!!reason_sym)) %>%
    dplyr::count(!!reason_sym, name = "n")

  gsm.vizr::bars(
    df_counts,
    gsm.vizr::bars_spec(
      x = reason_name,
      y = "n",
      fill = reason_name,
      stat = "identity",
      orientation = "horizontal",
      scales = list(
        x = list(label = "Discontinuation Reasons"),
        y = list(label = "Participant Count"),
        fill = list(label = "Discontinuation Reasons", colors = fill_colors)
      ),
      labels = list(title = "Participant Count by Reasons"),
      annotations = list(labels = list(total = list(display = TRUE))),
      theme = .qtl_bar_theme(),
      # The plotly original showed only the bar count on hover
      # (tooltip = "label" over an after_stat(count) aesthetic).
      tooltip = list(
        formatter = gsm.vizr::js_hook(
          "function (value, context, details) {
             var d = (details && details.datum) || {};
             return [String(d.n)];
           }"
        )
      )
    ),
    minHeight = 500
  )
}
