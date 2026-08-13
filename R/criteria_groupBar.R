#' Bar Chart by Group and Criteria
#'
#' @param df A `data.frame` containing the participant level dataset with eligibility
#' @param varGroupID A variable to make the stacked bar chart with, i.e. invid
#' @param strGroupLabel A `string` to label the `varGroupID` in reference to axes, legend, footnotes.
#' @param bSwapAxes A `boolean` to denote whether or not the y-axis and fill groups should be swapped.
#'
#' @returns A `bars` htmlwidget
#'
#' @export
criteria_groupBar <- function(
  df,
  varGroupID,
  strGroupLabel,
  bSwapAxes = FALSE
) {
  group_sym <- rlang::ensym(varGroupID)
  var_name <- rlang::as_string(group_sym)

  df_counts <- df %>%
    filter(!is.na(.data$ietestcd_concat), nzchar(.data$ietestcd_concat)) %>%
    tidyr::separate_longer_delim(ietestcd_concat, ",") %>%
    dplyr::count(.data$ietestcd_concat, !!group_sym, name = "n")

  # bSwapAxes picks which variable is the category and which is the fill; both
  # branches draw horizontally, exactly as the two ggplot branches did.
  category <- if (bSwapAxes) var_name else "ietestcd_concat"
  fill <- if (bSwapAxes) "ietestcd_concat" else var_name
  fill_colors <- .qtl_ggplot_hue(df_counts[[fill]])

  df_counts[[category]] <- .qtl_chart_order(df_counts[[category]])

  gsm.vizr::bars(
    df_counts,
    gsm.vizr::bars_spec(
      x = category,
      y = "n",
      fill = fill,
      stat = "identity",
      orientation = "horizontal",
      scales = list(
        x = list(label = if (bSwapAxes) strGroupLabel else "Criteria"),
        y = list(label = "Criteria Count"),
        fill = list(
          label = if (bSwapAxes) "Criteria" else strGroupLabel,
          colors = fill_colors
        )
      ),
      labels = list(
        title = if (bSwapAxes) {
          paste0(strGroupLabel, " by Criteria")
        } else {
          paste0("Criteria by ", strGroupLabel)
        }
      ),
      annotations = list(labels = list(total = list(display = TRUE))),
      theme = .qtl_bar_theme(),
      tooltip = list(
        formatter = gsm.vizr::js_hook(sprintf(
          "function (value, context, details) {
             var d = (details && details.datum) || {};
             return ['%s: ' + d['%s'],
                     'Criteria: ' + d.ietestcd_concat,
                     'Count: ' + d.n];
           }",
          strGroupLabel,
          var_name
        ))
      )
    ),
    minHeight = 500
  )
}
