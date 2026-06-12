# Output required per-dataset citations for FLUXNET data

Given a vector of site IDs, this either returns a dataframe with or
BibTeX citations for each site.

## Usage

``` r
flux_citations(
  site_ids,
  output = c("data.frame", "bibtex"),
  bibtex_path = NULL,
  ...
)
```

## Arguments

- site_ids:

  Character vector of site IDs, e.g. `c("AR-Bal", "DE-Gwg")`.

- output:

  Either `"data.frame"` to return a tibble or `"bibtex"` to return (or
  write) BibTeX entries. See '**Value**' for more details.

- bibtex_path:

  Path to a .bib file to write BibTeX to, passed to the `con` argument
  of [`writeLines()`](https://rdrr.io/r/base/writeLines.html). If `NULL`
  (default), BibTeX will be returned as character. Has no effect if
  `output = 'data.frame'`.

- ...:

  Additional arguments passed to
  [`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md).

## Value

If `output = 'data.frame'`, a `tibble` is returned with a `bibentry`
list-column with elements of class
[bibentry](https://rdrr.io/r/utils/bibentry.html) and a `citation`
column with citations formatted in the default style (see the
[`format()`](https://rdrr.io/r/base/format.html) method for
[`bibentry()`](https://rdrr.io/r/utils/bibentry.html) for more details).
If `output = 'bibtex'`, BibTeX entries are either returned as an atomic
character vector (if `bibtex_path` is `NULL`) or written to a file.

## Examples

``` r
# Return dataframe with bibentries and formatted citations
flux_citations(c("AR-Bal", "DE-Gwg"))
#> ℹ Initializing virtualenv "fluxnet".
#> ℹ Installing fluxnet-shuttle (development) from GitHub.
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
#> # A tibble: 2 × 5
#>   site_id site_name   product_id               bibentry   citation              
#>   <chr>   <chr>       <chr>                    <list>     <chr>                 
#> 1 AR-Bal  Balcarce BA 10.17190/AMF/2571144     <bibentry> "Gassmann MI, Tonti N…
#> 2 DE-Gwg  Graswang    GPtUsX3eLBhx-c2kGtz1zjZ- <bibentry> "Schmid, H., Sellmaie…

# Return BibTeX
flux_citations(c("AR-Bal", "DE-Gwg"), output = "bibtex")
#> @Misc{gassmann_2026,
#>   author = {Maria Isabel Gassmann and Natalia Edith Tonti},
#>   title = {AmeriFlux FLUXNET-1F AR-Bal Balcarce BA},
#>   year = {2026},
#>   publisher = {AmeriFlux AMP},
#>   doi = {10.17190/AMF/2571144},
#>   url = {https://doi.org/10.17190/AMF/2571144},
#>   type = {dataset},
#> }
#> @Misc{schmid_2026,
#>   author = {{Schmid} and {H.} and {Sellmaier} and {S.} and {Völksch} and {I.}},
#>   title = {Fluxnet Archive Product from Graswang, 2023–2024},
#>   year = {2026},
#>   publisher = {Ecosystem Thematic Centre},
#>   pid = {GPtUsX3eLBhx-c2kGtz1zjZ-},
#>   url = {https://hdl.handle.net/11676/GPtUsX3eLBhx-c2kGtz1zjZ-},
#>   type = {dataset},
#> }

# Append BibTeX entries to a file
if (FALSE) { # \dontrun{
flux_citations(
  c("AR-Bal", "DE-Gwg"),
  output = "bibtex",
  bibtex_path = "references.bib"
)
} # }
```
