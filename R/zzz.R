.onLoad <- function(...) {
  reticulate::py_require(
    packages = "git+https://github.com/fluxnet/shuttle.git",
    python_version = ">=3.11,<3.14"
  )
}

.onAttach <- function(lib, pkg) {
  cli::cli_div(theme = list(span.emph = list(color = "orange")))
  cli::cli_inform(
    c(
      "!" = "Use of data downloaded by {.pkg fluxnet} requires you abide by FLUXNET data policies: {.url https://fluxnet.org/data/data-policy/}",
      i = "Citations for individual sites' datasets are returned by {.fun fluxnet::flux_listall}"
    ),
    class = "packageStartupMessage"
  )
}