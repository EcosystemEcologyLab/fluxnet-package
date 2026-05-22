test_that("manifest is correct", {
  tempdir <- withr::local_tempdir()
  flux_extract(
    zip_dir = test_path("testdata"),
    resolutions = c("y", "m"),
    output_dir = tempdir,
    extract_varinfo = TRUE,
    extract_txt = FALSE
  )
  manifest <- flux_discover_files(data_dir = tempdir)
  expect_s3_class(manifest, "data.frame")

  expect_equal(unique(manifest$time_resolution), c(NA, "MM", "YY"))
})

test_that("deduplication works", {
  tempdir <- withr::local_tempdir()
  flux_extract(
    zip_dir = test_path("testdata"),
    site_ids = "US-MMS",
    resolutions = c("y", "m"),
    output_dir = fs::path(tempdir, "copy1"),
    extract_varinfo = TRUE,
    extract_txt = FALSE
  )
  flux_extract(
    zip_dir = test_path("testdata"),
    site_ids = "US-MMS",
    resolutions = c("y", "m"),
    output_dir = fs::path(tempdir, "copy2"),
    extract_varinfo = TRUE,
    extract_txt = FALSE
  )
  expect_warning(
    manifest <- flux_discover_files(data_dir = tempdir),
    "7 duplicate files removed:"
  )
  expect_equal(
    nrow(manifest %>% dplyr::filter(stringr::str_detect(path, "copy2"))),
    7
  )
    expect_equal(
      nrow(manifest %>% dplyr::filter(stringr::str_detect(path, "copy1"))),
      0
    )
})