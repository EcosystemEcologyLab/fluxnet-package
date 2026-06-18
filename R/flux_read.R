#' Read in FLUXNET data
#'
#' Reads and minimally cleans FLUXNET data found by [flux_discover_files()].
#'
#' @param manifest A manifest data frame produced by [flux_discover_files()].
#' @param resolution The time resolution to read in.  Must be one of `"y"`
#'   (annual), `"m"` (monthly), `"w"` (weekly), `"d"` (daily), or `"h"`
#'   (hourly/half-hourly).
#' @param datasets Character vector of one or both of `"FLUXMET"` or `"ERA5"`.
#'   Defaults to both.
#' @param networks A character vector indicating which networks to extract files
#'   from. Multiple values may be provided. Defaults to all networks.
#' @param site_ids A vector of site IDs to filter the manifest by.  If `NULL`
#'   (the default), the manifest isn't filtered by site ID.
#'
#' @examples
#' \dontrun{
#' manifest <- flux_discover_files()
#' daily <- flux_read(manifest, resolution = "d")
#' annual <- flux_read(manifest, resolution = "y")
#'
#' # Filter manifest by metadata first
#' metadata <- flux_listall()
#'
#' library(dplyr)
#' manifest_enriched <- left_join(manifest, metadata, by = join_by(site_id))
#' manifest_WET <- manifest_enriched %>% filter(igbp == "WET")
#' annual_wet <- flux_read(manifest_WET, resolution = "y")
#'
#' }
#'
#'
#' @export
flux_read <- function(
  manifest,
  resolution = c("y", "m", "w", "d", "h"),
  datasets = c("ERA5", "FLUXMET"),
  networks = c(
    "AMF",
    "CNF",
    "EUF",
    "FLX",
    "ICOS",
    "JPF",
    "KOF",
    "SAEON",
    "TERN"
  ),
  site_ids = NULL
) {
  if (!is.null(site_ids)) {
    if (any(site_ids == "all")) {
      lifecycle::deprecate_warn(
        "0.3.1",
        "flux_read(site_ids = 'can no longer be set to \"all\"')",
        details = "Using `site_ids = NULL`"
      )
      site_ids <- NULL
    }
  }
  datasets <- match.arg(datasets, several.ok = TRUE)
  resolution <- match.arg(resolution)
  resolution_fmt <- paste0(toupper(resolution), toupper(resolution))

  # Combine hourly (HR) and half-hourly (HH)
  if (resolution_fmt == "HH") {
    resolution_fmt <- c("HH", "HR")
  }
  network_choice <- match.arg(networks, several.ok = TRUE)

  files_df <- manifest %>%
    dplyr::filter(.data$dataset %in% datasets) %>%
    dplyr::filter(.data$time_resolution %in% resolution_fmt) %>%
    dplyr::filter(.data$product_source_network %in% network_choice)

  if (!is.null(site_ids)) {
    files_df <- files_df %>% dplyr::filter(.data$site_id %in% site_ids)
  }

  if (nrow(files_df) == 0) {
    cli::cli_abort(
      "No files to read. Check the {.var manifest} or choose different values for {.arg resolution} and {.arg datasets}."
    )
  }

  cli::cli_inform("Reading {nrow(files_df)} file{?s}.")
  data_raw <- purrr::pmap(
    files_df %>% dplyr::select(dplyr::all_of(c("path", "site_id", "dataset"))),
    function(path, site_id, dataset) {
      readr::read_csv(path, show_col_types = FALSE, na = c("", "NA", "-9999")) %>%
        dplyr::mutate(site_id = site_id, dataset = dataset, .before = 1)
    },
    .progress = TRUE
  ) %>%
    purrr::list_rbind()

  # Parse TIMESTAMP column differently depending on time resolution
  timestamp_col <- switch(
    resolution,
    y = "TIMESTAMP",
    m = "TIMESTAMP",
    w = c("TIMESTAMP_START", "TIMESTAMP_END"),
    d = "TIMESTAMP",
    h = c("TIMESTAMP_START", "TIMESTAMP_END")
  )

  timestamp_replace <- switch(
    resolution,
    y = "YEAR",
    m = "DATE",
    w = "DATE",
    d = "DATE",
    h = "DATETIME"
  )

  timestamp_fun <- switch(
    resolution,
    y = as.integer,
    m = lubridate::ym,
    w = lubridate::ymd,
    d = lubridate::ymd,
    h = lubridate::ymd_hm
  )

  data_clean <- data_raw %>%
    dplyr::mutate(
      dplyr::across(dplyr::all_of(timestamp_col), timestamp_fun),
    ) %>%
    dplyr::rename_with(function(col) {
      stringr::str_replace(col, "TIMESTAMP", timestamp_replace)
    })

  # Append an attribute to more easily track the time resolution of the dataset
  attr(data_clean, "flux_resolution") <- resolution

  data_clean
}
