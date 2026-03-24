# fluxnet

`fluxnet` is an R package that provides utilities to download
[FLUXNET](https://fluxnet.org) data from member networks, read in those
data, perform basic quality control checks, and create exploratory
visualizations and data inventories.

## Installation

You can install the development version of fluxnet from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("EcosystemEcologyLab/fluxnet-package")
```

## Data Use Requirements

The FLUXNET data are shared under a CC-BY-4.0 data use license which
requires attribution for each data use. You can see the citations for
each site in the result of
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
and view the license document contained within each FLUXNET data product
(downloaded zip files).

Please also cite the `fluxnet` package:

## Typical usage

``` mermaid
flowchart TD
    A["`flux_listall()`"] -->|inspect available data| B["`flux_download()`"]
    B --> C["`flux_extract()`"]
    C --> D{"`manifest <- flux_discover_files()`"}
    D -->|Map sites| E["`flux_map_sites(manifest)`"]
    D -->|Read in data| F["`flux_read(manifest)`"]
    D -->|Read variable info| G["`flux_varinfo(manifest)`"]
    D -->|Read BADM| I["`flux_badm(manifest, 'LAI')`"]
    F --> |QA/QC| J["`flux_qc()`"]
```

## Updating/reinstalling fluxnet-shuttle

To force the `fluxnet` R package to re-install the `fluxnet-shuttle`
utility, remove the Pyhton virtualenv it is installed in with
`reticulate::virtualenv_remove("fluxnet")`. Then, the next time you run
[`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md),
the virtualenv will be re-created and `fluxnet-shuttle` will be
re-installed.
