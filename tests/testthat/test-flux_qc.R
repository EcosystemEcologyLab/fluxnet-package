test_that("flux_qc works with aggregated data", {
  tempdir <- withr::local_tempdir()
  flux_extract(
    zip_dir = test_path("testdata"),
    resolutions = c("y"),
    output_dir = fs::path(tempdir, "copy1"),
    extract_varinfo = TRUE,
    extract_txt = FALSE
  )
  manifest <- flux_discover_files(data_dir = tempdir)
  annual <- flux_read(manifest, "y")

  annual1 <- flux_qc(annual, "NEE_VUT_REF")
  expect_s3_class(annual1, "data.frame")
  annual2 <- flux_qc(annual, c("NEE_VUT_REF", "TA_F"))
  expect_s3_class(annual2, "data.frame")
  expect_error(flux_qc(annual, "NEE_VUT_REF", threshold = c(0.4, 0.5)))
  expect_lt(
    nrow(annual1 %>% dplyr::filter(qc_flagged)),
    nrow(annual2 %>% dplyr::filter(qc_flagged))
  )
  annual3 <- flux_qc(annual, c("NEE_VUT_REF", "TA_F"), operator = "all")
  expect_s3_class(annual3, "data.frame")
})

test_that("flux_qc works with hourly data", {})