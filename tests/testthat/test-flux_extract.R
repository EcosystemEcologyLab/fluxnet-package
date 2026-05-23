test_that("CSVs are extracted", {
  tmpdir <- withr::local_tempdir()
  out_default <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    site_ids = "US-MMS",
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
    site_ids = "US-MMS",
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
  expect_all_true(
    stringr::str_detect(
      fs::path_file(files),
      "(TERN_AU-Wom_FLUXNET_ERA5_YY_1981|TERN_AU-Wom_FLUXNET_FLUXMET_YY_2010)"
    )
  )
})

test_that("site_ids works", {
  tmpdir <- withr::local_tempdir()
  out <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    site_ids = c("US-MMS", "AU-Wom"),
    resolutions = c("y"),
    extract_varinfo = FALSE,
    extract_txt = FALSE
  )
  expect_s3_class(out, "data.frame")
})

test_that("hourly and half-hourly are extracted", {
  tmpdir <- withr::local_tempdir()
  out <- flux_extract(
    zip_dir = test_path("testdata"),
    output_dir = tmpdir,
    site_ids = c("US-MMS", "AU-Wom"),
    resolutions = c("h"),
    extract_varinfo = FALSE,
    extract_txt = FALSE
  )
  expect_true(any(stringr::str_detect(
    out$extracted_file,
    "AMF_US-MMS_FLUXNET_FLUXMET_HR_"
  )))
})