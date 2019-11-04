#' Enrich gpx data with time and speed
#' 
#' @param gpx_table (\code{data.frame}) table generated with \link{get_table_from_gpx}
#' @param every_x_value (\code{numeric}) Just take every xth value to make
#' 
#' @return the gpx data with true time and the relative speed between points
#' @export
#' @importFrom stringr str_replace
#' @importFrom magrittr %>%
get_enriched_gpx_table <- function(gpx_table, every_x_value = 5) {
  
  # GPX data filtering
  gpx_table_plot <- gpx_table[
    seq(from = 1, to = dim(gpx_table)[1], by = every_x_value)
    ,]
  
  gpx_table_plot$time <- gpx_table_plot$time %>%
    stringr::str_replace("T"," ") %>%
    stringr::str_replace("Z"," ")
  
  gpx_table_plot$time_right <- gpx_table_plot$time %>%
    as.POSIXct %>% as.numeric()
  
  # Calculate relative speed
  gpx_table_plot$rel_speed <- c(0,
                                # Calculate a distance by sqrt((long1 - long2) ^ 2 + (lat1 - lat2)^2) distance
                                apply(diff(as.matrix(gpx_table_plot[, c("lon", "lat")])), 1, function(x){
                                  sqrt(x[1] ^ 2 + x[2] ^ 2)
                                }) / 
                                  # Devide by time in seconds
                                  diff(as.matrix(gpx_table_plot$time_right)))
  gpx_table$distance <- get_distance_from_gpx_table(gpx_table)
  
  return(gpx_table_plot)
}