#' Stacked Eligibility Bar Chart
#'
#' @param dfNum A `data.frame` containing the participant level dataset with only ineligibility values
#' @param dfDenom A `data.frame` containing the participant level dataset with all inc/exc values.
#' @param varGroupID A variable to make the stacked bar chart with, i.e. invid
#' @param strGroupLabel A `string` to label the `varGroupID` in reference to axes, legend, footnotes.
#' @param bPercentage A `boolean` to denote whether or not the group bar chart should be visualized as percentages instead of absolute counts.
#'
#' @returns A `bars` htmlwidget
#'
#' @export
eligibility_groupBar <- function(
  dfNum,
  dfDenom,
  varGroupID,
  strGroupLabel,
  bPercentage = FALSE
) {
  group_sym <- rlang::ensym(varGroupID)
  var_name <- rlang::as_string(group_sym)

  groups_with_ineligible <- dfNum %>%
    pull(!!group_sym) %>%
    unique()

  df_counts <- dfDenom %>%
    filter(!!group_sym %in% groups_with_ineligible) %>%
    mutate(
      fillcol = factor(
        ifelse(.data$Source == "Neither", "No Eligibility Risk", "Ineligible"),
        levels = c("No Eligibility Risk", "Ineligible")
      ),
      !!group_sym := .qtl_chart_order(forcats::fct_rev(forcats::fct_infreq(
        !!group_sym
      )))
    ) %>%
    dplyr::count(!!group_sym, .data$fillcol, name = "totals")

  n_groups_without_ineligible <- dfDenom %>%
    filter(!(!!group_sym %in% groups_with_ineligible)) %>%
    pull(!!group_sym) %>%
    unique() %>%
    length()

  n_participants_without_ineligible <- dfDenom %>%
    filter(!(!!group_sym %in% groups_with_ineligible)) %>%
    nrow()

  labels <- list(
    title = paste0(
      if (bPercentage) {
        "Participant Percentage by "
      } else {
        "Participant Count by "
      },
      strGroupLabel
    )
  )
  if (n_groups_without_ineligible > 0) {
    labels$captions <- paste0(
      "Note: Excludes ",
      n_groups_without_ineligible,
      " ",
      tolower(strGroupLabel),
      "(s) with no ineligible participants (",
      n_participants_without_ineligible,
      " participants)."
    )
  }

  gsm.vizr::bars(
    df_counts,
    gsm.vizr::bars_spec(
      x = var_name,
      y = "totals",
      fill = "fillcol",
      # gsm.viz rewrites position = "fill" to {stack, percent} only when stat
      # is unset; an explicit "identity" would win the merge and draw counts.
      stat = if (bPercentage) NULL else "identity",
      orientation = "horizontal",
      position = if (bPercentage) "fill" else "stack",
      scales = list(
        x = list(label = strGroupLabel),
        y = list(
          label = if (bPercentage) {
            "Participant Percentage"
          } else {
            "Participant Count"
          }
        ),
        fill = list(
          label = "Eligibility",
          # Key order sets the stack order: gsm.viz reads it from this map and
          # ignores the factor-derived scales$fill$order whenever a named colour
          # map is supplied. Keep it in the `fillcol` level order above.
          colors = c(
            "No Eligibility Risk" = "#00BFC4",
            "Ineligible" = "#FF5859",
            "Neither" = "#7CAE00"
          )
        )
      ),
      labels = labels,
      theme = .qtl_bar_theme(),
      # "<status>: <count> (<pct>)" with the percentage over the category
      # total — the same numbers the removed formatter and perc column carried.
      tooltip = list(format = "count+percent")
    ),
    minHeight = 500
  )
}
