.onLoad <- function(...) {
  reticulate::py_require(
    packages = "git+https://github.com/fluxnet/shuttle.git",
    python_version = ">=3.11,<3.14"
  )
}
