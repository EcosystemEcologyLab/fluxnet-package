# Extract FLUXNET data from downloaded zip files

Extracts data from zip files downloaded by
[`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
with options to extract only subsets of the files they contain.

## Usage

``` r
flux_extract(
  zip_dir = "fluxnet",
  output_dir = fs::path(zip_dir, "unzipped"),
  site_ids = "all",
  resolutions = c("y", "m", "w", "d", "h"),
  extract_varinfo = TRUE,
  extract_txt = FALSE,
  overwrite = FALSE
)
```

## Arguments

- zip_dir:

  The directory with the zip files

- output_dir:

  The directory to unzip files to. Within this directory, data files
  will be nested by site.

- site_ids:

  A character vector of site IDs (e.g. `c("AR-TF2", "CA-Ca2")`) can be
  supplied to only unzip data for certain sites. If `"all"` (default),
  all zip files found in zip_dir will be unzipped.

- resolutions:

  A character vector indicating which time resolutions to extract.
  Options are yearly (`"y"`), monthly (`"m"`), daily (`"d"`), and
  hourly/half-hourly (`"h"`). Multiple options may be passed with all of
  them as default.

- extract_varinfo:

  Logical; extract the BIF and BIFVARINFO files containing variable
  information in the BADM Interchange Format? Defaults to `TRUE`.

- extract_txt:

  Logical; extract the README.txt and
  DATA_POLICY_LICENSE_AND_INSTRUCTIONS.txt files? Defaults to `FALSE`.

- overwrite:

  Logical; should existing extracted files be overwritten (`TRUE`) or
  ignored (`FALSE`)?
