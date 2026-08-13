#' Stacked Discontinuation Bar Chart
#'
#' @param dfNum A `data.frame` containing the participant level dataset with just premature discontinuation
#' @param dfDenom A `data.frame` containing the participant level dataset with all study dispositions
#' @param varGroupID A variable to make the stacked bar chart with, i.e. invid
#' @param strGroupLabel A `string` to label the `varGroupID` in reference to axes, legend, footnotes.
#' @param varStatus A variable indicating participant study status, defaults to `compyn`.
#' @param valuesDiscontinued A vector of values in `varStatus` considered premature discontinuations, defaults to 'N'.
#'
#' @returns A `bars` htmlwidget
#'
#' @export
discontinuation_groupBar <- function(
  dfNum,
  dfDenom,
  varGroupID,
  strGroupLabel,
  varStatus = compyn,
  valuesDiscontinued = c('N')
) {
  group_sym <- rlang::ensym(varGroupID)
  var_name <- rlang::as_string(group_sym)

  groups_with_discontinuation <- dfNum %>%
    pull(!!group_sym) %>%
    unique()

  df_counts <- dfDenom %>%
    mutate(
      fillcol = factor(
        ifelse(
          !!enexpr(varStatus) %in% valuesDiscontinued,
          "Premature Discontinuation",
          "Completed/Ongoing"
        ),
        levels = c("Completed/Ongoing", "Premature Discontinuation")
      )
    ) %>%
    filter(!!group_sym %in% groups_with_discontinuation) %>%
    mutate(
      !!group_sym := .qtl_chart_order(forcats::fct_rev(forcats::fct_infreq(
        !!group_sym
      )))
    ) %>%
    dplyr::count(!!group_sym, .data$fillcol, name = "totals")

  n_groups_without_discontinuation <- dfDenom %>%
    filter(!(!!group_sym %in% groups_with_discontinuation)) %>%
    pull(!!group_sym) %>%
    unique() %>%
    length()

  n_participants_without_discontinuation <- dfDenom %>%
    filter(!(!!group_sym %in% groups_with_discontinuation)) %>%
    nrow()

  labels <- list(title = paste0("Participant Count by ", strGroupLabel))
  if (n_groups_without_discontinuation > 0) {
    labels$captions <- paste0(
      "Note: Excludes ",
      n_groups_without_discontinuation,
      " ",
      tolower(strGroupLabel),
      "(s) with no prematurely discontinued participants (",
      n_participants_without_discontinuation,
      " participants)."
    )
  }

  gsm.vizr::bars(
    df_counts,
    gsm.vizr::bars_spec(
      x = var_name,
      y = "totals",
      fill = "fillcol",
      stat = "identity",
      orientation = "horizontal",
      position = "stack",
      scales = list(
        x = list(label = strGroupLabel),
        y = list(label = "Participant Count"),
        fill = list(
          label = "Study Status",
          # Key order sets the stack order: gsm.viz reads it from this map and
          # ignores the factor-derived scales$fill$order whenever a named colour
          # map is supplied. Keep it in the `fillcol` level order above.
          colors = c(
            "Completed/Ongoing" = "#00BFC4",
            "Premature Discontinuation" = "#FF5859"
          )
        )
      ),
      labels = labels,
      theme = .qtl_bar_theme(),
      tooltip = list(
        formatter = gsm.vizr::js_hook(sprintf(
          "function (value, context, details) {
             var d = (details && details.datum) || {};
             return ['Count: ' + d.totals,
                     '%s: ' + d['%s'],
                     'Discontinuation Status: ' + d.fillcol];
           }",
          strGroupLabel,
          var_name
        ))
      )
    ),
    minHeight = 500
  )
}
