test_that("citations work", {
  citations <- flux_citations(
    site_ids = c("AR-Bal", "DE-Gwg"),
    output = "data.frame"
  )
  expect_s3_class(citations, "data.frame")
  expect_s3_class(citations$bibentry[[1]], "bibentry")
})

test_that("writing to bibtex works", {
  tmp <- withr::local_tempfile(fileext = ".bib")
  citations <- flux_citations(
    site_ids = c("AR-Bal", "DE-Gwg"),
    output = "bibtex",
    bibtex_path = tmp
  )
  expect_true(
    readLines(tmp)[3] == "  title = {AmeriFlux FLUXNET-1F AR-Bal Balcarce BA},"
  )
})
