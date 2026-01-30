#' Read in FLUXNET data
#'
#' Reads and minimally cleans FLUXNET data found by [flux_discover_files()].
#'
#' @param manifest A manifest data frame produced by [flux_discover_files()].
#' @param resolution The time resolution to read in.  Must be one of `"y"`
#'   (annual), `"m"` (monthly), `"w"` (weekly), `"d"` (daily), or `"h"`
#'   (hourly).
#' @param site_ids A vector of site IDs to filter the manifest by.  If `"all"`
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
  site_ids = "all"
) {
  resolution <- match.arg(resolution)
  resolution <- paste0(toupper(resolution), toupper(resolution))

  files_df <- manifest %>%
    dplyr::filter(!.data$dataset %in% c("BIF", "BIFVARINFO")) %>%
    dplyr::filter(.data$time_resolution == resolution)

  if (length(site_ids) > 1 & !any(site_ids == "all")) {
    files_df <- files_df %>% dplyr::filter(.data$site_id %in% site_ids)
  }

  #TODO error if there are no files to read

  data_raw <- purrr::pmap(
    files_df %>% dplyr::select(path, site_id, dataset),
    function(path, site_id, dataset) {
      readr::read_csv(path, show_col_types = FALSE) %>%
        dplyr::mutate(site_id = site_id, dataset = dataset, .before = 1)
    }
  ) %>%
    purrr::list_rbind()

  # Parse TIMESTAMP column differently depending on time resolution
  timestamp_col <- switch(
    resolution,
    YY = "TIMESTAMP",
    MM = "TIMESTAMP",
    WW = "TIMESTAMP",
    DD = "TIMESTAMP",
    HH = c("TIMESTAMP_START", "TIMESTAMP_END")
  )

  timestamp_replace <- switch(
    resolution,
    YY = "YEAR",
    MM = "DATE",
    WW = "DATE",
    DD = "DATE",
    HH = "DATETIME"
  )

  timestamp_fun <- switch(
    resolution,
    YY = as.integer,
    MM = lubridate::ym,
    WW = lubridate::ymd,
    DD = lubridate::ymd,
    HH = lubridate::ymd_hm
  )

  data_clean <- data_raw %>%
    dplyr::mutate(
      dplyr::across(
        timestamp_col,
        timestamp_fun
      ),
      dplyr::across(dplyr::where(is.numeric), function(x) {
        dplyr::na_if(x, -9999)
      })
    ) %>%
    dplyr::rename_with(function(col) {
      stringr::str_replace(col, "TIMESTAMP", timestamp_replace)
    })

  data_clean
}
