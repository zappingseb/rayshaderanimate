#' Derive an overlay image from ArcGis
#' 
#' @importFrom png readPNG
#' @importFrom magick image_write image_flop image_flip
#' @export
#' 
#' @param bbox_arcgis \code{list} created with \code{get_bbox_from_gpx_table(..., arcgis = TRUE)}
#' @param output_file_loc \code{character} Path and name of the downloaded image file.
#' @param flipflop \code{logical} If image should be transposed. Default = TRUE. 
#' Due to the transposing of elevation data at the Greenich line image needs to be transposed
#' to suit rayshader package
#' @param major_dim major image dimension, in pixels.
#' Default is 400 (meaning larger dimension will be 400 pixels)
#' 
#' @return An image rendered with \code{png::readPNG} which was downloaded from ArcGis mapserver
#' 
#' 
get_image_overlay <- function(bbox_arcgis,
                              output_file_loc = tempfile(fileext = ".png"),
                              flipflop = TRUE,
                              major_dim = 400
                              ) {
  image_size <- define_image_size(bbox_arcgis, major_dim = major_dim)
  get_arcgis_map_image(bbox_arcgis, map_type = "World_Topo_Map", 
                       file = output_file_loc,
                       width = image_size$width, 
                       height = image_size$height, 
                       sr_bbox = 4326)
  if (flipflop) {
    magick::image_write(magick::image_flop(magick::image_flip(magick::image_read(path = output_file_loc))), output_file_loc)
  }
  message(paste0( (if(flipflop) "transposed "), "image saved to file: ", output_file_loc))
  return(png::readPNG(output_file_loc))
}