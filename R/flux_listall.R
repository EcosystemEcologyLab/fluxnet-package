#' List available FLUXNET zip files for download
#'
#' This provides a wrapper around the
#' [fluxnet-shuttle](https://github.com/fluxnet/shuttle) command-line utility's
#' `listall` command, which downloads a data frame of available .zip files. By
#' default, the downloaded CSV is stored in
#' `rappdirs::user_cache_dir("fluxnet")`.  If there is allready a FLUXNET
#' shanpshot CSV file downloaded and it is more recent than `cache_age`, it will
#' be read in instead of downloading a new snapshot (unless `cache = FALSE`).
#'
#' @param cache_dir The directory to store the list of available FLUXNET data
#'   in.
#' @param use_cache Logical; use cached list of files available to download if
#'   it exists and is not older than `cache_age`?
#' @param cache_age A `difftime` object of length 1. If there are no cached
#'   snapshots more recent than `cache_age`, a new one will be downloaded and
#'   stored. You can force the cache to be invalidated with `cache_age = -Inf`.
#' @param log_file An optional file path (e.g. `"log.txt"`) to direct the
#'   `fluxnet-shuttle` log to. Useful for debugging.
#' @param echo_cmd Set to `TRUE` to print the shell command in the console.
#'   Passed to [processx::run()].
#' @returns A data frame of stations with available data and their metadata.
#' @examples
#' \dontrun{
#' fluxnet_files <- flux_listall()
#' }
#' @export
flux_listall <- function(
  cache_dir = rappdirs::user_cache_dir("fluxnet"),
  use_cache = TRUE,
  cache_age = as.difftime(30, units = "days"),
  log_file = NULL,
  echo_cmd = FALSE
) {
  # Check if there is already a recently downloaded list
  fs::dir_create(cache_dir)
  cached_snapshots <- dplyr::tibble(
    path = fs::dir_ls(
      cache_dir,
      regexp = "fluxnet_shuttle_snapshot_\\d+T\\d+\\.csv$"
    )
  ) |>
    dplyr::mutate(timestamp = stringr::str_extract(path, "\\d+T\\d+")) |>
    dplyr::mutate(datetime = lubridate::ymd_hms(timestamp)) |>
    dplyr::mutate(expired = datetime + cache_age < Sys.time()) |>
    dplyr::arrange(desc(datetime))

  if (
    nrow(cached_snapshots |> dplyr::filter(!expired)) == 0 |
      isFALSE(use_cache)
  ) {
    fluxnet_shuttle <- fluxnet_shuttle_executable("fluxnet")
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
    csv_file <- listall$stdout |>
      stringr::str_extract("(?<=snapshot written to ).+")

    list <- readr::read_csv(
      fs::path(csv_file),
      show_col_types = FALSE
    )
    return(list)
  } else {
    #just read the newest cached one
    csv_path <- cached_snapshots |>
      dplyr::filter(!expired & datetime == max(datetime)) |>
      dplyr::pull(path)
    list <- readr::read_csv(csv_path, show_col_types = FALSE)
    return(list)
  }
}
