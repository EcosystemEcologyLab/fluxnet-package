# Connect to (or create) DuckDB database for FLUXNET data

**\[experimental\]** A convenience wrapper around
[`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html).

## Usage

``` r
flux_db_connect(
  duckdb_path = Sys.getenv("FLUXNET_DB_PATH", unset = "fluxnet/fluxnet.duckdb")
)
```

## Arguments

- duckdb_path:

  File path to a .duckdb file used to store FLUXNET data. Can be set
  with the environment variable `FLUXNET_DB_PATH`.

## Value

A database connection object of class `duckdb_connection`.

## See also

[`flux_db_build()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_build.md)

## Examples

``` r
if (FALSE) { # \dontrun{

con <- flux_db_connect()
DBI::dbListTables(con)
# [1] "annual"   "daily"    "hourly"   "manifest" "monthly"  "weekly"

# close connection
DBI::dbDisconnect(con)
} # }
```
