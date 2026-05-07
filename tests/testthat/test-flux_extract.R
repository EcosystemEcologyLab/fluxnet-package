test_that("CSVs are extracted", {
  tmpdir <- withr::local_tempdir()
  out_default <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    site_ids = "AR-CCg",
    resolutions = c("y", "m", "w", "d", "h"),
    extract_varinfo = TRUE,
    extract_txt = FALSE
  )
  expect_s3_class(out_default, "data.frame")
  expect_length(out_default$extracted_file, 16)
})

test_that(".txt are extracted", {
  tmpdir <- withr::local_tempdir()
  out_txt <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    site_ids = "AR-CCg",
    resolutions = c("y"),
    extract_varinfo = FALSE,
    extract_txt = TRUE
  )
  files <- fs::path_file(out_txt$extracted_file)
  expect_true("README.txt" %in% files)
  expect_true("DATA_POLICY_LICENSE_AND_INSTRUCTIONS.txt" %in% files)
})

test_that("network arg works", {
  tmpdir <- withr::local_tempdir()
  out_tern <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    network = "TERN",
    resolutions = c("y"),
    extract_varinfo = FALSE,
    extract_txt = TRUE
  )
  files <- fs::dir_ls(tmpdir, glob = "*.csv", recurse = TRUE)
  expect_equal(
    fs::path_file(files),
    c(
      "TERN_AU-Wom_FLUXNET_ERA5_YY_1981-2024_v1.3_r1.csv",
      "TERN_AU-Wom_FLUXNET_FLUXMET_YY_2010-2024_v1.3_r1.csv"
    )
  )
})

test_that("site_ids works", {
  tmpdir <- withr::local_tempdir()
  out <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    site_ids = c("AR-CCg", "AU-Wom"),
    resolutions = c("y"),
    extract_varinfo = FALSE,
    extract_txt = FALSE
  )
  expect_s3_class(out, "data.frame")
})