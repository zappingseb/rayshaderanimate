#' Generate a table from GPX file
#' 
#' @param gpx_file_loc (\code{character}) location of the gpx file
#' @return A table with the gpx coordinates, elevation and time data
#' 
#' @importFrom plotKML readGPX
#' @export
#' 
get_table_from_gpx <- function(gpx_file_loc) {
  my_gpx <- plotKML::readGPX(gpx_file_loc)
  return(my_gpx$tracks[[1]][[1]])
}