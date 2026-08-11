# Bar Chart by Group and Criteria

Bar Chart by Group and Criteria

## Usage

``` r
criteria_groupBar(df, varGroupID, strGroupLabel, bSwapAxes = FALSE)
```

## Arguments

- df:

  A `data.frame` containing the participant level dataset with
  eligibility

- varGroupID:

  A variable to make the stacked bar chart with, i.e. invid

- strGroupLabel:

  A `string` to label the `varGroupID` in reference to axes, legend,
  footnotes.

- bSwapAxes:

  A `boolean` to denote whether or not the y-axis and fill groups should
  be swapped.

## Value

A `plotly` object
