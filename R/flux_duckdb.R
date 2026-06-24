#' Connect to (or create) DuckDB database for FLUXNET data
#'
#' `r lifecycle::badge("experimental")`
#' A convenience wrapper around [DBI::dbConnect()].
#'
#' @param duckdb_path File path to a .duckdb file used to store FLUXNET data.
#'   Can be set with the environment variable `FLUXNET_DB_PATH`.
#' @returns A database connection object of class `duckdb_connection`.
#' @examples
#' \dontrun{
#'
#' con <- flux_db_connect()
#' DBI::dbListTables(con)
#' # [1] "annual"   "daily"    "hourly"   "manifest" "monthly"  "weekly"
#'
#' # close connection
#' DBI::dbDisconnect(con)
#' }
#' @seealso [flux_db_build()]
#' @export
flux_db_connect <- function(
  duckdb_path = Sys.getenv("FLUXNET_DB_PATH", unset = "fluxnet/fluxnet.duckdb")
) {
  rlang::check_installed("duckdb")
  rlang::check_installed("DBI")
  cli::cli_alert_info("Opening DuckDB connection to {.path {duckdb_path}}")
  fs::dir_create(fs::path_dir(duckdb_path))
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_path)
  con
}

# # TODO: flux_qc() relies on an attribute to know how to behave, so if flux_qc()
# # is ever going to work with a lazy tibble, then a helper fun like this may be
# # needed (or a re-design of flux_qc())
# flux_db_tbl <- function(
#   con,
#   table = c("annual", "monthly", "weekly", "daily", "hourly", "manifest")
# ) {
#   flux_tbl <- tbl(con, table)
#   res <- switch(
#     table,
#     annual = "y",
#     monthy = "m",
#     weekly = "w",
#     daily = "d",
#     hourly = "h"
#   )
#   if(!is.null(res)) {
#     attr(flux_tbl, "flux_resolution") <- res
#   }
#   flux_tbl
# }

#' Ingest FLUXNET data into a DuckDB database
#'
#' `r lifecycle::badge("experimental")`
#' As an alternative to reading FLUXNET data into memory with [flux_read()],
#' this ingests all FLUXNET data into a DuckDB database that can be queried in R
#' with `dplyr` via `dbplyr`. This is especially useful for daily and hourly
#' data which are likely to overflow memory when trying to read them in with
#' [flux_read()].
#'
#' @note Currently "BIF" and "BIFVARINFO" CSV files are *not* included in the
#'   DuckDB database.
#'
#' @param manifest A file manifest tibble created by [flux_discover_files()].
#' @inheritParams flux_db_connect duckdb_path
#' @returns Returns nothing; called for side-effects only.
#' @examples
#' \dontrun{
#'
#' # Ingest all available data into a DuckDB database
#' manifest <- flux_discover_files()
#' flux_db_build(manifest)
#' }
#'
#' @seealso [flux_db_update()], [flux_db_connect()]
#' @export
flux_db_build <- function(
  manifest,
  duckdb_path = Sys.getenv("FLUXNET_DB_PATH", unset = "fluxnet/fluxnet.duckdb")
) {
  # TODO: add a cleanup option to delete any CSVs ingested?
  rlang::check_installed("duckdb")
  rlang::check_installed("glue")
  rlang::check_installed("DBI")

  # Split manifest by resolution (keeping HH and HR together)
  manifest <- manifest %>%
    dplyr::filter(.data$dataset %in% c("ERA5", "FLUXMET")) %>%
    dplyr::mutate(
      resolution2 = dplyr::replace_values(
        .data$time_resolution,
        "HR" ~ "H",
        "HH" ~ "H"
      )
    )

  files_resolutions <- split(manifest$path, manifest$resolution2)

  # Convert vector of file paths to comma separated string for input to SQL
  # command
  files_strings <- purrr::map(files_resolutions, \(x) {
    glue::glue_collapse(glue::glue("'{x}'"), sep = ", ")
  })

  con <- flux_db_connect(duckdb_path)
  on.exit(
    {
      cli::cli_progress_step("Closing connection.")
      DBI::dbDisconnect(con)
    },
    add = TRUE
  )
  tables <- DBI::dbListTables(con)

  # Add the manifest to the database—useful to compare with updated manifest to
  # update data.

  if (!"manifest" %in% tables) {
    cli::cli_progress_step("Recording CSV manifest in database")
    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp), add = TRUE)

    readr::write_csv(manifest, tmp)
    exe_manifest <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE TABLE manifest AS
      SELECT * FROM read_csv(
        '{tmp}',
        nullstr = ['NA'],
        types = {{'location_lat': 'DOUBLE', 'location_long': 'DOUBLE'}}
      )
      "
      )
    )
  }

  # Ingest CSVs using a series of SQL commands.  `union_by_name = true` is
  # necessary since FLUXMET CSVs have different numbers of columns. Site IDs, data
  # hub, and dataset (ERA5 or FLUXMET) is extracted from filenames, -9999 is
  # converted to NA, and TIMESTAMP is parsed (depending on time interval) on
  # ingest.

  # Create annual table if annual data exists
  if (!is.null(files_strings$YY) & !"annual" %in% tables) {
    cli::cli_progress_step("Reading in annual data CSVs")
    exe_YY <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE TABLE annual AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$YY}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP': 'INTEGER'}}
        );
      ALTER TABLE annual
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP);
    "
      )
    )
  }

  # Create monthly data table if monthly data exists
  if (!is.null(files_strings$MM) & !"monthly" %in% tables) {
    cli::cli_progress_step("Reading in monthly data CSVs")
    exe_MM <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE TABLE monthly AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$MM}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP': 'DATE'}},
          dateformat = '%Y%m'
        );
      ALTER TABLE monthly
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP); 
    "
      )
    )
  }

  # Create weekly table if weekly data exists
  if (!is.null(files_strings$WW) & !"weekly" %in% tables) {
    cli::cli_progress_step("Reading in weekly data CSVs")
    exe_WW <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE TABLE weekly AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$WW}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP_START': 'DATE', 'TIMESTAMP_END': 'DATE'}},
          dateformat = '%Y%m%d'
        );
      ALTER TABLE weekly
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP_START);
    "
      )
    )
  }

  # Create daily table if daily data exists
  if (!is.null(files_strings$DD) & !"daily" %in% tables) {
    cli::cli_progress_step("Reading in daily data CSVs")
    exe_DD <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE TABLE daily AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$DD}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP': 'DATE'}},
          dateformat = '%Y%m%d'
        );
      ALTER TABLE daily
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP);
    "
      )
    )
  }

  # Create hourly/half-hourly table if hourly/half-hourly data exists
  if (!is.null(files_strings$H) & !"hourly" %in% tables) {
    cli::cli_progress_step("Reading in hourly/half-hourly data CSVs")
    exe_HH <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE TABLE hourly AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
        split_part(parse_filename(path), '_', 5) as time_resolution,
      FROM 
        read_csv(
          [{files_strings$H}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP_START': 'DATETIME', 'TIMESTAMP_END': 'DATETIME'}},
          timestampformat = '%Y%m%d%H%M'
        );
      ALTER TABLE hourly
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP_START);
    "
      )
    )
  }
}

#' Update existing DuckDB database with new FLUXNET data
#'
#' `r lifecycle::badge("experimental")`
#' Updates an existing DuckDB database crated by [flux_db_build()]. When you've
#' downloaded and extracted new data since building the database, this may be
#' faster than rebuilding the database by deleting the .duckdb file and
#' re-running [flux_db_build()]. If run successfully, it will update the
#' 'manifest' table as well.
#'
#' @note This will error when new CSVs contain columns not already in the
#' database. In this case, you'll have to delete the .duckdb file and run
#' [flux_db_build()] again to regenerate the database.
#'
#' @inheritParams flux_db_build manifest duckdb_path
#' @returns Returns nothing; called for side-effects only.
#' @examples
#' \dontrun{
#'
#' # Build database
#' manifest <- flux_discover_files()
#' flux_db_build(manifest)
#'
#' # Download and extract additional sites
#' flux_download()
#' flux_extract()
#'
#' # Update database
#' manifest <- flux_discover_files()
#' flux_db_update(manifest)
#'
#' }
#'
#' @seealso [flux_db_build()], [flux_db_connect()]
#'
#' @export
flux_db_update <- function(
  manifest,
  duckdb_path = Sys.getenv("FLUXNET_DB_PATH", unset = "fluxnet/fluxnet.duckdb")
) {
  rlang::check_installed("duckdb")
  rlang::check_installed("glue")
  rlang::check_installed("DBI")

  con <- flux_db_connect(duckdb_path)
  on.exit(
    {
      cli::cli_progress_step("Closing connection.")
      DBI::dbDisconnect(con)
    },
    add = TRUE
  )

  tables <- DBI::dbListTables(con)
  if (!"manifest" %in% tables) {
    cli::cli_abort(c(
      "Database is empty or does not contain a 'manifest' table!",
      i = "You may need to delete {.path {con@driver@dbdir}} and re-generate it with {.fun flux_db_build}."
    ))
  }
  manifest_old <- dplyr::tbl(con, "manifest") %>% dplyr::collect()
  manifest_new <- manifest %>%
    dplyr::filter(.data$dataset %in% c("ERA5", "FLUXMET")) %>%
    dplyr::mutate(
      resolution2 = dplyr::replace_values(
        .data$time_resolution,
        "HR" ~ "H",
        "HH" ~ "H"
      )
    )

  to_add <- dplyr::anti_join(
    manifest_new,
    manifest_old,
    by = c(
      "site_id",
      "dataset",
      "time_resolution",
      "first_year",
      "last_year",
      "oneflux_code_version",
      "release_version",
      "product_id"
    )
  )

  if (nrow(to_add) == 0) {
    cli::cli_warn("No CSVs to add to database.")
    return(NULL)
  }

  # Split files by resolution
  files_resolutions <- split(to_add$path, to_add$resolution2)

  # Convert vector of file paths to comma separated string for input to SQL
  # command
  files_strings <- purrr::map(files_resolutions, \(x) {
    glue::glue_collapse(glue::glue("'{x}'"), sep = ", ")
  })

  # Update annual table if there is new annual data
  if (!is.null(files_strings$YY)) {
    cli::cli_progress_step("Reading in annual data CSVs")
    exe_YY <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE OR REPLACE TEMP TABLE annual_ingest AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$YY}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP': 'INTEGER'}}
        );
      ALTER TABLE annual_ingest
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP);
    "
      )
    )
    # Upsert (update/insert) by site_id, dataset, and timestamp. 'BY NAME' is
    # needed because the ingest table may have different column names from
    # the database.
    cli::cli_progress_step("Updating/Inserting annual data into database")
    exe_YY_upsert <- tryCatch(
      {
        DBI::dbExecute(
          con,
          "
      INSERT OR REPLACE INTO annual
      BY NAME (FROM annual_ingest)
      "
        )
      },
      error = function(cnd) {
        # cnd
        cli::cli_abort(c(
          "Error updating table.",
          (cnd$message),
          i = "You may need to delete {.path {con@driver@dbdir}} and re-generate it with {.fun flux_db_build}."
        ))
      }
    )
  }

  # Update monthly table if there is new monthly data
  if (!is.null(files_strings$MM)) {
    cli::cli_progress_step("Reading in monthly data CSVs")
    exe_MM <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE OR REPLACE TEMP TABLE monthly_ingest AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$MM}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP': 'DATE'}},
          dateformat = '%Y%m'
        );
      ALTER TABLE monthly_ingest
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP);
    "
      )
    )
    # Upsert (update/insert) by site_id, dataset, and timestamp. 'BY NAME' is
    # needed because the ingest table may have different column names from
    # the database.
    cli::cli_progress_step("Updating/Inserting monthly data into database")
    exe_MM_upsert <- tryCatch(
      {
        DBI::dbExecute(
          con,
          "
      INSERT OR REPLACE INTO monthly
      BY NAME (FROM monthly_ingest)
      "
        )
      },
      error = function(cnd) {
        # cnd
        cli::cli_abort(c(
          "Error updating table.",
          (cnd$message),
          i = "You may need to delete {.path {con@driver@dbdir}} and re-generate it with {.fun flux_db_build}."
        ))
      }
    )
  }

  # Update weekly table if there is new weekly data
  if (!is.null(files_strings$WW)) {
    cli::cli_progress_step("Reading in weekly data CSVs")
    exe_WW <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE OR REPLACE TEMP TABLE weekly_ingest AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$WW}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP_START': 'DATE', 'TIMESTAMP_END': 'DATE'}},
          dateformat = '%Y%m%d'
        );
      ALTER TABLE weekly_ingest
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP_START);
    "
      )
    )
    # Upsert (update/insert) by site_id, dataset, and timestamp. 'BY NAME' is
    # needed because the weekly_ingest table may have different column names from
    # the database.
    cli::cli_progress_step("Updating/Inserting weekly data into database")
    exe_WW_upsert <- tryCatch(
      {
        DBI::dbExecute(
          con,
          "
      INSERT OR REPLACE INTO weekly
      BY NAME (FROM weekly_ingest)
      "
        )
      },
      error = function(cnd) {
        # cnd
        cli::cli_abort(c(
          "Error updating table.",
          (cnd$message),
          i = "You may need to delete {.path {con@driver@dbdir}} and re-generate it with {.fun flux_db_build}."
        ))
      }
    )
  }

  # Update daily table if there is new daily data
  if (!is.null(files_strings$DD)) {
    cli::cli_progress_step("Reading in daily data CSVs")
    exe_DD <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE OR REPLACE TEMP TABLE daily_ingest AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
      FROM 
        read_csv(
          [{files_strings$DD}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP': 'DATE'}},
          dateformat = '%Y%m%d'
        );
      ALTER TABLE daily_ingest
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP);
    "
      )
    )
    # Upsert (update/insert) by site_id, dataset, and timestamp. 'BY NAME' is
    # needed because the ingest table may have different column names from the
    # database.
    cli::cli_progress_step("Updating/Inserting daily data into database")
    exe_DD_upsert <- tryCatch(
      {
        DBI::dbExecute(
          con,
          "
      INSERT OR REPLACE INTO daily
      BY NAME (FROM daily_ingest)
      "
        )
      },
      error = function(cnd) {
        # cnd
        cli::cli_abort(c(
          "Error updating table.",
          (cnd$message),
          i = "You may need to delete {.path {con@driver@dbdir}} and re-generate it with {.fun flux_db_build}."
        ))
      }
    )
  }

  # Update hourly/half-hourly table if there is new data
  if (!is.null(files_strings$H)) {
    cli::cli_progress_step("Reading in hourly/half-hourly data CSVs")
    exe_HH <- DBI::dbExecute(
      con,
      glue::glue(
        "
      CREATE OR REPLACE TEMP TABLE hourly_ingest AS
      SELECT *,
        split_part(parse_filename(path), '_', 1) as data_hub,
        split_part(parse_filename(path), '_', 2) as site_id,
        split_part(parse_filename(path), '_', 4) as dataset,
        split_part(parse_filename(path), '_', 5) as time_resolution,
      FROM 
        read_csv(
          [{files_strings$H}],
          union_by_name = true,
          filename = 'path',
          nullstr = ['NA', '-9999'],
          parallel = true,
          types = {{'TIMESTAMP_START': 'DATETIME', 'TIMESTAMP_END': 'DATETIME'}},
          timestampformat = '%Y%m%d%H%M'
        );
      ALTER TABLE hourly_ingest
        ADD PRIMARY KEY (site_id, dataset, TIMESTAMP_START);
    "
      )
    )
    # Upsert (update/insert) by site_id, dataset, and timestamp. 'BY NAME' is
    # needed because the ingest table may have different column names from the
    # database.
    cli::cli_progress_step("Updating/Inserting hourly data into database")
    # TODO: Figure out a good way to add missing columns with ALTER TABLE
    exe_HH_upsert <- tryCatch(
      {
        DBI::dbExecute(
          con,
          "
      INSERT OR REPLACE INTO hourly
      BY NAME (FROM hourly_ingest)
      "
        )
      },
      error = function(cnd) {
        # cnd
        cli::cli_abort(c(
          "Error updating table.",
          (cnd$message),
          i = "You may need to delete {.path {con@driver@dbdir}} and re-generate it with {.fun flux_db_build}."
        ))
      }
    )
  }

  # If all went well, update the manifest
  cli::cli_progress_step("Updating CSV manifest in database")
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  readr::write_csv(manifest_new, tmp)
  DBI::dbExecute(
    con,
    glue::glue(
      "
      CREATE OR REPLACE TABLE manifest AS
      SELECT * FROM read_csv(
        '{tmp}',
        nullstr = ['NA'],
        types = {{'location_lat': 'DOUBLE', 'location_long': 'DOUBLE'}}
      )
      "
    )
  )
}
