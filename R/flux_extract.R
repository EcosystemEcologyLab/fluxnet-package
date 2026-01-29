#' Extract FLUXNET data from downloaded zip files
#'
#' Extracts data from zip files downloaded by [flux_download()] with options to
#' extract only subsets of the files they contain.
#'
#' @param zip_dir The directory with the zip files
#' @param output_dir The directory to unzip files to.  Within this directory,
#'   data files will be nested by site.
#' @param site_ids A character vector of site IDs (e.g. `c("AR-TF2", "CA-Ca2")`)
#'   can be supplied to only unzip data for certain sites.  If `"all"`
#'   (default), all zip files found in zip_dir will be unzipped.
#' @param resolutions A character vector indicating which time resolutions to
#'   extract.  Options are yearly (`"y"`), monthly (`"m"`), daily (`"d"`),
#'   and hourly/half-hourly (`"h"`). Multiple options may be passed with all of
#'   them as default.
#' @param extract_varinfo Logical; extract the BIF and BIFVARINFO files
#'   containing variable information in the BADM Interchange Format? Defaults to
#'   `TRUE`.
#' @param extract_txt Logical; extract the README.txt and
#'   DATA_POLICY_LICENSE_AND_INSTRUCTIONS.txt files? Defaults to `FALSE`.
#' @param overwrite Logical; should existing extracted files be overwritten
#'   (`TRUE`) or ignored (`FALSE`)?
#' @export
flux_extract <- function(
  zip_dir = "fluxnet",
  output_dir = fs::path(zip_dir, "unzipped"),
  site_ids = "all",
  resolutions = c("y", "m", "w", "d", "h"),
  extract_varinfo = TRUE,
  extract_txt = FALSE,
  overwrite = FALSE
) {
  zip_files <- fs::dir_ls(zip_dir, glob = "*.zip")
  zip_avail <- dplyr::tibble(zip_path = zip_files) |>
    dplyr::mutate(filename = fs::path_ext_remove(fs::path_file(zip_path))) |>
    tidyr::separate_wider_delim(
      filename,
      delim = "_",
      names = c(
        "network",
        "site_id",
        "FLUXNET",
        "year_range",
        "oneflux_version",
        "release_version"
      )
    ) |>
    dplyr::select(-FLUXNET) |>
    tidyr::separate_wider_delim(
      year_range,
      delim = "-",
      names = c("year_start", "year_end")
    )

  if (length(site_ids) == 1 && site_ids != "all" | length(site_ids) > 1) {
    zip_to_extract <- zip_avail |>
      dplyr::filter(site_id %in% site_ids)
  } else {
    zip_to_extract <- zip_avail
  }

  resolutions <- match.arg(resolutions, several.ok = TRUE)
  # TODO might be better to implement overwrite outside of unzip()
  extracted_files <- purrr::map(zip_files, \(zip) {
    flux_extract_site(
      zip,
      output_dir = output_dir,
      resolutions = resolutions,
      extract_varinfo = extract_varinfo,
      extract_txt = extract_txt,
      overwrite = overwrite
    )
  }) |>
    purrr::list_rbind()

  invisible(extracted_files)
}


# With a single zip file
flux_extract_site <- function(
  zip_file,
  output_dir,
  resolutions,
  extract_varinfo,
  extract_txt,
  overwrite
) {
  # capture errors
  safe_unzip <- purrr::safely(utils::unzip)

  all_files_try <- safe_unzip(zip_file, list = TRUE)

  if (!is.null(all_files_try$error)) {
    out <- dplyr::tibble(
      zip_file = zip_file,
      zip_file_error = all_files_try$error$message
    )
    return(out)
  } else {
    all_files <- all_files_try$result$Name
  }

  txt_files <- all_files[grepl(".txt$", all_files)]
  bif_file <- all_files[grepl("_BIF_", all_files)]
  varinfo_files <- all_files[grepl("_BIFVARINFO_", all_files)]
  data_files <- all_files[!all_files %in% c(txt_files, bif_file, varinfo_files)]

  data_avail <- dplyr::tibble(filename = data_files) |>
    tidyr::separate_wider_delim(
      filename,
      delim = "_",
      names = c(
        "network",
        "site_id",
        "FLUXNET",
        "data_type", # Either ERA5 or FLUXMET, but we'll end up joining these files, so always get both.
        "resolution",
        "year_range",
        "oneflux_version",
        "release_version"
      ),
      cols_remove = FALSE
    ) |>
    dplyr::select(-FLUXNET) |>
    dplyr::mutate(
      release_version = stringr::str_remove(release_version, "\\.csv$")
    )

  varinfo_avail <- dplyr::tibble(filename = varinfo_files) |>
    tidyr::separate_wider_delim(
      filename,
      delim = "_",
      names = c(
        "network",
        "site_id",
        "FLUXNET",
        "BIFVARINFO",
        "resolution",
        "year_range",
        "oneflux_version",
        "release_version"
      ),
      cols_remove = FALSE
    ) |>
    dplyr::select(-FLUXNET, -BIFVARINFO) |>
    dplyr::mutate(
      release_version = stringr::str_remove(release_version, "\\.csv$")
    )

  data_to_extract <- data_avail |>
    dplyr::filter(resolution %in% toupper(paste0(resolutions, resolutions)))
  varinfo_to_extract <- varinfo_avail |>
    dplyr::filter(resolution %in% toupper(paste0(resolutions, resolutions)))

  files_to_extract <- c(
    txt_files[extract_txt],
    bif_file[extract_varinfo],
    varinfo_to_extract$filename[extract_varinfo],
    data_to_extract$filename
  )

  # Extract into folders named after zip file for tidier organization
  extract_dir <- fs::dir_create(fs::path(
    output_dir,
    fs::path_ext_remove(fs::path_file(zip_file))
  ))

  # if overwrite = FALSE, don't even try to unzip
  if (isFALSE(overwrite)) {
    already_extracted <- fs::dir_ls(extract_dir) |> fs::path_file()
    files_to_extract <- files_to_extract[
      !files_to_extract %in% already_extracted
    ]
    if (length(files_to_extract) == 0) {
      out <- dplyr::tibble(
        zip_file = zip_file,
        zip_file_error = glue::glue(
          "All requested files already extracted, set `overwrite = TRUE` to overwrite."
        )
      )
      return(out)
    }
  }
  extracted_try <- safe_unzip(
    zipfile = zip_file,
    files = files_to_extract,
    overwrite = overwrite,
    exdir = extract_dir
  )

  if (!is.null(extracted_try$error)) {
    out <- dplyr::tibble(
      zip_file = zip_file,
      zip_file_error = all_files_try$error$message
    )
    return(out)
  } else {
    out <- dplyr::tibble(zip_file = zip_file, zip_file_error = NA)
    if (length(extracted_try$result) > 1) {
      out <- out |> tidyr::expand_grid(extracted_file = extracted_try$result)
    }
  }

  
# Return
  return(out)
}
