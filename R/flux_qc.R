#' Flag overly-gapfilled data
#'
#' Flags rows of data based on variables with associated `_QC` columns.
#'
#' @param data A data frame created by [flux_read()].
#' @param qc_vars A character vector of column names with associated `*_QC`
#'   columns to use for flagging.
#' @param max_gapfilled Numeric between 0 and 1; cutoff for the `is_bad` flag to
#'   be `TRUE`.
#' @param if_missing Set the behavior for rows with `NA` for the `*_QC`
#'   columns.  If `"flag"`, an `NA` will get the `is_bad = TRUE` flag.  If
#'   `"ignore"`, the `is_bad` flag will be `NA` also.
#' @returns A tibble with the added columns `pct_gapfilled` (the maximum
#'   proportion gapfilled of all the `qc_vars` for each row) and `is_bad` (a
#'   flag indicating whether a row had `pct_gapfilled` > `max_gapfilled`).
#' @examples
#' \dontrun{
#'
#' # Flag rows where NEE_VUT_REF is more than 50% gapfilled
#' manifest <- flux_discover_files()
#' annual <- flux_read(manifest, resolution = "y")
#' annual_flagged <- flux_qc(
#'   annual,
#'   qc_vars = "NEE_VUT_REF",
#'   max_gapfilled = 0.5,
#'   if_missing = "ignore"
#' )
#'
#' # Treat `NA`s in the `NEE_VUT_REF_QC` column as over the threshold
#' annual_flagged2 <- flux_qc(
#'   annual,
#'   qc_vars = "NEE_VUT_REF",
#'   max_gapfilled = 0.5,
#'   if_missing = "flag"
#' )
#'
#' }
#'
#' @export
flux_qc <- function(
  data,
  qc_vars,
  max_gapfilled = 0.5,
  if_missing = c("flag", "ignore")
) {
  # TODO allow to use different thresholds for different qc_vars
  # TODO option to switch between ANY and ALL variables meeting the threshsolds
  # TODO input validation
  # - max_gapfilled between 0, 1
  # - length of qc_vars matches length of max_gapfilled if it is not length 1

  if_missing <- match.arg(if_missing)
  qc_cols <- paste0(qc_vars, "_QC")
  if (all(!qc_cols %in% colnames(data))) {
    cli::cli_warn("QC column{?s} {qc_cols} not found. No filtering applied.")
    df$pct_gapfilled <- NA_real_
    df$is_bad <- if (if_missing == "flag") {
      TRUE
    } else if (if_missing == "ignore") {
      NA
    }
    return(df)
  }

  # works with code below becuase results of pick() is a tibble
  # inject + !!! converts dataframe into df[[1]], df[[2]], df[[3]]...
  pmin_df <- function(data, na.rm = TRUE) {
    rlang::inject(pmin(!!!data, na.rm = na.rm))
  }

  data2 <- data %>%
    # pct_gapfilled reflects the *most* gapfilled of the qc_vars
    dplyr::mutate(
      pct_gapfilled = 1 -
        pmin_df(dplyr::pick(dplyr::any_of(qc_cols)), na.rm = TRUE)
    )

  data2$pct_gapfilled <- pmax(0, pmin(1, data2$pct_gapfilled)) # clamp just in case

  data3 <- data2 %>%
    mutate(
      is_bad = dplyr::case_when(
        if_missing == "flag" & is.na(pct_gapfilled) ~ TRUE,
        if_missing == "ignore" & is.na(pct_gapfilled) ~ NA,
        .default = pct_gapfilled > max_gapfilled
      )
    )
  data3
}
