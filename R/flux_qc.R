#' Flag overly-gapfilled data
#'
#' Flags rows of data based on variables with associated `_QC` columns.
#'
#' @param data A data frame created by [flux_read()].
#' @param qc_vars A character vector of column names with associated `*_QC`
#'   columns to use for flagging.
#' @param threshold For aggregated data (weekly, daily, monthly, annual), a
#'   number between 0 and 1. For hourly and half-hourly data, either 0, 1, 2, or
#'   3 corresponding to 0 = measured, 1 = good quality gap-fill (MDS), 2 =
#'   medium quality gap-fill, 3 = poor quality gap-fill. Rows with `_QC` values
#'   greater than the number provided will be be flagged with `qc_flagged =
#'   TRUE`. Input can be length 1 or the same length as `qc_vars` to supply a
#'   different threshold for each variable.
#' @param operator How to flag data when multiple `qc_vars` are supplied?  If
#'   "any", the row will be marked as bad if *any* of the QC vars indicate
#'   gap-filling above their `max_gapfill` threshold.  If "all" then the row
#'   will be flagged only if *all* of the QC vars are above their `max_gapfill`.
#' @param max_gapfilled `r lifecycle::badge("deprecated")` Deprecated; use
#'   `threshold` instead.
#' @returns A tibble with the added columns `p_gapfilled` and `qc_flagged`. If
#'   `operator = "any"`, `qc_flagged = TRUE` indicates that at least one of the
#'   supplied QC variables was more gapfilled than `threshold` and `p_gapfilled`
#'   will be the maximum proportion gapfilled across the QC vars for each row.
#'   If `operator = "all"`, then `qc_flagged = TRUE` indicates that *all* of the
#'   supplied QC variables were more gapfilled than the thresholds supplies and
#'   `p_gapfilled` will be the minimum proportion gapfilled across all QC
#'   variables for each row.
#' @examples
#' \dontrun{
#'
#' # Flag rows where NEE_VUT_REF is more than 50% gapfilled
#' manifest <- flux_discover_files()
#' annual <- flux_read(manifest, resolution = "y")
#' annual_flagged <- flux_qc(
#'   annual,
#'   qc_vars = "NEE_VUT_REF",
#'   threshold = 0.5
#' )
#'
#' # Use multiple variables each with a different threshold for QC
#' annual_flagged2 <- flux_qc(
#'   annual,
#'   qc_vars = c("NEE_VUT_REF", "TA_F"),
#'   threshold = c(0.4, 0.6)
#' )
#'
#' # Same as above, but require *both* variables to be above their thresholds
#' # to consider that row a problem
#' annual_flagged2 <- flux_qc(
#'   annual,
#'   qc_vars = c("NEE_VUT_REF", "TA_F"),
#'   threshold = c(0.4, 0.6),
#'   operator = "all"
#' )
#'
#' }
#'
#' @export
flux_qc <- function(
  data,
  qc_vars,
  threshold = 0.5,
  operator = c("any", "all"),
  max_gapfilled = deprecated()
) {
  if (lifecycle::is_present(max_gapfilled)) {
    lifecycle::deprecate_warn(
      "0.5.0",
      "flux_qc(max_gapfilled)",
      "flux_qc(threshold)"
    )
    threshold <- max_gapfilled
  }
  # Doesn't make sense for hourly resolution where _QC columns are categorical flags
  if (attr(data, "flux_resolution") == "HH") {
    cli::cli_abort(
      "{.fun flux_qc()} doesn't work with hourly data where {.col *_QC} columns are categorical."
    )
  }
  if (!all(dplyr::between(threshold, 0, 1))) {
    cli::cli_abort("{.arg threshold} must have values between 0 and 1.")
  }

  if (length(qc_vars) > 1 & length(threshold) == 1) {
    threshold <- rep(threshold, length(qc_vars))
  } else if (length(threshold) != length(qc_vars)) {
    cli::cli_abort(
      "{.arg threshold} must be length 1 or match the length of {.arg qc_vars}."
    )
  }

  operator <- match.arg(operator)

  qc_cols <- paste0(qc_vars, "_QC")
  if (all(!qc_cols %in% colnames(data))) {
    cli::cli_warn(c(
      "!" = "QC column{?s} {.var {qc_cols}} not found",
      i = "No rows flagged"
    ))
    data$p_gapfilled <- NA_real_
    data$qc_flagged <- NA
    return(data)
  }

  operator_fun <- switch(
    operator,
    all = `&`,
    any = `|`
  )

  # These may look reversed, but it's because they get applied to the QC columns
  # which are the proprotion of data that is "good", not proportion gapfilled.
  # Proportion gapfilled is 1-pfun(qc_cols). These work with code below becuase
  # results of pick() is a tibble and inject + !!! converts a tibble into
  # df[[1]], df[[2]], df[[3]]...
  pfun <- switch(
    operator,
    all = function(data, na.rm = TRUE) {
      rlang::inject(pmax(!!!data, na.rm = na.rm))
    },
    any = function(data, na.rm = TRUE) {
      rlang::inject(pmin(!!!data, na.rm = na.rm))
    }
  )
  data_flagged <- data %>%
    dplyr::mutate(
      qc_flagged = purrr::map2(
        data %>% dplyr::select(dplyr::any_of(qc_cols)),
        threshold,
        function(col, threshold) {
          gapfilled <- 1 - col
          gapfilled > threshold
        }
      ) %>%
        purrr::reduce(operator_fun),
      p_gapfilled = 1 - pfun(dplyr::pick(dplyr::any_of(qc_cols)), na.rm = TRUE)
    )
  # Return
  data_flagged
}
