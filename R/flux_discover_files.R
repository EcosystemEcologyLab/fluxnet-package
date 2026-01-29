#' Create a "manifest" of downloaded and unzipped FLUXNET data files
#'
#' @param data_dir The directory to look for FLUXNET CSV files in, typically the
#'   same as the `output_dir` used for [flux_extract()].
#' @returns Prints a summary of discovered available data and returns
#'   (invisibly) a dataframe with file paths and metadata extracted from file
#'   names.
#' @examples
#' \dontrun{
#' # Download data
#' flux_download(site_ids = c("AU-Boy", "BR-CST"))
#'
#' # Extract annual and monthly data
#' flux_extract(resolutions = c("y", "m"))
#'
#' # Create a manifest of extracted files
#' manifest <- flux_discover_files()
#' }
#' @export
flux_discover_files <- function(data_dir = "fluxnet/unzipped") {
  all_files <- fs::dir_ls(data_dir, glob = "*.csv", recurse = TRUE)
  bif_files <- all_files[grepl("_BIF_", all_files)]
  varinfo_files <- all_files[grepl("_BIFVARINFO_", all_files)]
  data_files <- all_files[!all_files %in% c(bif_files, varinfo_files)]

  bif_manifest <- dplyr::tibble(
    path = bif_files,
    filename = fs::path_file(.data$path) %>% fs::path_ext_remove()
  ) %>%
    tidyr::separate_wider_delim(
      "filename",
      delim = "_",
      names = c(
        "network",
        "site_id",
        "FLUXNET",
        "dataset",
        "year_range",
        "oneflux_version",
        "release_version"
      )
    ) %>%
    dplyr::select(-dplyr::all_of("FLUXNET")) %>%
    tidyr::separate_wider_delim(
      "year_range",
      delim = "-",
      names = c("start_year", "end_year")
    ) %>%
    dplyr::distinct(
      .data$network,
      .data$site_id,
      .data$dataset,
      .data$start_year,
      .data$end_year,
      .data$oneflux_version,
      .data$release_version,
      .keep_all = TRUE
    ) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("year"), as.integer))

  manifest <-
    dplyr::tibble(
      path = c(data_files, varinfo_files),
      filename = fs::path_file(.data$path) %>% fs::path_ext_remove()
    ) %>%
    tidyr::separate_wider_delim(
      "filename",
      delim = "_",
      names = c(
        "network",
        "site_id",
        "FLUXNET",
        "dataset",
        "time_resolution",
        "year_range",
        "oneflux_version",
        "release_version"
      )
    ) %>%
    dplyr::select(-dplyr::all_of("FLUXNET")) %>%
    tidyr::separate_wider_delim(
      "year_range",
      delim = "-",
      names = c("start_year", "end_year")
    ) %>%
    dplyr::distinct(
      .data$network,
      .data$site_id,
      .data$dataset,
      .data$time_resolution,
      .data$start_year,
      .data$end_year,
      .data$oneflux_version,
      .data$release_version,
      .keep_all = TRUE
    ) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("year"), as.integer)) %>%
    dplyr::bind_rows(bif_manifest) %>%
    dplyr::arrange(
      .data$site_id,
      .data$dataset,
      .data$time_resolution,
      .data$start_year
    )

  summary <- manifest %>%
    dplyr::filter(!.data$dataset %in% c("BIF", "BIFVARINFO")) %>%
    dplyr::group_by(.data$time_resolution, .data$dataset) %>%
    dplyr::summarize(
      unique_sites = dplyr::n_distinct(.data$site_id),
      total_site_years = sum(
        .data$end_year - .data$start_year + 1,
        na.rm = TRUE
      ),
      n_files = dplyr::n(),
      .groups = "drop"
    ) %>%
    dplyr::arrange(.data$time_resolution, .data$dataset)

  purrr::pmap(
    summary,
    function(
      time_resolution,
      dataset,
      unique_sites,
      total_site_years,
      n_files
    ) {
      cli::pluralize(
        "{time_resolution} / {dataset} \u2192 {unique_sites} site{?s}, {total_site_years} site-year{?s} across {n_files} file{?s}"
      )
    }
  ) %>%
    cli::cli_inform()

  invisible(manifest)
}
