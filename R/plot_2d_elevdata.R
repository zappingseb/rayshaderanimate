#' Plot a 2D raster of the bbox
#' 
#' @param elevdata_rayshade (\code{matrix}) with elevation data but unlabeled
#'  by \code{unlabel_elevdata}
#' @param overlay_img (\code{character}) Link to an image to put on-top
#'   of the map. Best created with \link{get_arcgis_map_image}
#' @import rayshader
#' @importFrom raster raster extend extract
#' @importFrom magrittr %>%
#' @importFrom png readPNG
#' @export
plot_2d_elevdata <- function(elevdata_rayshade, overlay_img = NULL) {
  
  my_raster <- raster::raster(elevdata_rayshade)
  my_raster_extended <- raster::extend(my_raster, 1)
  matrix_extended <- matrix(raster::extract(my_raster_extended, raster::extent(my_raster_extended), buffer = 1000),
                            nrow = ncol(my_raster_extended), ncol = nrow(my_raster_extended))
  
  zscale <- 50
  raymat <- ray_shade(matrix_extended, zscale = zscale, lambert = TRUE)
  ambmat <- ambient_shade(matrix_extended, zscale = zscale)
  watermap <- detect_water(matrix_extended)
  map_to_plot <- matrix_extended %>%
    sphere_shade(texture = "imhof4") %>%
    add_shadow(raymat, max_darken = 0.5) %>%
    add_shadow(ambmat, max_darken = 0.5)
  
  if (!is.null(overlay_img)) {
    map_to_plot <- map_to_plot %>% add_overlay(png::readPNG(overlay_img), alphalayer = 0.5)
  }
  plot_map(map_to_plot)
}