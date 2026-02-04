# Read in FLUXNET data

Reads and minimally cleans FLUXNET data found by
[`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md).

## Usage

``` r
flux_read(
  manifest,
  resolution = c("y", "m", "w", "d", "h"),
  datasets = c("ERA5", "FLUXMET"),
  site_ids = "all"
)
```

## Arguments

- manifest:

  A manifest data frame produced by
  [`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md).

- resolution:

  The time resolution to read in. Must be one of `"y"` (annual), `"m"`
  (monthly), `"w"` (weekly), `"d"` (daily), or `"h"` (hourly).

- datasets:

  Character vector of one or both of `"FLUXMET"` or `"ERA5"`. Defaults
  to both.

- site_ids:

  A vector of site IDs to filter the manifest by. If `"all"` (the
  default), the manifest isn't filtered by site ID.

## Examples

``` r
if (FALSE) { # \dontrun{
manifest <- flux_discover_files()
daily <- flux_read(manifest, resolution = "d")
annual <- flux_read(manifest, resolution = "y")

# Filter manifest by metadata first
metadata <- flux_listall()

library(dplyr)
manifest_enriched <- left_join(manifest, metadata, by = join_by(site_id))
manifest_WET <- manifest_enriched %>% filter(igbp == "WET")
annual_wet <- flux_read(manifest_WET, resolution = "y")

} # }

```
