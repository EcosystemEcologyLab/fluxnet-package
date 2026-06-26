# Update existing DuckDB database with new FLUXNET data

**\[experimental\]** Updates an existing DuckDB database crated by
[`flux_db_build()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_build.md).
When you've downloaded and extracted new data since building the
database, this may be faster than rebuilding the database by deleting
the .duckdb file and re-running
[`flux_db_build()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_build.md).
If run successfully, it will update the 'manifest' table as well.

## Usage

``` r
flux_db_update(
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

This will error when new CSVs contain columns not already in the
database. In this case, you'll have to delete the .duckdb file and run
[`flux_db_build()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_build.md)
again to regenerate the database.

## See also

[`flux_db_build()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_build.md),
[`flux_db_connect()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_db_connect.md)

## Examples

``` r
if (FALSE) { # \dontrun{

# Build database
manifest <- flux_discover_files()
flux_db_build(manifest)

# Download and extract additional sites
flux_download()
flux_extract()

# Update database
manifest <- flux_discover_files()
flux_db_update(manifest)

} # }
```
