#' List available FLUXNET zip files for download
#'
#' This provides a wrapper around the
#' [fluxnet-shuttle](https://github.com/fluxnet/shuttle) command-line utility's
#' `listall` command, which downloads a data frame of available .zip files. By
#' default, the downloaded CSV is stored in
#' `rappdirs::user_cache_dir("fluxnet")`.  If there is allready a FLUXNET
#' shanpshot CSV file downloaded and it is more recent than `cache_age`, it will
#' be read in instead of downloading a new snapshot.
#'
#'
#' @note To force the `fluxnet` R package to re-install the `fluxnet-shuttle`
#' utility, remove the Pyhton virtualenv it is installed in by running
#' `reticulate::virtualenv_remove("fluxnet")`. Then, when you run
#' `flux_listall()` next, the virtualenv will be re-created and
#' `fluxnet-shuttle` will be re-installed.
#'
#' @param cache_dir The directory to store the list of available FLUXNET data
#'   in.
#' @param cache_age A `difftime` object of length 1. If there are no cached
#'   snapshots more recent than `cache_age`, a new one will be downloaded and
#'   stored. You can force the cache to be invalidated with `cache_age = -Inf`.
#' @param clean_cache A number of files \eqn{\geq 1} to keep in `cache_dir`.
#'   Defaults to 10, which keeps only the 10 most recent snapshots.
#' @param log_file An optional file path (e.g. `"log.txt"`) to direct the
#'   `fluxnet-shuttle` log to. Useful for debugging.
#' @param echo_cmd Set to `TRUE` to print the shell command in the console.
#'   Passed to [processx::run()].
#' @param ... Arguments passed to [flux_install_shuttle()].
#' @returns A data frame of stations with available data and their metadata.
#' @examples
#' \dontrun{
#' fluxnet_files <- flux_listall()
#'
#' # Invalidate cache and update it
#' fluxnet_files <- flux_listall(cache_age = -Inf)
#' }
#' @export
flux_listall <- function(
  cache_dir = rappdirs::user_cache_dir("fluxnet"),
  cache_age = as.difftime(1, units = "days"),
  clean_cache = 10L,
  log_file = NULL,
  echo_cmd = FALSE,
  ...
) {
  # Check if there is already a recently downloaded list
  fs::dir_create(cache_dir)
  cached_snapshots <- dplyr::tibble(
    path = fs::dir_ls(
      cache_dir,
      regexp = "fluxnet_shuttle_snapshot_\\d+T\\d+\\.csv$"
    )
  ) %>%
    dplyr::mutate(timestamp = stringr::str_extract(.data$path, "\\d+T\\d+")) %>%
    dplyr::mutate(datetime = lubridate::ymd_hms(.data$timestamp)) %>%
    dplyr::mutate(expired = .data$datetime + cache_age < Sys.time()) %>%
    dplyr::arrange(dplyr::desc(.data$datetime))

  if (nrow(cached_snapshots %>% dplyr::filter(!.data$expired)) == 0) {
    fluxnet_shuttle <- flux_install_shuttle(...)
    cli::cli_inform("File list is expired, downloading the latest version")

    if (is.null(log_file)) {
      log_cmd <- "--no-logfile"
    } else {
      log_cmd <- c("-l", log_file)
    }
    listall <- processx::run(
      fluxnet_shuttle,
      c(log_cmd, "listall", "-o", fs::path_expand(cache_dir)),
      echo_cmd = echo_cmd
    )
    csv_file <- listall$stdout %>%
      stringr::str_extract("(?<=snapshot written to ).+")

    list <- readr::read_csv(
      fs::path(csv_file),
      show_col_types = FALSE
    )
  } else {
    #just read the newest cached one
    csv_path <- cached_snapshots %>%
      dplyr::filter(!.data$expired & .data$datetime == max(.data$datetime)) %>%
      dplyr::pull(.data$path)
    list <- readr::read_csv(csv_path, show_col_types = FALSE)
  }

  # Remove oldest files so there's only at max `clean_cache` snapshots saved
  if (clean_cache < 1) {
    cli::cli_inform("{.arg clean_cache} must be \u2265 1. Setting to 1.")
    clean_cache <- 1L
  }
  keep <- cached_snapshots %>% dplyr::slice_max(.data$datetime, n = clean_cache)
  fs::file_delete(
    dplyr::anti_join(
      cached_snapshots,
      keep,
      by = c("path", "timestamp", "datetime", "expired")
    )$path
  )

  return(list)
}
