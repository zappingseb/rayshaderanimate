#' Animate GPX line on 2d plot
#' 
#' @param gpx_table (\code{data.frame}) gpx table created by \link{get_enriched_gpx_table}
#' @param elevdata_long (\code{data.frame}) elevation data created by \link{get_elevdata_long}
#' 
#' @return A gganimate animated plot where the gpx data gets animated on top of an elevation map
#' @export
#' @import ggplot2
#' @importFrom gganimate transition_reveal
#' @importFrom grDevices terrain.colors
#' @importFrom rlang .data
plot_2d_animation <- function(gpx_table, elevdata_long) {
  elevdata_long$variable <- as.numeric(as.character(elevdata_long$variable))
  # ------ animate line -> 2D ---------
  ggplot() +
    geom_tile(
      data = elevdata_long,
      aes_string("variable", "deg_elmat_lat", fill = "value"),
      alpha = 0.45) +
    scale_x_continuous("X",expand = c(0,0)) +
    scale_y_continuous("Y",expand = c(0,0)) +
    scale_fill_gradientn("Z",colours = terrain.colors(10)) +
    coord_fixed() +
    geom_point(
      data = gpx_table,
      aes_string(x = "lon", y = "lat", color = "-rel_speed"), shape = 15, size = 1, stroke = 0) +
    geom_path(
      data = gpx_table,
      aes_string(x = "lon", y = "lat", color = "-rel_speed"), shape = 15, size = 1, stroke = 0) +
    gganimate::transition_reveal(.data$time_right) +
    scale_color_viridis_c(option = "A") +
    guides(colour=FALSE)
  
}