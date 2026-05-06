flux_arrange_hive <- function(manifest, hive_root = "fluxnet/unzipped/") {
  is_hive <- manifest$path %>%
    fs::path_dir() %>%
    stringr::str_detect("resolution=.+/dataset=.+/data_hub=.+/site_id=.+") %>%
    all()
  if (!is_hive) {
    copy <- manifest %>%
      dplyr::mutate(
        file = fs::path_file(path),
        new_path = fs::path(
          hive_root,
          glue::glue("time_resolution={time_resolution}"),
          glue::glue("dataset={dataset}"),
          glue::glue("data_hub={data_hub}"),
          glue::glue("site_id={site_id}"),
          file
        )
      ) %>%
      select(path, new_path)

    fs::dir_create(fs::path_dir(copy$new_path))
    fs::file_move(path = copy$path, new_path = copy$new_path)

    # Delete origniating folders only if they are now empty
    dirs <- fs::path_dir(copy$path) %>% unique()
    dirs <- dirs[fs::dir_exists(dirs)]

    empty_dirs <- dirs[purrr::map_lgl(dirs, fs::is_dir_empty)]
    fs::dir_delete(empty_dirs)
  } else {
    cli::cli_inform(c(`!` = "Data already appears to be hive-partitioned"))
  }
}
