
# fluxnet

<!-- badges: start -->
<!-- badges: end -->

The goal of fluxnet is to ...

## Installation

You can install the development version of fluxnet from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("EcosystemEcologyLab/fluxnet-package")
```

To use the `fluxnet` R package to download data, you'll also need to install the `fluxnet-shuttle` command-line utility, found at https://github.com/fluxnet/shuttle. 

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(fluxnet)
## List all available FLUXNET data
flux_listall()

## Download all available FLUXNET data
flux_download()
```

