# Map sites with downloaded data

Plot locations of sites in a file manifest on a world map.

## Usage

``` r
flux_map_sites(
  manifest,
  color_var = c("data_hub", "igbp", "network", "first_year", "last_year")
)
```

## Arguments

- manifest:

  A data manifest created by
  [`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md).

- color_var:

  A variable to use to color-code points.

## Value

A ggplot2 object

## Examples

``` r
if (FALSE) { # \dontrun{
manifest <- flux_discover_files()
flux_map_sites(manifest)
} # }
```
