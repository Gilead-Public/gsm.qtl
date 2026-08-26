#' Order a category column for a horizontal gsm.viz chart (internal)
#'
#' ggplot2 drew the first factor level at the bottom of a horizontal chart;
#' Chart.js draws the first category at the top. Reversing the levels keeps the
#' migrated charts reading in the same order as the published plotly ones.
#' `bars()` turns the resulting levels into `scales$x$order`.
#' @noRd
.qtl_chart_order <- function(x) {
  f <- if (is.factor(x)) x else factor(x)
  factor(as.character(f), levels = rev(levels(f)))
}

#' Shared sizing curve for the QTL barcharts (internal)
#'
#' Reproduces the report's historical `max(500, 25 * n_groups)` height: the
#' per-category growth rate lives here, the 500px floor is the `minHeight`
#' argument of `gsm.vizr::bars()`.
#' @noRd
.qtl_bar_theme <- function() {
  list(dynamicSizing = TRUE, pxPerCategory = 25)
}

#' Preserve ggplot2's default discrete fill palette (internal)
#'
#' gsm.viz defaults to a Tableau palette, while these charts historically used
#' ggplot2's hue palette. Named colours keep each value on its published colour
#' and also give gsm.viz the same legend/stack order.
#' @noRd
.qtl_ggplot_hue <- function(x) {
  values <- if (is.factor(x)) {
    levels(droplevels(x[!is.na(x)]))
  } else {
    sort(unique(as.character(x[!is.na(x)])))
  }
  if (length(values) == 0) {
    return(stats::setNames(character(), character()))
  }
  stats::setNames(scales::hue_pal()(length(values)), values)
}
