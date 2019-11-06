#' @importFrom grDevices png dev.off
video_util_empty_screen <- function(width, height){
  infly_heading_file <- tempfile(fileext = ".png")
  
  png(filename = infly_heading_file, width = width, height = height)
  
  plot(c(0, width), c(0, height), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
  
  dev.off()
  
  return(infly_heading_file)
}