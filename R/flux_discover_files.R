#' Create a "manifest" of downloaded and unzipped FLUXNET data files
#'
#' @param data_dir The directory to look for FLUXNET CSV files in, typically the
#'   same as the `output_dir` used for [flux_extract()].
#' @param ... Arguments passed to [flux_listall()].
#' @returns Prints a summary of discovered available data and returns
#'   (invisibly) a dataframe with file paths and metadata extracted from file
#'   names and merged in from [flux_listall()].
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
flux_discover_files <- function(data_dir = "fluxnet/unzipped", ...) {
  metadata <- flux_listall(...)
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
        "product_source_network",
        "site_id",
        "FLUXNET",
        "dataset",
        "year_range",
        "oneflux_code_version",
        "release_version"
      )
    ) %>%
    dplyr::select(-dplyr::all_of("FLUXNET")) %>%
    tidyr::separate_wider_delim(
      "year_range",
      delim = "-",
      names = c("first_year", "last_year")
    ) %>%
    dplyr::distinct(
      .data$product_source_network,
      .data$site_id,
      .data$dataset,
      .data$first_year,
      .data$last_year,
      .data$oneflux_code_version,
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
        "product_source_network",
        "site_id",
        "FLUXNET",
        "dataset",
        "time_resolution",
        "year_range",
        "oneflux_code_version",
        "release_version"
      )
    ) %>%
    dplyr::select(-dplyr::all_of("FLUXNET")) %>%
    tidyr::separate_wider_delim(
      "year_range",
      delim = "-",
      names = c("first_year", "last_year")
    ) %>%
    dplyr::distinct(
      .data$product_source_network,
      .data$site_id,
      .data$dataset,
      .data$time_resolution,
      .data$first_year,
      .data$last_year,
      .data$oneflux_code_version,
      .data$release_version,
      .keep_all = TRUE
    ) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("year"), as.integer)) %>%
    dplyr::bind_rows(bif_manifest) %>%
    dplyr::arrange(
      .data$site_id,
      .data$dataset,
      .data$time_resolution,
      .data$first_year
    )

  summary <- manifest %>%
    dplyr::filter(!.data$dataset %in% c("BIF", "BIFVARINFO")) %>%
    dplyr::group_by(.data$time_resolution, .data$dataset) %>%
    dplyr::summarize(
      unique_sites = dplyr::n_distinct(.data$site_id),
      total_site_years = sum(
        .data$last_year - .data$first_year + 1,
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

  manifest_merged <- dplyr::left_join(
    manifest,
    metadata %>%
      dplyr::select(
        -dplyr::all_of(c("first_year", "last_year", "oneflux_code_version"))
      ),
    by = c("product_source_network", "site_id")
  )

  invisible(manifest_merged)
}
