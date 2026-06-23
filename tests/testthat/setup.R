# # Download example sites for tests if they aren't there already
# fs::dir_create(testthat::test_path("testdata"))
# zips <- fs::dir_ls(testthat::test_path("testdata")) %>% fs::path_file()
# flux_install_shuttle(venv = "fluxnet-package")
# if (
#   length(zips) == 0 |
#     !all(stringr::str_detect(
#       zips,
#       "(AMF_US-MMS_FLUXNET_)|(TERN_AU-Wom_FLUXNET_)"
#     ))
# ) {
#   flux_download(
#     site_ids = c("US-MMS", "AU-Wom"),
#     download_dir = testthat::test_path("testdata")
#   )
# }


# NOTE: I downloaded the files above, extracted the CSVs, manually deleted most
# of the data in each CSV to keep the file size < 1mb for each CSV, then
# re-zipped them to create some minimal test data.