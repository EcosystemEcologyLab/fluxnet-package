# Install the fluxnet-shuttle CLI

Uses `reticulate` to install the
[fluxnet-shuttle](https://fluxnet.github.io/shuttle/) Python library and
command line interface into a virtual environment. Required for
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
and
[`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md).

## Usage

``` r
flux_install_shuttle(
  venv = Sys.getenv("FLUXNET_VENV", unset = "fluxnet"),
  shuttle_version = Sys.getenv("FLUXNET_SHUTTLE_VERSION", unset = "main"),
  from = c("github", "pypi"),
  reinitialize = FALSE
)
```

## Arguments

- venv:

  A name to use for creating a virtual environment. Defaults to
  `"fluxnet"`, but we recommend using a project-specific virtual
  environment. You can set this in a project-level `.Renviron` file as
  `FLUXNET_VENV=myproject` and it will be pulled from there.

- shuttle_version:

  A version tag (e.g. `"0.3.7"`) to install. Defaults to GitHub
  development version (for now). Can also be set as an environment
  variable in `.Renviron`, E.g. `FLUXNET_SHUTTLE_VERSION=0.3.6`

- from:

  Where to install from? Currently only `"github"` is available, but
  eventually `"pypi"` will be an option to install from
  [PyPI](https://pypi.org).

- reinitialize:

  Logical; if `TRUE`, the virtual environment specified in `venv` will
  be removed and re-initialized. Useful if you'd like to update the
  version of `fluxnet-shuttle`.

## Value

The path to the `fluxnet-shuttle` CLI executable, silently.

## Note

This will be run automatically the first time you run
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
or
[`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md),
so it is not necessary to run this function separately first. Big thanks
to Andrew Heiss for helping me figure this all out!

## Examples

``` r
if (FALSE) { # \dontrun{

# Standard install of development version
flux_install_shuttle()

# Specify a version
flux_install_shuttle(shuttle_version = "0.3.5")

# When run a second time, even after restarting the R session, it skips
# installation as long as the `venv` exists unless `reinitialize = TRUE`
flux_install_shuttle(shuttle_version = "0.3.6")

# If you want to update the version, set `reinitilaize = TRUE`
flux_install_shuttle(shuttle_version = "0.3.6", reinitialize = TRUE)
} # }
```
