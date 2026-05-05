# Read variable info from "BIFVARINFO" files

Extracts and tidies variable information from "BIFVARINFO" csv files.

## Usage

``` r
flux_varinfo(
  manifest,
  resolution = c("y", "m", "w", "d", "h"),
  networks = c("AMF", "CNF", "EUF", "FLX", "ICOS", "JPF", "KOF", "SAEON", "TERN"),
  site_ids = NULL
)
```

## Arguments

- manifest:

  A manifest data frame produced by
  [`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md).

- resolution:

  The time resolution to read in. Must be one of `"y"` (annual), `"m"`
  (monthly), `"w"` (weekly), `"d"` (daily), or `"h"`
  (hourly/half-hourly).

- networks:

  A character vector indicating which networks to extract files from.
  Multiple values may be provided. Defaults to all networks.

- site_ids:

  A vector of site IDs to filter the manifest by. If `NULL` (the
  default), the manifest isn't filtered by site ID.

## Value

A tibble

## Note

This only returns variable info (`VARIABLE_GROUP == GRP_VAR_INFO`) from
the "BIFVARINFO" files as much of the other metadata they contain can be
found in the results of
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md).

`HEIGHT` is returned as a character value because some heights are
reported as ranges and cannot be parsed as a single numeric value.

## Examples

``` r
if (FALSE) { # \dontrun{
manifest <- flux_discover_files()
flux_varinfo(manifest)
} # }
```
