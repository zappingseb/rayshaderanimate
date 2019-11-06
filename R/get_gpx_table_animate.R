#' @importFrom viridisLite viridis
#' @importFrom scales colour_ramp
get_gpx_table_animate <- function(gpx_table = NULL, video_indeces = c(),
                      lon_labels = c(),
                      lat_labels = c()
) {
  gpx_tab_filtered <- gpx_table[video_indeces, ]
  
  gpx_tab_filtered$lon_idx <- vapply(gpx_tab_filtered$lon, function(x) which.min(abs(x - lon_labels)), numeric(1))
  gpx_tab_filtered$lat_idx <- vapply(gpx_tab_filtered$lat, function(x) which.min(abs(x - lat_labels)), numeric(1))
  
  gpx_tab_filtered$rel_speed_col <- scales::colour_ramp(viridisLite::viridis(10, option = "A",
                                                                             begin = 1, end = 0))(-gpx_tab_filtered$rel_speed /
                                                                                                    -max(gpx_tab_filtered$rel_speed))
  gpx_tab_filtered$label <- rep(NA, nrow(gpx_tab_filtered))
  gpx_tab_filtered$title <- rep(NA, nrow(gpx_tab_filtered))
  
  return(gpx_tab_filtered)
}