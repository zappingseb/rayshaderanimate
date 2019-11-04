#' Calculate distance between all points
#' 
#' This function uses GPS data and \link{calc_distance} to calculate
#'   the distance between all points
#'   
#' @param gpx_table \code{data.frame} created by \link{get_table_from_gpx}
#' 
#' @return vector of distances in m
#' 
get_distance_from_gpx_table <- function(gpx_table){
  
  stopifnot("lon" %in% names(gpx_table))
  stopifnot("lat" %in% names(gpx_table))
  
  distance_vector <- c(0)
  for (i in 1:(nrow(gpx_table) - 1)) {
    distance_vector <- c(
      distance_vector,
      distance_vector[i] + calc_distance(points_from = data.frame(lng = gpx_table[i, "lon"], lat =gpx_table[i, "lat"]),
                    points_to = data.frame(lng = gpx_table[i+1, "lon"], lat =gpx_table[i+1, "lat"]))$nn.dists[1,1]
    )
  }
  
  return(distance_vector)
}