# Eligibility Overview Table

Eligibility Overview Table

## Usage

``` r
Eligibility_Overview(dfResults, dSnapshot, strNum, strDenom, strQTL)
```

## Arguments

- dfResults:

  A results `data.frame` from the output of
  `gsm.reporting::BindResults()` used to create a variety of
  visualizations like the line plot, bar plot.

- dSnapshot:

  A `date` to determine the snapshot grab the data from `dfResults`

- strNum:

  A `string` to denominate what the numerator population is.

- strDenom:

  A `string` to denominate what the denominator population is.

- strQTL:

  A `string` to define the QTL being measured

## Value

`gt` object
