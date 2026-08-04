# QTL Time Series Lineplot

QTL Time Series Lineplot

## Usage

``` r
QTL_lineplot(dfResults, strQTL)
```

## Arguments

- dfResults:

  A results `data.frame` from the output of
  `gsm.reporting::BindResults()` used to create a variety of
  visualizations like the line plot, bar plot.

- strQTL:

  A `string` to label the QTL being measured

## Value

A `plotly` object

## Details

This function is retained as a legacy Plotly-based compatibility path.
For report rendering, prefer
[`QTL_lineplot_v2()`](https://gilead-biostats.github.io/gsm.qtl/dev/reference/QTL_lineplot_v2.md).
