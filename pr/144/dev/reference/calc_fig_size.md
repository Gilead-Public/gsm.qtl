# Compute a widget height from the number of y-axis groups

Convenience helper for HTML widgets (e.g., Plotly) that converts a count
of categories/rows into a pixel height. The function returns the larger
of `base` and `per * n_rows`, which keeps small plots readable while
allowing tall plots when many groups are shown.

## Usage

``` r
calc_fig_size(n_rows, base = 500, per = 25)
```

## Arguments

- n_rows:

  A single non-negative number giving the number of rows/groups (e.g.,
  distinct y-axis categories).

- base:

  Minimum height in **pixels** to allocate regardless of `n_rows`.
  Default is `500`.

- per:

  Height in **pixels** to allocate **per** row/group. Default is `22`.

## Value

An integer pixel value suitable for a widget's `height =` argument.
