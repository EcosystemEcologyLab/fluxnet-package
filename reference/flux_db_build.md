# Ingest FLUXNET data into a DuckDB database

**\[experimental\]** As an alternative to reading FLUXNET data into
memory with
[`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md),
this ingests all FLUXNET data into a DuckDB database that can be queried
in R with `dplyr` via `dbplyr`. This is especially useful for daily and
hourly data which are likely to overflow memory when trying to read them
in with
[`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md).

## Usage

``` r
flux_db_build(
  manifest,
  duckdb_path = Sys.getenv("FLUXNET_DB_PATH", unset = "fluxnet/fluxnet.duckdb")
)
```

## Arguments

- manifest:

  A file manifest tibble created by
  [`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md).

- duckdb_path:

  File path to a .duckdb file used to store FLUXNET data. Can be set
  with the environment variable `FLUXNET_DB_PATH`.

## Value

Returns nothing; called for side-effects only.

## Note

Currently "BIF" and "BIFVARINFO" CSV files are *not* included in the
DuckDB database.

## See also

[`flux_db_update()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_update.md),
[`flux_db_connect()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_connect.md)

## Examples

``` r
if (FALSE) { # \dontrun{

# Ingest all available data into a DuckDB database
manifest <- flux_discover_files()
flux_db_build(manifest)
} # }
```
