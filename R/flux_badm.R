#' Read and tidy BADM subsets
#'
#' Reads in BADM data from "BIF" csv files, subsets to a single `VARIABLE_GROUP`
#' and returns a wide data frame.
#'
#' @inheritParams flux_read
#' @param variable_group A single `VARIABLE_GROUP` without a `GRP_` prefix.
#'   Options can be viewed at
#'   <https://ameriflux.lbl.gov/data/badm/badm-standards/>
#' @returns A tibble.
#' @examples
#' \dontrun{
#' manifest <- flux_discover_files()
#' flux_badm(manifest, "SOIL_CHEM")
#' flux_badm(manifest, "LAI")
#' }
#' @export
flux_badm <- function(
  manifest,
  variable_group,
  site_ids = NULL,
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
  )
) {
  if (!is.null(site_ids)) {
    if (any(site_ids == "all")) {
      cli::cli_warn(
        "Setting {.arg site_ids = 'all'} is deprecated. Using {.arg site_ids = NULL} instead."
      )
      site_ids <- NULL
    }
  }
  network_choice <- match.arg(networks, several.ok = TRUE)

  var_grp <- toupper(c(variable_group, paste0("GRP_", variable_group)))

  files_df <- manifest %>%
    dplyr::filter(.data$dataset == "BIF") %>%
    dplyr::filter(.data$product_source_network %in% network_choice)
  if (!is.null(site_ids)) {
    files_df <- files_df %>% dplyr::filter(.data$site_id %in% site_ids)
  }

  # Workaround for https://github.com/EcosystemEcologyLab/fluxnet-package/issues/57
  # TODO: This workaround comes at a cost of speed.  There might be a better
  # solution upstream in `readr` someday:
  # https://github.com/tidyverse/readr/issues/1623

  # bif_raw <- readr::read_csv(files_df$path, show_col_types = FALSE)
  bif_raw <- purrr::map(files_df$path, function(x) {
    readr::read_csv(
      x,
      col_select = c(
        "SITE_ID",
        "GROUP_ID",
        "VARIABLE_GROUP",
        "VARIABLE",
        "DATAVALUE"
      ),
      show_col_types = FALSE
    )
  }) %>%
    purrr::list_rbind()

  bif_var_group <- bif_raw %>% dplyr::filter(.data$VARIABLE_GROUP %in% var_grp)

  if (nrow(bif_var_group) == 0) {
    var_grp_cli <- cli::cli_vec(var_grp, style = list(vec_last = " or "))
    cli::cli_warn("{.var VARIABLE_GROUP} of {var_grp_cli} not found")
    return(dplyr::tibble())
  }

  bif_tidy <- bif_var_group %>%
    tidyr::pivot_wider(
      names_from = "VARIABLE",
      values_from = "DATAVALUE"
    ) # %>%
  # dplyr::select(-dplyr::all_of(c("GROUP_ID", "VARIABLE_GROUP")))
  # dplyr::mutate(dplyr::across(dplyr::ends_with("_DATE"), \(x) {
  #   lubridate::parse_date_time(
  #     x,
  #     # Timestamps can be anything from year only all the way to minutes
  #     orders = c("y", "ym", "ymd", "ymdH", "ymdHM")
  #   )
  # }))
  bif_tidy
}
