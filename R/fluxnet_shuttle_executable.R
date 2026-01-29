#' Big thanks to Andrew Heiss for helping me figure this out!
#' @noRd
fluxnet_shuttle_executable <- function(virtualenv = "fluxnet") {
  #TODO: check if virtualenv already exists and print message if not
  reticulate::virtualenv_create(
    virtualenv,
    version = ">=3.11,<3.14",
    packages = "git+https://github.com/fluxnet/shuttle.git"
  )
  env_path <- reticulate::virtualenv_python(virtualenv)
  executable <- file.path(dirname(env_path), "fluxnet-shuttle")

  executable
}
