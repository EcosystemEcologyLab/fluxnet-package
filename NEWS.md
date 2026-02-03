# fluxnet (development version)

* `flux_download()` now retries failed downloads once and `overwrite = FALSE` no longer skips downloading corrupted or partial downloads.
* Added `flux_read()` for reading in FLUXNET data in a manifest.
* Added `flux_discover_files()` for creating a file manifest.

# fluxnet 0.1.0

* Added `flux_extract()` for extracting data from downloaded .zip files.
* Added functions for downloading FLUXNET data

