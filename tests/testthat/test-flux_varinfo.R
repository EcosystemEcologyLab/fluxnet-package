test_that("flux_varinfo() works", {
  unzipped <- withr::local_tempdir()
  flux_extract(test_path("testdata"), output_dir = unzipped)
  manifest <- flux_discover_files(unzipped)

  info <- flux_varinfo(manifest)
  expect_s3_class(info, "data.frame")
})
