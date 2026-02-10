# fluxnet

``` r
library(fluxnet)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## Discovering what is available for download

[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
is an R wrapper around a command line program,
[`fluxnet-shuttle`](https://github.com/fluxnet/shuttle), which requires
Python. The first time you run
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md),
a Python virtual environment will be created and `fluxnet-shuttle` will
be installed into it. If you don’t have an appropriate version of Python
installed, you may be prompted with tips on how to install it.

``` r
list <- flux_listall()
```

    #> Using Python: /usr/bin/python3.12
    #> Creating virtual environment 'fluxnet' ...
    #> + /usr/bin/python3.12 -m venv /home/runner/.virtualenvs/fluxnet
    #> Done!
    #> Installing packages: pip, wheel, setuptools
    #> + /home/runner/.virtualenvs/fluxnet/bin/python -m pip install --upgrade pip wheel setuptools
    #> Installing packages: 'git+https://github.com/fluxnet/shuttle.git'
    #> + /home/runner/.virtualenvs/fluxnet/bin/python -m pip install --upgrade --no-user 'git+https://github.com/fluxnet/shuttle.git'
    #> Virtual environment 'fluxnet' successfully created.
    #> File list is expired, downloading the latest version

By default, the results of
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
are saved in a user cache, so when you run it again it’ll pull the
results from there unless they are older than `cach_age`. To ignore the
cache, use `use_cache = FALSE`. To *invalidate* the cache (and replace
it with an updated one), use `cache_age = -Inf`.

``` r
# Don't use cached results:
list <- flux_listall(use_cache = FALSE)

# Invalidate and replace cached results:
list <- flux_listall(cache_age = -Inf)
```

The list returned by
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
contains metadata on the available sites including, importantly,
citations for site-level data attribution which is required by FLUXNET.

``` r
colnames(list)
#>  [1] "data_hub"               "site_id"                "site_name"             
#>  [4] "location_lat"           "location_long"          "igbp"                  
#>  [7] "network"                "team_member_name"       "team_member_role"      
#> [10] "team_member_email"      "first_year"             "last_year"             
#> [13] "download_link"          "fluxnet_product_name"   "product_citation"      
#> [16] "product_id"             "oneflux_code_version"   "product_source_network"
list[,c("site_id", "product_citation")]
#> # A tibble: 224 × 2
#>    site_id product_citation                                                     
#>    <chr>   <chr>                                                                
#>  1 AR-CCg  Gabriela Posse (2025), AmeriFlux FLUXNET-1F AR-CCg Carlos Casares gr…
#>  2 AR-TF1  Lars Kutzbach (2025), AmeriFlux FLUXNET-1F AR-TF1 Rio Moat bog, Ver.…
#>  3 AR-TF2  Lars Kutzbach (2025), AmeriFlux FLUXNET-1F AR-TF2 Rio Pipo bog, Ver.…
#>  4 BR-CST  Antonio Antonino (2025), AmeriFlux FLUXNET-1F BR-CST Caatinga Serra …
#>  5 CA-ARB  Aaron Todd, Elyn Humphreys (2025), AmeriFlux FLUXNET-1F CA-ARB Attaw…
#>  6 CA-Ca1  T. Andrew Black (2025), AmeriFlux FLUXNET-1F CA-Ca1 British Columbia…
#>  7 CA-Ca2  T. Andrew Black (2025), AmeriFlux FLUXNET-1F CA-Ca2 British Columbia…
#>  8 CA-DB2  Sara Knox (2025), AmeriFlux FLUXNET-1F CA-DB2 Delta Burns Bog 2, Ver…
#>  9 CA-DBB  Andreas Christen, Sara Knox (2025), AmeriFlux FLUXNET-1F CA-DBB Delt…
#> 10 CA-DSM  Sara Knox (2025), AmeriFlux FLUXNET-1F CA-DSM Delta Salt Marsh, Ver.…
#> # ℹ 214 more rows
```

## Downloading data

There are a few paths to downloading FLUXNET data. If you just want to
download everything available, simply run
[`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md).
You can download just specific sites with the `site_ids` argument, or
you can filter the results of
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
and pass those in.

``` r
# Download everything available.
flux_download()

# Download just certain sites
flux_download(site_ids = c("AR-CCg", "AR-TF1", "BR-CST"))

# Filter list and download
list_wet <- list[list$igbp == "WET",]
flux_download(file_list_df = list_wet)
```

## Extracting data from .zip files

[`flux_extract()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_extract.md)
allows you to unzip only desired files from all or some of the
downloaded site .zip files.

``` r
# Extract everything (not recommended!)
flux_extract()

# Extract just annual and monthly data
flux_extract(resolutions = c("y", "m"))

# Extract hourly data for just certain sites
flux_extract(site_ids = c("AR-CCg", "AR-TF1"), resolutions = "h")

# Don't extract BIF and BIFVARINFO CSVs
flux_extract(extract_varinfo = FALSE)
```

## Discovering what data you have extracted

[`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md)
is used to create a “manifest” of the data available to read in. You
*must* create this manifest (and optionally filter it) to pass into
[`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md).

``` r
manifest <- flux_discover_files()
```

## Reading in data

You can read in data by passing a manifest to
[`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md).
You can read in data for just select sites with the `site_ids` argument,
but for more complex filtering you can simply subset the manifest object
first.

``` r
# Read all available annual data
annual <- flux_read(manifest, resolution = "y")

# Read in hourly data from specific sites
hourly <- flux_read(
  manifest,
  resolution = "h",
  site_ids = c("AR-CCg", "AR-TF1")
)

# Read in only ERA5 data
annual_era5 <- flux_read(manifest, resolution = "y", datasets = "ERA5")

# Filter manifest to just sites with "WET" for IGBP
n_wet_manifest <- 
  left_join(manifest, list, by = join_by(site_id)) %>%
  filter(igbp == "WET", location_lat > 0)

n_wet_monthly <- flux_read(n_wet_manifest, resolution = "m")
```
