# Wrapper around fluxnet-shuttle listall
flux_listall <- function(dir = "fluxnet") {
  rlang::check_installed("processx")

  shuttle_installed <- system2(
    "which",
    "fluxnet-shuttle",
    stderr = NULL,
    stdout = NULL
  )
  if (shuttle_installed > 0) {
    stop(
      "Please install the fluxnet-shuttle utility (https://github.com/fluxnet/shuttle)!"
    )
  }

  listall <- processx::run("fluxnet-shuttle", c("listall", "-o", dir))
  path <- listall$stdout |> stringr::str_extract("(?<=snapshot written to ).+")
  path
}
