test_that("map works", {
  tmp <- withr::local_tempdir()
  flux_extract(
    testthat::test_path("testdata"),
    output_dir = tmp,
    resolutions = "y"
  )
  manifest <- flux_discover_files(tmp)
  p <- flux_map_sites(manifest)
  expect_s3_class(p, "ggplot")
})
