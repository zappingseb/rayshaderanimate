#' Create a 3D video with an animated GPX route
#' 
#' @param gpx_table (\code{data.frame}) gpx table created by \link{get_enriched_gpx_table}
#' @param elevdata_long (\code{data.frame}) elevation data created by \link{get_elevdata_long}
#' @param number_of_screens (\code{numeric}) A guess of the number of screens/frames that
#'   shall be shown. An amount of images of the 3D map will be created that suits
#'   this. The more screens there are the more fluent the animation is. Each
#'   screen though takes about 20-30 seconds to render on a decent PC
#' @param make_gif (\code{logical}) Whether the screens shall be rendered out as a gif file. Just
#'   works for less than 24 screens
#' @param theta Rotation around z-axis.
#' @param zoom Zoom factor.
#' @param ffmpeg_path (\code{character}) to render more than 24 screens ffmpeg is needed to be in the path. Therefore
#'   please install it and provide the link to the path here. The ffmpeg already in path
#'   will not be overwritten
#' @param output_file_loc (\code{character}) Where to store the output mp4 file.
#' @param overwrite (\code{logical}) Whether to overwrite the output fie
#' @importFrom magick image_read image_write image_animate
#' @import rayshader
#' @import ggplot2
#' 
#' @export
video_animation <- function(gpx_table = NULL, elevdata_long = NULL, number_of_screens = 10, make_gif = TRUE,
                            theta = -10, zoom = 0.7, ffmpeg_path = "C:/Programme_2/ffmpeg/bin/", output_file_loc, overwrite = TRUE) {
  
  if (is.character(ffmpeg_path) && !grepl(pattern = "ffmpeg", Sys.getenv("PATH"))) {
    Sys.setenv("PATH" = paste0(Sys.getenv("PATH"), ";", ffmpeg_path))
  }
  
  if (number_of_screens > 24 && make_gif) {
    stop("gif can just be rendered for max 24 screens")
  }
  
  video_indeces <- get_video_indeces(time_data = gpx_table$time_right, number_of_screens = number_of_screens)
  
  if (number_of_screens > 50) {
    warning("theta and zoom parameters will be ignored")
    theta_angles <- rev(30 - 50 * 1/(1 + exp(seq(-5, 6, length.out = length(video_indeces)))))
    zoom_scale <- 0.5 + 0.5 * 1/(1 + exp(seq(-5, 5, length.out = length(video_indeces))))
  } else{
    theta_angles <- rep(theta, length(video_indeces))
    zoom_scale <- rep(zoom, length(video_indeces))
  }
  
  file.remove(list.files(tempdir(), pattern = "video", full.names = T))
  
  for (video_index in 1:length(video_indeces)) {
    
    if (video_index == 1) {
      message("First steps takes longer to to shadow calculation.")
    }
    
    vid_indx <- video_indeces[video_index]
    
    my_plot <- ggplot() +
      geom_tile(
        data = elevdata_long,
        aes(as.numeric(as.character(variable)), deg_elmat_lat, fill = value),
        alpha = 0.75) +
      scale_x_continuous(paste0("Longitude | ", gpx_table$time[vid_indx]), expand = c(0,0)) +
      scale_y_continuous("Latitude", expand = c(0,0)) +
      scale_fill_gradientn("Elevation", colours = terrain.colors(10)) +
      coord_fixed() +
      geom_path(
        data = gpx_table[1:vid_indx, ],
        aes(x = lon, y = lat, color = -rel_speed), shape = 15, size = 1, stroke = 0) +
      scale_color_viridis_c(option = "A") +
      guides(colour=FALSE)
    
    
    shadow_mat <- plot_gg(my_plot, shadow_intensity = 0.7, width = 5, height = 5, multicore = TRUE, scale = 350,
                          zoom = zoom_scale[video_index],
                          theta = theta_angles[video_index],
                          phi = 60, windowsize = c(800, 800), 
                          saved_shadow_matrix = if (video_index == 1) {
                            NULL
                          } else {
                            shadow_mat
                          },
                          save_shadow_matrix = TRUE, raytrace = TRUE)
    render_snapshot(filename = file.path(tempdir(), paste0("video", video_index, ".png")), clear = TRUE)
  }
  
  video_files <- list.files(tempdir(), pattern = "video", full.names = T)
  
  if (make_gif) {
    images <- magick::image_read(video_files)
    animation <- magick::image_animate(images, fps = 1)
    magick::image_write(animation, paste0(output_file_loc, ".gif"))
    return(paste0(output_file_loc, ".gif"))
  } else {
    
    # ------ make it a movie -------
    all_paths <- tempfile(fileext = ".txt")
    
    writeLines(con = all_paths,
               paste0("file '",tempdir(), "\\video", 1:length(video_indeces), ".png'")
    )
    
    outputfile <- tempfile(fileext = ".mp4")
    
    system(intern = TRUE,
           paste0("ffmpeg ",
                  ifelse(overwrite, "-y", "-n"),
                  " -f concat -r 24 -safe 0 -i \"",
                  all_paths,
                  "\" -vf \"fps=24,format=yuv420p\" ", outputfile))
    
    file.copy(from = outputfile, to = output_file_loc, overwrite = overwrite)
    return(output_file_loc)
  }
  
}
