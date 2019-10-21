#' Get bbox format from gpx file table
#' 
#' @param gpx_table data.frame generated with \link{get_table_from_gpx}
#' @param arcgis (\code{logical}) Whether a format to download
#'   data from arcgis by \link{get_arcgis_map_image} shall be provided
#'   
#' @return list of coordinates box
#' @export
get_bbox_from_gpx_table <- function(gpx_table, arcgis = FALSE) {
  
  bbox_gpx <- cbind(
    c(min(gpx_table$lon)-0.015, min(gpx_table$lat)-0.015),
    c(max(gpx_table$lon)+0.015, max(gpx_table$lat)+0.015)
  )
  
  colnames(bbox_gpx) <- c("min", "max")
  rownames(bbox_gpx) <- c("x", "y")
  
  if (arcgis){
    
    return(list(
      p1 = list(long = bbox_gpx[1,1], lat = bbox_gpx[2,1]),
      p2 = list(long = bbox_gpx[1,2], lat = bbox_gpx[2,2])
    ))
  } else {
    return(bbox_gpx)
  }
  
}