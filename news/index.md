# Changelog

## fluxnet (development version)

## fluxnet 0.2.1

- Eric Scott is now listed as package maintainer

## fluxnet 0.2.0

- Added
  [`flux_varinfo()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_varinfo.md)
  and
  [`flux_badm()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_badm.md)
  for reading and tidying “BIFVARINFO” and “BIF” files, respectively.
- [`flux_extract()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_extract.md)
  and
  [`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md)
  gain a `network` argument to specify a subset of networks (e.g. ICOS,
  TERN) to extract data from. Suggested by
  [@lbell3141](https://github.com/lbell3141).
- Added
  [`flux_qc()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_qc.md),
  a function to flag overly gapfilled rows of aggregated (not hourly)
  data.
- Added
  [`flux_map_sites()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_map_sites.md).
- [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  now uses `httr2` rather than `curl` for downloading files. This fixed
  a bug where downloads were failing when attempting to download large
  numbers of sites at once.
- Added
  [`flux_map_sites()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_map_sites.md)
- [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  prints a warning when downloads fail.
- Changed default cache age for
  [`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
  to 1 day.
- [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  now retries failed downloads once and `overwrite = FALSE` no longer
  skips downloading corrupted or partial downloads.
- Added
  [`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md)
  for reading in FLUXNET data in a manifest.
- Added
  [`flux_discover_files()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_discover_files.md)
  for creating a file manifest.

## fluxnet 0.1.0

- Added
  [`flux_extract()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_extract.md)
  for extracting data from downloaded .zip files.
- Added functions for downloading FLUXNET data
