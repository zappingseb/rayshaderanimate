#' @import rayshader
video_util_3d_animation <- function(gpx_table = NULL, elevation_matrix = NULL) {
  
  outputfiles <- file.path(tempdir(), paste0("gpx_animation", 1:nrow(gpx_table), ".png"))
  vapply(outputfiles, file.remove, logical(1))
  
  for (i in 1:nrow(gpx_table)) {
    message(paste0(i, "/", nrow(gpx_table)),"\r",appendLF=FALSE)
    flush.console()
    render_label(elevation_matrix, x = gpx_table[i, "lon_idx"], y = gpx_table[i, "lat_idx"], z = 100, 
                 zscale = 15, text = NULL, textsize = 15, linewidth = 6, freetype = FALSE, linecolor = "#0f9ad1"
    ) 
    
    if (!is.na(gpx_table[i, "label"])) {
      render_label(elevation_matrix, x = gpx_table[i, "lon_idx"], y = gpx_table[i, "lat_idx"], z = 2200, 
                   zscale = 15, text = gpx_table[i, "label"],
                   textsize = 1, linewidth = 7, freetype = FALSE, linecolor = "#0f9ad1", family = "mono", antialias = TRUE)
      
    }
    
    render_snapshot(filename = outputfiles[i], clear = FALSE)
  }
  
  return(outputfiles)
}