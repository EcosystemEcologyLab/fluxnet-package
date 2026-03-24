test_that("flux_badm() works", {
  unzipped <- withr::local_tempdir()
  flux_extract(test_path("testdata"), output_dir = unzipped)
  manifest <- flux_discover_files(unzipped)

  canopy_ht <- flux_badm(manifest, "HEIGHTC")
  expect_s3_class(canopy_ht, "data.frame")
})


test_that("flux_badm() warns when variable group not found", {
  unzipped <- withr::local_tempdir()
  flux_extract(test_path("testdata"), output_dir = unzipped)
  manifest <- flux_discover_files(unzipped)

  expect_warning(
    blah <- flux_badm(manifest, "blah"),
    "`VARIABLE_GROUP` of BLAH or GRP_BLAH not found"
  )
  expect_length(blah, 0)
})
