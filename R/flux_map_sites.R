#' Map sites with downloaded data
#'
#' Plot locations of sites in a file manifest on a world map.
#'
#' @param manifest A data manifest created by [flux_discover_files()].
#' @param color_var A variable to use to color-code points.
#' @returns A ggplot2 object
#' @examples
#' \dontrun{
#' manifest <- flux_discover_files()
#' flux_map_sites(manifest)
#' }
#'
#' @export
flux_map_sites <- function(
  manifest,
  color_var = c("data_hub", "igbp", "network", "first_year", "last_year")
) {
  color_var <- match.arg(color_var)
  # get just one row per site
  manifest_summary <- manifest %>%
    dplyr::group_by(.data$site_id) %>%
    dplyr::summarize(
      first_year = min(.data$first_year, na.rm = TRUE),
      last_year = max(.data$last_year, na.rm = TRUE),
      location_lat = unique(.data$location_lat),
      location_long = unique(.data$location_long),
      igbp = unique(.data$igbp),
      network = unique(.data$network),
      data_hub = unique(.data$data_hub)
    )

  p_world <- ggplot2::ggplot() +
    ggplot2::geom_polygon(
      data = ggplot2::map_data("world"),
      ggplot2::aes(x = long, y = lat, group = group),
      fill = "white",
      color = "grey50"
    ) +
    ggplot2::coord_quickmap()

  p_world +
    ggplot2::geom_point(
      data = manifest_summary,
      ggplot2::aes(
        x = location_long,
        y = location_lat,
        color = .data[[color_var]]
      )
    ) +
    ggplot2::labs(x = "", y = "")
}
