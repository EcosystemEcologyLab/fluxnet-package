# Create a "manifest" of downloaded and unzipped FLUXNET data files

Create a "manifest" of downloaded and unzipped FLUXNET data files

## Usage

``` r
flux_discover_files(data_dir = "fluxnet/unzipped")
```

## Arguments

- data_dir:

  The directory to look for FLUXNET CSV files in, typically the same as
  the `output_dir` used for
  [`flux_extract()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_extract.md).

## Value

Prints a summary of discovered available data and returns (invisibly) a
dataframe with file paths and metadata extracted from file names.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download data
flux_download(site_ids = c("AU-Boy", "BR-CST"))

# Extract annual and monthly data
flux_extract(resolutions = c("y", "m"))

# Create a manifest of extracted files
manifest <- flux_discover_files()
} # }
```
