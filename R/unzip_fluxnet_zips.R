#' Unzip downloaded FLUXNET zip files
#'
#' Unzips all CSV files in FLUXNET zip files
#'
#' @param location The path to the directory containing zip files.
#' @param exdir The directory to unzip to.
#' @param overwrite Logical; overwrite already unzipped files?
#'
#' @returns A list of two data frames, one of successfully unzipped files and
#'   one containing any failed files.
#'
#' @examples
#' \dontrun{
#' unzip_fluxnet_zips("fluxnet/icos/")
#' }
#'
#'
#' @export
unzip_fluxnet_zips <- function(
  location,
  exdir = file.path(location, "unzipped"),
  overwrite = TRUE
) {
  zip_paths <- fs::dir_ls(location, recurse = TRUE, regexp = "\\.zip$")
  dir.create(exdir, recursive = TRUE, showWarnings = FALSE)

  # prepare empty failures list
  failures <- dplyr::tibble(
    zip = character(),
    stage = character(),
    error = character()
  )

  # process each ZIP
  successes <- purrr::map_dfr(zip_paths, function(zf) {
    fname <- basename(zf)
    parts <- strsplit(tools::file_path_sans_ext(fname), "_")[[1]]
    if (length(parts) < 5) {
      failures <<- dplyr::add_row(
        failures,
        zip = fname,
        stage = "name-parse",
        error = "unexpected filename structure"
      )
      return(NULL)
    }

    data_center <- parts[1]
    site <- parts[2]
    data_product <- parts[3]
    dataset <- parts[4]
    yrs <- tryCatch(strsplit(parts[5], "-")[[1]], error = function(e) NULL)
    if (is.null(yrs) || length(yrs) != 2) {
      failures <<- dplyr::add_row(
        failures,
        zip = fname,
        stage = "year-parse",
        error = "cannot split year-range"
      )
      return(NULL)
    }
    start_year <- as.integer(yrs[1])
    end_year <- as.integer(yrs[2])

    # list contents
    contents <- tryCatch(
      utils::unzip(zf, list = TRUE),
      error = function(e) {
        failures <<- dplyr::add_row(
          failures,
          zip = fname,
          stage = "list-contents",
          error = e$message
        )
        NULL
      }
    )
    if (is.null(contents)) {
      return(NULL)
    }

    csvs <- contents$Name[grepl("\\.csv$", contents$Name)]
    if (length(csvs) == 0) {
      failures <<- dplyr::add_row(
        failures,
        zip = fname,
        stage = "filter-csv",
        error = "no .csv entries in archive"
      )
      return(NULL)
    }

    # extract CSVs
    extracted <- tryCatch(
      utils::unzip(zf, files = csvs, exdir = exdir, overwrite = overwrite),
      error = function(e) {
        failures <<- dplyr::add_row(
          failures,
          zip = fname,
          stage = "extract",
          error = e$message
        )
        character(0)
      }
    )
    if (length(extracted) == 0) {
      return(NULL)
    }

    # one row per CSV
    dplyr::tibble(
      file = file.path(exdir, extracted),
      data_center = data_center,
      site = site,
      data_product = data_product,
      dataset = dataset,
      start_year = start_year,
      end_year = end_year
    )
  })

  list(
    successes = successes,
    failures = failures
  )
}
