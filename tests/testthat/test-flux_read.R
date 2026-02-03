test_that("flux_read() works", {
  unzipped <- withr::local_tempdir()
  flux_extract(test_path("testdata"), output_dir = unzipped)
  manifest <- flux_discover_files(unzipped)

  annual <- flux_read(manifest, resolution = "y")
  expect_s3_class(annual, "data.frame")
  expect_contains(colnames(annual), "YEAR")

  monthly <- flux_read(manifest, resolution = "m")
  expect_s3_class(monthly, "data.frame")
  expect_contains(colnames(monthly), "DATE")

  daily <- flux_read(manifest, resolution = "d")
  expect_s3_class(daily, "data.frame")
  expect_contains(colnames(daily), "DATE")

  weekly <- flux_read(manifest, resolution = "w")
  expect_s3_class(weekly, "data.frame")
  expect_contains(colnames(weekly), "DATE_START")
  expect_contains(colnames(weekly), "DATE_END")

  hourly <- flux_read(manifest, resolution = "h")
  expect_s3_class(hourly, "data.frame")
  expect_contains(colnames(hourly), "DATETIME_START")
  expect_contains(colnames(hourly), "DATETIME_END")
})

test_that("datasets filter works", {
  unzipped <- withr::local_tempdir()
  flux_extract(test_path("testdata"), output_dir = unzipped)
  manifest <- flux_discover_files(unzipped)

  fluxmet <- flux_read(manifest, datasets = "FLUXMET")
  era5 <- flux_read(manifest, datasets = "ERA5")

  expect_equal(unique(fluxmet$dataset), "FLUXMET")
  expect_equal(unique(era5$dataset), "ERA5")
})
