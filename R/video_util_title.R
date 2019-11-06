#' @importFrom grDevices png dev.off
#' @importFrom graphics text
video_util_title <- function(heading, width = 1200, height = 200) {
  infly_heading_file <- tempfile(fileext = ".png")
  
  png(filename = infly_heading_file, width = width, height = height)
  
  plot(c(0, width), c(0, height), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
  
  
  text(x = width/2, y = height/2, paste(heading), 
       cex = 3, col = "#0f9ad1")
  
  dev.off()
  
  return(infly_heading_file)
}