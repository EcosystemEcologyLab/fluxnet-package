
# fluxnet

<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/EcosystemEcologyLab/fluxnet-package/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EcosystemEcologyLab/fluxnet-package/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`fluxnet` is an R package that provides utilities to download [FLUXNET](https://fluxnet.org) data from member networks, read in those data, perform basic quality control checks, and create exploratory visualizations and data inventories.

## Installation

You can install the development version of fluxnet from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("EcosystemEcologyLab/fluxnet-package")
```

## Data Use Requirements

The FLUXNET data are shared under a CC-BY-4.0 data use license which requires attribution for each data use. You can see the citations for each site in the result of `flux_listall()` and view the license document contained within each FLUXNET data product (downloaded zip files).

To use the `fluxnet` R package to download data, you'll also need to install the `fluxnet-shuttle` command-line utility, found at https://github.com/fluxnet/shuttle. 

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(fluxnet)
## List all available FLUXNET data
flux_listall()

## Download all available FLUXNET data
flux_download()

## Extract all the annual data files from the downloads
flux_extract(resolutions = "y")

## Create manifest
manifest <- flux_discover_files()

## Read in data
annual <- flux_read(manifest, resolution = "y")
```

## Updating/reinstalling fluxnet-shuttle

To force the `fluxnet` R package to re-install the `fluxnet-shuttle` utility, remove the Pyhton virtualenv it is installed in with `reticulate::virtualenv_remove("fluxnet")`.
Then, the next time you run `flux_listall()`, the virtualenv will be re-created and `fluxnet-shuttle` will be re-installed.