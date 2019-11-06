#' Add places information to GPX table
#' 
#' @param gpx_table \code{data.frame} created by get_table_from_gpx
#' @param places \code{data.frame} with columns \code{lat, lon, label, title} that can
#'   be used to add some information to the pure GPX file
#'   
#' 
get_gpx_table_with_places <- function(gpx_table, places){
  
  if (!("label" %in% names(gpx_table))) {
    gpx_table$label <- rep(NA, nrow(gpx_table))
  }
  if (!("title" %in% names(gpx_table))) {
    gpx_table$title <- rep(NA, nrow(gpx_table))
  }
  
  stopifnot("lat" %in% names(places))
  stopifnot("lon" %in% names(places))
  stopifnot("label" %in% names(places))
  stopifnot("title" %in% names(places))
  
  for (row_index in 1:nrow(places)) {
    
    index <- which.min(sqrt((gpx_table$lat - places$lat[row_index]) ^ 2 + (gpx_table$lon - places$lon[row_index]) ^ 2))
    
    gpx_table$label[index] <- as.character(places$label[row_index])
    gpx_table$title[index] <- as.character(places$title[row_index])
  }
  
  return(gpx_table)
}