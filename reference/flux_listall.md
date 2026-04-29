# List available FLUXNET zip files for download

This provides a wrapper around the
[fluxnet-shuttle](https://github.com/fluxnet/shuttle) command-line
utility's `listall` command, which downloads a data frame of available
.zip files. By default, the downloaded CSV is stored in
`rappdirs::user_cache_dir("fluxnet")`. If there is allready a FLUXNET
shanpshot CSV file downloaded and it is more recent than `cache_age`, it
will be read in instead of downloading a new snapshot.

## Usage

``` r
flux_listall(
  cache_dir = rappdirs::user_cache_dir("fluxnet"),
  cache_age = as.difftime(1, units = "days"),
  clean_cache = 10L,
  log_file = NULL,
  echo_cmd = FALSE,
  ...
)
```

## Arguments

- cache_dir:

  The directory to store the list of available FLUXNET data in.

- cache_age:

  A `difftime` object of length 1. If there are no cached snapshots more
  recent than `cache_age`, a new one will be downloaded and stored. You
  can force the cache to be invalidated with `cache_age = -Inf`.

- clean_cache:

  A number of files \\\geq 1\\ to keep in `cache_dir`. Defaults to 10,
  which keeps only the 10 most recent snapshots.

- log_file:

  An optional file path (e.g. `"log.txt"`) to direct the
  `fluxnet-shuttle` log to. Useful for debugging.

- echo_cmd:

  Set to `TRUE` to print the shell command in the console. Passed to
  [`processx::run()`](http://processx.r-lib.org/reference/run.md).

- ...:

  Arguments passed to
  [`flux_install_shuttle()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_install_shuttle.md).

## Value

A data frame of stations with available data and their metadata.

## Note

To force the `fluxnet` R package to re-install the `fluxnet-shuttle`
utility, remove the Pyhton virtualenv it is installed in by running
`reticulate::virtualenv_remove("fluxnet")`. Then, when you run
`flux_listall()` next, the virtualenv will be re-created and
`fluxnet-shuttle` will be re-installed.

## Examples

``` r
if (FALSE) { # \dontrun{
fluxnet_files <- flux_listall()

# Invalidate cache and update it
fluxnet_files <- flux_listall(cache_age = -Inf)
} # }
```
