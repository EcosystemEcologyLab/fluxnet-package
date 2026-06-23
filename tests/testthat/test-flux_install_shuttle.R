test_that("installing fluxnet-shuttle dev version from github works", {
  on.exit(reticulate::virtualenv_remove("fluxnet-package-tests"), add = TRUE)
  exe <- flux_install_shuttle(venv = "fluxnet-package-tests")
  expect_type(exe, "character")
})

test_that("specifying a version works", {
  on.exit(reticulate::virtualenv_remove("fluxnet-package-tests"), add = TRUE)
  exe <- flux_install_shuttle(
    venv = "fluxnet-package-tests",
    shuttle_version = "0.3.6"
  )
  version_raw <- system2(exe, "--version", stdout = TRUE, stderr = FALSE)
  expect_equal(version_raw, "fluxnet-shuttle 0.3.6")

  expect_warning(flux_install_shuttle(
    venv = "fluxnet-package-tests", # should already have 0.3.6 installed in it
    shuttle_version = "0.3.7"
  ))
})
