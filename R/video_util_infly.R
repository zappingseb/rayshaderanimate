video_util_infly <- function(theta = c(280, 250), zoom = c(0.6, 1.5), title = "Random Bike Ride") {
  
  # INFLY
  file_names_infly <- file.path(tempdir(), paste0("video_infly_", 1:(3 * 24), ".png"))
  vapply(file_names_infly, file.remove, logical(1))
  theta_angles <- rev(theta[1] - theta[2] * 1/(1 + exp(seq(-3, 3, length.out = length(file_names_infly)))))
  zoom_scale <- zoom[1] + zoom[2] * 1/(1 + exp(seq(-5, 5, length.out = length(file_names_infly))))
  
  for (i in 1:length(file_names_infly)) {
    
    render_camera(theta = theta_angles[i], zoom = zoom_scale[i])
    render_snapshot(filename = file_names_infly[i])
    
  }
  
  infly_heading_file <- video_util_title(title = title, width = 1200, height = 200)
  
  png_empty <- video_util_empty_screen(width = 1200, height = 250)
  
  output_files <- file.path(tempdir(), paste0("video_infly_combined_", 1:length(file_names_infly), ".png"))
  vapply(output_files, file.remove, logical(1))
  for (i in 1:length(file_names_infly)) {
    
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