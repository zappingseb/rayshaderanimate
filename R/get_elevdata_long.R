#' Derive a long format of elevation data for ggplot
#' 
#' @param elevdata (\code{data.frame}) Elevation data build by \link{get_elevdata_from_bbox}
#' 
#' @export
#' @importFrom reshape2 melt
get_elevdata_long <- function(elevdata) {
  
  elmat_filtered_long <- reshape2::melt(elevdata, id.vars=c("deg_elmat_lat"))
  
  elmat_filtered_long$variable <- as.numeric(as.character(elmat_filtered_long$variable))
  elmat_filtered_long$deg_elmat_lat <- as.numeric(as.character(elmat_filtered_long$deg_elmat_lat))
  elmat_filtered_long <- elmat_filtered_long[
    which(elmat_filtered_long$deg_elmat_lat != min(elmat_filtered_long$variable)),
    ]
  elmat_filtered_long <- elmat_filtered_long[
    which(elmat_filtered_long$deg_elmat_lat != max(elmat_filtered_long$variable)),
    ]
  return(elmat_filtered_long)
}