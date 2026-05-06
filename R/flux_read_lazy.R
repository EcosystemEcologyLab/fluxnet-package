flux_read_lazy <- function(
  resolution = c("y", "m", "w", "d", "h"),
  hive_root = "fluxnet/unzipped"
) {
  # TODO: Check if hive-partitioned and warn if not, point to [flux_arrange_hive()]

  # Alert user that `arrow` is required, prompt install
  rlang::check_installed("arrow", reason = "for `flux_read_lazy()`")

  resolution <- match.arg(resolution)
  resolution <- paste0(toupper(resolution), toupper(resolution))

  resolution_path <- fs::path(
    hive_root,
    glue::glue("time_resolution={resolution}")
  )

  era5 <- arrow::open_csv_dataset(
    fs::path(resolution_path, "dataset=ERA5/"),
    unify_schemas = TRUE,
    na = c("", "NA", "-9999")
  )

  fluxmet <- arrow::open_csv_dataset(
    fs::path(resolution_path, "dataset=FLUXMET/"),
    unify_schemas = TRUE,
    na = c("", "NA", "-9999")
  )

  dataset <- c(era5, fluxmet)

  # Apply timestamp parsing
  if (resolution == "YY") {
    dataset_clean <- dataset %>%
      dplyr::mutate(
        YEAR = as.integer(TIMESTAMP),
        .after = 1,
        .keep = "unused"
      )
  } else if (resolution == "MM") {
    dataset_clean <- dataset %>%
      dplyr::mutate(
        DATE = lubridate::ym(TIMESTAMP),
        .after = 1,
        .keep = "unused"
      )
  } else if (resolution == "WW") {
    dataset_clean <- dataset %>%
      dplyr::mutate(
        DATE_START = lubridate::ymd(TIMESTAMP_START),
        DATE_END = lubridate::ymd(TIMESTAMP_END),
        .after = 1,
        .keep = "unused"
      )
  } else if (resolution == "DD") {
    dataset_clean <- dataset %>%
      dplyr::mutate(
        DATE = lubridate::ymd(TIMESTAMP),
        .after = 1,
        .keep = "unused"
      )
  } else if (resolution == "HH") {
    dataset_clean <- dataset %>%
      dplyr::mutate(
        DATETIME_START = lubridate::ymd_hm(TIMESTAMP_START),
        DATETIME_END = lubridate::ymd_hm(TIMESTAMP_END),
        .after = 1,
        .keep = "unused"
      )
  }
}
