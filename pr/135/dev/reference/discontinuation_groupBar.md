# Stacked Discontinuation Bar Chart

Stacked Discontinuation Bar Chart

## Usage

``` r
discontinuation_groupBar(
  dfNum,
  dfDenom,
  varGroupID,
  strGroupLabel,
  varStatus = compyn,
  valuesDiscontinued = c("N")
)
```

## Arguments

- dfNum:

  A `data.frame` containing the participant level dataset with just
  premature discontinuation

- dfDenom:

  A `data.frame` containing the participant level dataset with all study
  dispositions

- varGroupID:

  A variable to make the stacked bar chart with, i.e. invid

- strGroupLabel:

  A `string` to label the `varGroupID` in reference to axes, legend,
  footnotes.

- varStatus:

  A variable indicating participant study status, defaults to `compyn`.

- valuesDiscontinued:

  A vector of values in `varStatus` considered premature
  discontinuations, defaults to 'N'.

## Value

A `plotly` object
