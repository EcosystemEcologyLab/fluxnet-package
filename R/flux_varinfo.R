#' Read variable info from "BIFVARINFO" files
#'
#' Extracts and tidies variable information from "BIFVARINFO" csv files.
#'
#' @param manifest A manifest data frame produced by [flux_discover_files()].
#' @inheritParams flux_read
#'
#' @note This only returns variable info (`VARIABLE_GROUP == GRP_VAR_INFO`) from
#'   the "BIFVARINFO" files as much of the other metadata they contain can be
#'   found in the results of `flux_listall()`.
#'
#'   `HEIGHT` is returned as a character value because some heights are reported
#'   as ranges and cannot be parsed as a single numeric value.
#'
#'
#' @returns A tibble
#' @examples
#' \dontrun{
#' manifest <- flux_discover_files()
#' flux_varinfo(manifest)
#' }
#'
#' @export
flux_varinfo <- function(
  manifest,
  resolution = c("y", "m", "w", "d", "h"),
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
  site_ids = "all"
) {
  resolution <- match.arg(resolution)
  resolution <- paste0(toupper(resolution), toupper(resolution))
  network_choice <- match.arg(networks, several.ok = TRUE)

  files_df <- manifest %>%
    dplyr::filter(.data$dataset == "BIFVARINFO") %>%
    dplyr::filter(.data$time_resolution == resolution) %>%
    dplyr::filter(.data$product_source_network %in% network_choice)

  if (length(site_ids) > 1 | !any(site_ids == "all")) {
    files_df <- files_df %>% dplyr::filter(.data$site_id %in% site_ids)
  }

  var_info_raw <- readr::read_csv(files_df$path, show_col_types = FALSE) %>%
    dplyr::filter(.data$VARIABLE_GROUP %in% c("VAR_INFO", "GRP_VAR_INFO"))

  var_info_tidy <- var_info_raw %>%
    tidyr::pivot_wider(names_from = "VARIABLE", values_from = "DATAVALUE") %>%
    dplyr::select(-dplyr::all_of(c("VARIABLE_GROUP", "GROUP_ID"))) %>%
    dplyr::rename_with(function(x) stringr::str_remove(x, "VAR_INFO_")) %>%
    dplyr::mutate(
      # Some heights appear to be ranges, eg "-0.02-0.06", and fail to parse as
      # numeric so this field is left as character.
      # HEIGHT = as.numeric(HEIGHT),
      # 1 date fails to parse: "199601074000".  Seems like a mistake?
      DATE = dplyr::case_when(
        DATE == "199601074000" ~ "19960107",
        .default = DATE
      ),
      DATE = lubridate::parse_date_time(
        .data$DATE,
        # Timestamps can be anything from year only all the way to minutes
        orders = c("y", "ym", "ymd", "ymdH", "ymdHM")
      )
    ) %>%
    dplyr::arrange(.data$SITE_ID, .data$VARNAME)

  var_info_tidy
}
