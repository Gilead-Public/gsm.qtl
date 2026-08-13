#' Bar Chart by Group and Reasons
#'
#' @param df A `data.frame` containing the participant level dataset with eligibility
#' @param varGroupID A variable to make the stacked bar chart with, i.e. invid.
#' @param varCompreas A variable to identify study completion/discontinuation reasons
#' @param strGroupLabel A `string` to label the `varGroupID` in reference to axes, legend, footnotes.
#' @param bSwapAxes A `boolean` to denote whether or not the y-axis and fill groups should be swapped.
#'
#' @returns A `bars` htmlwidget
#'
#' @export
reasons_groupBar <- function(
  df,
  varGroupID,
  varCompreas,
  strGroupLabel,
  bSwapAxes = FALSE
) {
  group_sym <- rlang::ensym(varGroupID)
  var_name <- rlang::as_string(group_sym)
  compreas_sym <- rlang::ensym(varCompreas)
  compreas_name <- rlang::as_string(compreas_sym)

  df_counts <- df %>%
    dplyr::count(!!compreas_sym, !!group_sym, name = "n")

  # bSwapAxes picks which variable is the category and which is the fill; both
  # branches draw horizontally, exactly as the two ggplot branches did.
  category <- if (bSwapAxes) var_name else compreas_name
  fill <- if (bSwapAxes) compreas_name else var_name
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
        x = list(label = if (bSwapAxes) strGroupLabel else "Reason"),
        y = list(label = "Reason Count"),
        fill = list(
          label = if (bSwapAxes) "Reason" else strGroupLabel,
          colors = fill_colors
        )
      ),
      labels = list(
        title = if (bSwapAxes) {
          paste0(strGroupLabel, " by Discontinuation Reason")
        } else {
          paste0("Discontinuation Reason by ", strGroupLabel)
        }
      ),
      annotations = list(labels = list(total = list(display = TRUE))),
      theme = .qtl_bar_theme(),
      tooltip = list(
        formatter = gsm.vizr::js_hook(sprintf(
          "function (value, context, details) {
             var d = (details && details.datum) || {};
             return ['%s: ' + d['%s'],
                     'Discontinuation Reason: ' + d['%s'],
                     'Count: ' + d.n];
           }",
          strGroupLabel,
          var_name,
          compreas_name
        ))
      )
    ),
    minHeight = 500
  )
}
