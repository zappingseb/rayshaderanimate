#' Derive an overlay image from ArcGis
#' 
#' @importFrom png readPNG
#' @importFrom magick image_write image_flop image_flip
#' @export
#' 
#' @param bbox_arcgis \code{list} created with \code{get_bbox_from_gpx_table(..., arcgis = TRUE)}
#' 
#' @return An image rendered with \code{png::readPNG} which was downloaded from ArcGis mapserver
#' 
#' 
get_image_overlay <- function(bbox_arcgis) {
  image_size <- define_image_size(bbox_arcgis, major_dim = 600)
  overlay_file <- tempfile(fileext = ".png")
  get_arcgis_map_image(bbox_arcgis, map_type = "World_Topo_Map", file = overlay_file,
                       width = image_size$width, height = image_size$height, 
                       sr_bbox = 4326)
  overlay_file_rot <- tempfile(fileext = ".png")
  magick::image_write(magick::image_flop(magick::image_flip(magick::image_read(path = overlay_file))), overlay_file_rot)
  return(png::readPNG(overlay_file_rot))
}