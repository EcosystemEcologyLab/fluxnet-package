#' Big thanks to Andrew Heiss for helping me figure this out!
#' @noRd
fluxnet_shuttle_executable <- function(virtualenv = "fluxnet") {
  #TODO: check if virtualenv already exists and print message if not
  reticulate::virtualenv_create(
    virtualenv,
    version = ">=3.11,<3.14",
    packages = "git+https://github.com/fluxnet/shuttle.git@0.3.7"
  )
  env_path <- reticulate::virtualenv_python(virtualenv)
  executable <- file.path(dirname(env_path), "fluxnet-shuttle")

  executable
}

#' Install the fluxnet-shuttle CLI
#'
#' Uses `reticulate` to install the
#' [fluxnet-shuttle](https://fluxnet.github.io/shuttle/) Python library and
#' command line interface into a virtual environment.  Required for
#' [flux_listall()] and [flux_download()].
#'
#' @note This will be run automatically the first time you run [flux_listall()]
#'   or [flux_download()], so it is not necessary to run this function
#'   separately first.
#'
#' @param venv A name to use for creating a virtual environment.  Defaults to
#'   `"fluxnet"`, but we recommend using a project-specific virtual environment.
#'   You can set this in a project-level `.Renviron` file as
#'   `FLUXNET_VENV=myproject` and it will be pulled from there.
#' @param version A version tag (e.g. `"0.3.7"`) to install.  Defaults to GitHub
#'   development version (for now). Can also be set as an environment variable
#'   in `.Renviron`, E.g. `FLUXNET_SHUTTLE_VERSION=0.3.6`
#' @param from Where to install from? Currently only `"github"` is available,
#'   but eventually `"pypi"` will be an option to install from
#'   [PyPI](https://pypi.org).
#' @param reinitialize Logical; if `TRUE`, the virtual environment specified in
#'   `venv` will be removed and re-initialized.  Useful if you'd like to update
#'   the version of `fluxnet-shuttle`.
#' @examples
#' \dontrun{
#'
#' # Standard install of development version
#' flux_install_shuttle()
#'
#' # Specify a version
#' flux_install_shuttle(version = "0.3.5")
#'
#' # When run a second time, even after restarting the R session, it skips
#' # installation as long as the `venv` exists unless `reinitialize = TRUE`
#' flux_install_shuttle(version = "0.3.6")
#'
#' # If you want to update the version, set `reinitilaize = TRUE`
#' flux_install_shuttle(version = "0.3.6", reinitialize = TRUE)
#' }
#'
#' @returns The path to the `fluxnet-shuttle` CLI executable, silently.
#' @export
flux_install_shuttle <- function(
  venv = Sys.getenv("FLUXNET_VENV", unset = "fluxnet"),
  version = Sys.getenv("FLUXNET_SHUTTLE_VERSION", unset = "main"),
  from = c("github", "pypi"),
  reinitialize = FALSE
) {
  from <- match.arg(from)
  if (isTRUE(reinitialize) & reticulate::virtualenv_exists(venv)) {
    reticulate::virtualenv_remove(venv)
  }

  fmt_version <- if (version == "main") "development" else (version)
  fmt_from <- switch(from, github = "GitHub", pypi = "PyPI")

  # Print message only if virtualenv doesn't exist yet
  if (!reticulate::virtualenv_exists(venv)) {
    cli::cli_inform(c(
      i = 'Initializing virtualenv "{venv}".',
      i = 'Installing {.pkg fluxnet-shuttle} ({fmt_version}) from {fmt_from}. '
    ))
  }

  # TODO: eventually enable install with `pypi`

  if (from == "pypi") {
    cli::cli_warn(c(
      "Installing {.pkg fluxnet-shuttle} from PyPI is not yet available.",
      "Installing from GitHub."
    ))
    from <- "github"
  }

  if (from == "github") {
    if (version == "main") {
      pkg_string <- "git+https://github.com/fluxnet/shuttle.git"
    } else {
      pkg_string <- paste0(
        "git+https://github.com/fluxnet/shuttle.git@",
        version
      )
    }
  }

  reticulate::virtualenv_create(
    envname = venv,
    version = ">=3.11,<3.14", # Python version requirements for fluxnet-shuttle
    packages = pkg_string
  )
  env_path <- reticulate::virtualenv_python(venv)
  executable <- file.path(dirname(env_path), "fluxnet-shuttle")

  invisible(executable)
}