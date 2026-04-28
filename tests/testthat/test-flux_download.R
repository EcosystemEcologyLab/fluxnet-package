test_that("download of all files works", {
  skip_on_ci()
  download_dir <- withr::local_tempdir()
  snapshot <- flux_listall()
  out <- flux_download(
    file_list_df = head(snapshot, n = 2),
    download_dir = download_dir
  )
  expect_equal(nrow(out), 2)
})

test_that("download of specified site_ids works", {
  skip_on_ci()
  download_dir <- withr::local_tempdir()
  out <- flux_download(
    site_ids = c("NZ-ScF"),
    download_dir = download_dir
  )
  expect_equal(nrow(out), 1)
})
