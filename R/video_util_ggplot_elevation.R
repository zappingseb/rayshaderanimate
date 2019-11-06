#' @import ggplot2
video_util_ggplot_elevation <- function(gpx_table, dpi) {
  
  distance <- NULL
  ele <- NULL
  time_right <- NULL
  x <- NULL
  y <- NULL
  
  outputfiles <- file.path(tempdir(), paste0("gpx_ggplot", 1:nrow(gpx_table), ".png"))
  vapply(outputfiles, file.remove, logical(1))
  
  for (i in 1:nrow(gpx_table)) {
    message(paste0(i, "/", nrow(gpx_table)),"\r",appendLF=FALSE)
    flush.console()
    # Add a GGPLOT of the elevation profile 
    if ("distance" %in% names(gpx_table)) {
      gp_before <- ggplot(data = gpx_table, mapping = aes(x = as.numeric(distance)/1000,
                                                          y = as.numeric(ele))) +
        # Gray area
        geom_area(fill = "#cccccc") +
        # Darkened area behind the blue line
        geom_area(
          mapping = aes(x = ifelse(distance < gpx_table[i, "distance"],
                                   distance / 1000, -1)), fill = "#a5e2ec") +
        # Dark blue line infront of x
        geom_area(data = data.frame(
          x = c(gpx_table[i, "distance"]/1000 - 0.2, gpx_table[i, "distance"]/1000 + 0.2),
          y = rep(max(as.numeric(gpx_table$ele)) + 50, 2)),
          mapping = aes(x=x, y=y), fill = "#0f9ad1") +
        theme_bw() + xlim(0, max(gpx_table$distance)/1000) + xlab("Distance [km]")
    } else {
      
      gp_before <- ggplot(data = gpx_table, mapping = aes(x = as.numeric(time_right),
                                                          y = as.numeric(ele))) +
        geom_area(fill = "#cccccc") +
        geom_area(
          mapping = aes(x = ifelse(as.numeric(time_right) < as.numeric(gpx_table[i, "time_right"]),
                                   as.numeric(time_right), 0)), fill = "#a5e2ec") +
        theme_bw() + 
        xlim(min(gpx_table$time_right), max(gpx_table$time_right)) +
        theme(axis.text.x = element_blank(), axis.title.x = element_blank())
    }
    
    gp <- gp_before +
      theme(axis.line.x = element_blank(), axis.line.y = element_blank(),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.ticks = element_blank(), panel.border = element_blank()
      ) + 
      ylab("Elevation [m]") +
      coord_cartesian(ylim = c(min(as.numeric(gpx_table$ele)), max(as.numeric(gpx_table$ele))))
    
    ggsave(outputfiles[i], plot = gp, width = 8, height = 2, dpi = dpi)
  }
  return(outputfiles)
}