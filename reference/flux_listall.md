# List available FLUXNET zip files for download

This provides a wrapper around the
[fluxnet-shuttle](https://github.com/fluxnet/shuttle) command-line
utility's `listall` command, which downloads a data frame of available
.zip files. By default, the downloaded CSV is stored in
`rappdirs::user_cache_dir("fluxnet")`. If there is allready a FLUXNET
shanpshot CSV file downloaded and it is more recent than `cache_age`, it
will be read in instead of downloading a new snapshot (unless
`use_cache = FALSE`).

## Usage

``` r
flux_listall(
  cache_dir = rappdirs::user_cache_dir("fluxnet"),
  use_cache = TRUE,
  cache_age = as.difftime(30, units = "days"),
  log_file = NULL,
  echo_cmd = FALSE
)
```

## Arguments

- cache_dir:

  The directory to store the list of available FLUXNET data in.

- use_cache:

  Logical; use cached list of files available to download if it exists
  and is not older than `cache_age`?

- cache_age:

  A `difftime` object of length 1. If there are no cached snapshots more
  recent than `cache_age`, a new one will be downloaded and stored. You
  can force the cache to be invalidated with `cache_age = -Inf`.

- log_file:

  An optional file path (e.g. `"log.txt"`) to direct the
  `fluxnet-shuttle` log to. Useful for debugging.

- echo_cmd:

  Set to `TRUE` to print the shell command in the console. Passed to
  [`processx::run()`](http://processx.r-lib.org/reference/run.md).

## Value

A data frame of stations with available data and their metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
fluxnet_files <- flux_listall()

# Ignore cache
fluxnet_files <- flux_listall(use_cache = FALSE)

# Invalidate cache and update it
fluxnet_files <- flux_listall(cache_age = -Inf)
} # }
```
