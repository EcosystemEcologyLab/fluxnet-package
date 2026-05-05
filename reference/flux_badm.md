# Read and tidy BADM subsets

Reads in BADM data from "BIF" csv files, subsets to a single
`VARIABLE_GROUP` and returns a wide data frame.

## Usage

``` r
flux_badm(
  manifest,
  variable_group,
  site_ids = NULL,
  networks = c("AMF", "CNF", "EUF", "FLX", "ICOS", "JPF", "KOF", "SAEON", "TERN")
)
```

## Arguments

- manifest:

  A manifest data frame produced by
  [`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md).

- variable_group:

  A single `VARIABLE_GROUP` without a `GRP_` prefix. Options can be
  viewed at <https://ameriflux.lbl.gov/data/badm/badm-standards/>

- site_ids:

  A vector of site IDs to filter the manifest by. If `NULL` (the
  default), the manifest isn't filtered by site ID.

- networks:

  A character vector indicating which networks to extract files from.
  Multiple values may be provided. Defaults to all networks.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
manifest <- flux_discover_files()
flux_badm(manifest, "SOIL_CHEM")
flux_badm(manifest, "LAI")
} # }
```
