# Flag overly-gapfilled data

Flags rows of data based on variables with associated `_QC` columns.

## Usage

``` r
flux_qc(data, qc_vars, max_gapfilled = 0.5, operator = c("any", "all"))
```

## Arguments

- data:

  A data frame created by
  [`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md).

- qc_vars:

  A character vector of column names with associated `*_QC` columns to
  use for flagging.

- max_gapfilled:

  Numeric between 0 and 1; cutoff for the `qc_flagged` flag to be
  `TRUE`. Can be length 1 or the same length as `qc_vars` to supply a
  different threshold for each variable.

- operator:

  How to flag data when multiple `qc_vars` are supplied? If "any", the
  row will be marked as bad if *any* of the QC vars indicate gap-filling
  above their `max_gapfill` threshold. If "all" then the row will be
  flagged only if *all* of the QC vars are above their `max_gapfill`.

## Value

A tibble with the added columns `p_gapfilled` and `qc_flagged`. If
`operator = "any"`, `qc_flagged = TRUE` indicates that at least one of
the supplied QC variables was more gapfilled than `max_gapfilled` and
`p_gapfilled` will be the maximum proportion gapfilled across the QC
vars for each row. If `operator = "all"`, then `qc_flagged = TRUE`
indicates that *all* of the supplied QC variables were more gapfilled
than the thresholds supplies and `p_gapfilled` will be the minimum
proportion gapfilled across all QC variables for each row.

## Examples

``` r
if (FALSE) { # \dontrun{

# Flag rows where NEE_VUT_REF is more than 50% gapfilled
manifest <- flux_discover_files()
annual <- flux_read(manifest, resolution = "y")
annual_flagged <- flux_qc(
  annual,
  qc_vars = "NEE_VUT_REF",
  max_gapfilled = 0.5
)

# Use multiple variables each with a different threshold for QC
annual_flagged2 <- flux_qc(
  annual,
  qc_vars = c("NEE_VUT_REF", "TA_F"),
  max_gapfilled = c(0.4, 0.6)
)

# Same as above, but require *both* variables to be above their thresholds
# to consider that row a problem
annual_flagged2 <- flux_qc(
  annual,
  qc_vars = c("NEE_VUT_REF", "TA_F"),
  max_gapfilled = c(0.4, 0.6),
  operator = "all"
)

} # }
```
