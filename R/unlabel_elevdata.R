#' Unlabel elevation data matrix for rayshader
#' 
#' @param elevdata data.frame created by \link{get_elevdata_from_bbox}
#' 
#' @export
#' @return The data.frame without labels in last column
unlabel_elevdata <- function(elevdata = NULL) {
  #unlabel for rayshader
  return(elevdata[1:(dim(elevdata)[1]-1), 1:(dim(elevdata)[2]-1)] %>%
    as.matrix())
}