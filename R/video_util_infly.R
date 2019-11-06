#' Function to move along the rayshader image at first
#' 
#' @importFrom magick image_append image_read image_write
#' @import rayshader
#' 
#' @param theta \code{numeric} Theta angle will move from first value to first value minus second value
#' @param phi \code{numeric} phi angle will move from first value to first value minus second value
#' @param zoom \code{numeric} zoom angle will move from second value to first value
#' 
#' @param title \code{character} Title of the infly video
#' @param width \code{numeric} width of the inflight video
#' @param height \code{numeric} height of the inflight video title
#' @param duration \code{numeric} duration in seconds
#' 
#' @export
#' 
#' @return \code{character} vector with the absolute paths of the screen images created for the infly
#' 
video_util_infly <- function(theta = c(280, 250),
                             zoom = c(0.6, 1.5),
                             phi = c(58, 33),
                             title = "Random Bike Ride", width = 1200, height = 200,
                             duration = 4
                             ) {
  
  stopifnot(length(theta) == 2)
  stopifnot(length(zoom) == 2)
  stopifnot(length(phi) == 2)
  
  file_names_infly <- file.path(tempdir(), paste0("video_infly_", 1:(duration * 24), ".png"))
  vapply(file_names_infly, file.remove, logical(1))
  theta_angles <- rev(theta[1] - theta[2] * 1/(1 + exp(seq(-3, 3, length.out = length(file_names_infly)))))
  zoom_scale <- zoom[1] + zoom[2] * 1/(1 + exp(seq(-5, 5, length.out = length(file_names_infly))))
  phi_angles <- rev(phi[1] - phi[2] * 1/(1 + exp(seq(-3, 3, length.out = length(file_names_infly)))))
  
  for (i in 1:length(file_names_infly)) {
    render_camera(theta = theta_angles[i], zoom = zoom_scale[i], phi = phi_angles[i])
    render_snapshot(filename = file_names_infly[i])
  }
  
  infly_heading_file <- video_util_title(heading = title, width = width, height = height)
  
  png_empty <- video_util_empty_screen(width = width, height = width / 4)
  
  output_files <- file.path(tempdir(), paste0("video_infly_combined_", 1:length(file_names_infly), ".png"))
  vapply(output_files, file.remove, logical(1))
  
  message("Adding Title to infly rendering")
  for (i in 1:length(file_names_infly)) {
    message(paste0(i, "/", length(file_names_infly)),"\r",appendLF=FALSE)
    flush.console()
    magick::image_write(
      image = magick::image_append(
        c(magick::image_read(infly_heading_file),
          magick::image_read(file_names_infly[i]),
          magick::image_read(png_empty)
        ),
        stack = TRUE
      ),
      path = output_files[i]
    )
  }
  
  return(c(rep(output_files[1], 24),
           output_files[2:(length(output_files)-1)],
           rep(output_files[length(output_files)], 24)))
}