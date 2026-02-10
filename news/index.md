# Changelog

## fluxnet (development version)

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
