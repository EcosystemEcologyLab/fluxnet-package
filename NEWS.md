# fluxnet 0.3.1

* `site_ids = "all"` is deprecated in favor of `site_ids = NULL` in all functions with this argument.

# fluxnet 0.3.0

* Adds a new function, `flux_install_shuttle()` which accepts the name of a virtualenv to use and a version of `fluxnet-shuttle` to install.  It pulls these from envvars, by default, making it easy to configure via a project-level .Renviron file.  It can be run as a separate step, but this is optional as it will be called automatically the first time `flux_listall()` or `flux_download()` are run.
* `flux_download()` no longer shows a progress bar as it downloads files.
* Optionally, you can provide a list containing your Ameriflux user name, email, and intended use to `flux_download()` via the new `user_info` argument and `flux_amf_credentials()` helper function.
* To get all available sites with `flux_download()`, use `site_ids = NULL`. `site_ids = "all"` is deprecated.
* `flux_download()` now uses the `fluxnet_shuttle` Python library rather than `httr2` to perform downloads.
* Fixed a bug in `flux_badm()` that would cause it to error when some "BIF" files contained additional optional columns ([#57](https://github.com/EcosystemEcologyLab/fluxnet-package/issues/57))
* The `use_cache` argument of `flux_listall()` has been removed.
* `flux_listall()` gained a `clean_cache` argument to set the number of recent snapshot CSVs to keep. Defaults to 10.

# fluxnet 0.2.1

* Eric Scott is now listed as package maintainer

# fluxnet 0.2.0

* Added `flux_varinfo()` and `flux_badm()` for reading and tidying "BIFVARINFO" and "BIF" files, respectively.
* `flux_extract()` and `flux_read()` gain a `network` argument to specify a subset of networks (e.g. ICOS, TERN) to extract data from.  Suggested by @lbell3141.
* Added `flux_qc()`, a function to flag overly gapfilled rows of aggregated (not hourly) data.
* Added `flux_map_sites()`.
* `flux_download()` now uses `httr2` rather than `curl` for downloading files.  This fixed a bug where downloads were failing when attempting to download large numbers of sites at once. 
* Added `flux_map_sites()`
* `flux_download()` prints a warning when downloads fail.
* Changed default cache age for `flux_listall()` to 1 day.
* `flux_download()` now retries failed downloads once and `overwrite = FALSE` no longer skips downloading corrupted or partial downloads.
* Added `flux_read()` for reading in FLUXNET data in a manifest.
* Added `flux_discover_files()` for creating a file manifest.

# fluxnet 0.1.0

* Added `flux_extract()` for extracting data from downloaded .zip files.
* Added functions for downloading FLUXNET data

