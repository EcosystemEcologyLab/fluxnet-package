# Changelog

## fluxnet (development version)

## fluxnet 0.5.1

## fluxnet 0.5.0

- [`flux_qc()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_qc.md)
  now works with hourly data by supplying a `threshold` of 0, 1, 2, or
  3.
- The `max_gapfill` argument to
  [`flux_qc()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_qc.md)
  has been renamed to `threshold`
- The output of
  [`flux_read()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_read.md)
  now includes a `time_resolution` column. This may be especially useful
  for hourly (`"HR"`) and half-hourly (`"HH"`) frequency data, which are
  combined when `resolution = "h"`.

## fluxnet 0.4.0

- Added
  [`flux_citations()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_citations.md)
  to generate site-level citations either as plain text or BibTex
  entries.
- Fixed a bug where hourly data wasn’t being extracted or read in along
  with half-hourly data
  ([\#73](https://github.com/EcosystemEcologyLab/fluxnet-package/issues/73))

## fluxnet 0.3.2

- Fixes a bug introduced in 0.3.1 when more than one site id is provided
  to `site_ids`.

## fluxnet 0.3.1

- `site_ids = "all"` is deprecated in favor of `site_ids = NULL` in all
  functions with this argument.

## fluxnet 0.3.0

- Adds a new function,
  [`flux_install_shuttle()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_install_shuttle.md)
  which accepts the name of a virtualenv to use and a version of
  `fluxnet-shuttle` to install. It pulls these from envvars, by default,
  making it easy to configure via a project-level .Renviron file. It can
  be run as a separate step, but this is optional as it will be called
  automatically the first time
  [`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
  or
  [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  are run.
- [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  no longer shows a progress bar as it downloads files.
- Optionally, you can provide a list containing your Ameriflux user
  name, email, and intended use to
  [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  via the new `user_info` argument and
  [`flux_amf_credentials()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_amf_credentials.md)
  helper function.
- To get all available sites with
  [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md),
  use `site_ids = NULL`. `site_ids = "all"` is deprecated.
- [`flux_download()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_download.md)
  now uses the `fluxnet_shuttle` Python library rather than `httr2` to
  perform downloads.
- Fixed a bug in
  [`flux_badm()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_badm.md)
  that would cause it to error when some “BIF” files contained
  additional optional columns
  ([\#57](https://github.com/EcosystemEcologyLab/fluxnet-package/issues/57))
- The `use_cache` argument of
  [`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
  has been removed.
- [`flux_listall()`](https://ecosystemecologylab.github.io/fluxnet-package/reference/flux_listall.md)
  gained a `clean_cache` argument to set the number of recent snapshot
  CSVs to keep. Defaults to 10.

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
