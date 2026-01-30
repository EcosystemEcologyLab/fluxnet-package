test_that("manifest is correct", {
  tempdir <- withr::local_tempdir()
  flux_extract(
    zip_dir = test_path("testdata"),
    resolutions = c("y", "m"),
    output_dir = tempdir,
    extract_varinfo = TRUE,
    extract_txt = FALSE
  )
  expect_message(
    manifest <- flux_discover_files(data_dir = tempdir),
    "MM / ERA5 → 1 site, 44 site-years across 1 file
MM / FLUXMET → 1 site, 7 site-years across 1 file
YY / ERA5 → 1 site, 44 site-years across 1 file
YY / FLUXMET → 1 site, 7 site-years across 1 file"
  )
  expect_s3_class(manifest, "data.frame")

  expect_equal(unique(manifest$time_resolution), c(NA, "MM", "YY"))
})
