# Filter Discontinuation Reasons in data.frame

Filter Discontinuation Reasons in data.frame

## Usage

``` r
discontinuation_map_reasons(
  df,
  yaml_path = system.file("workflow", "0_other", "disc_reasons.yaml", package =
    "gsm.qtl")
)
```

## Arguments

- df:

  A `data.frame` that contains discontiuation reasons

- yaml_path:

  A `string` that denotes path to yaml file that contains
  discontinuation reasons

## Value

A `data.frame`
