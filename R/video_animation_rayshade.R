#' Create a Rayshader animation of a GPX table
#' 
#' @param gpx_table \code{data.frame} gpx table created by get_enriched_gpx_table
#' @param elevdata \code{data.frame} elevation data reveiced by \link{get_elevdata_from_bbox}
#' @param bbox_arcgis \code{list} Boundary Box to derive boundaries of an area derived by
#'  \code{get_bbox_from_gpx_table(..., arcgis = TRUE)}, OR an \code{array} of overlay image
#'  downloaded by the function \code{get_image_overlay()}. 
#'  If NULL (default) no overlay is added to the video.
#' @param image_overlay_alpha \code{numeric} Defines transparency of image layer in function
#'  \code{rayshader::add_overlay()}. Only relevant if code{bbox_arcgis != NULL}. Defaults to 0.9.
#' @param number_of_screens \code{numeric} Number of frames the animation should have
#' @param zscale \code{numeric} The ratio between the x and y spacing and the z axis. 
#' For more details see rayshader package. 
#' @param title \code{character} The introductory title shown in an infly video
#' @param add_elevation_plot \code{logical} Option to add an elevation graph to the bottom of the vid.
#' @param flyin \code{list} parameters of \link{video_util_infly}
#' @param places \code{data.frame} containing some places where large labels should be
#'   added during the video. needs to have the columns \code{lon, lat, label, title}
#' @param  output_file_loc \code{character} Where to store the output mp4 file.
#' @param width \code{numeric} Width of the screen to render
#' @param height \code{numeric} height of the 3d window
#' 
#' @param overwrite \code{logical} Whether the final video file can be overwritten
#' 
#' @export
#' 
#' @import rayshader
#' @importFrom magrittr %>%
video_animation_rayshade <- function(gpx_table,
                                     elevdata,
                                     bbox_arcgis = NULL,
                                     image_overlay_alpha = .9,
                                     number_of_screens = 500,
                                     zscale = 15,
                                     title = NULL,
                                     add_elevation_plot = FALSE,
                                     places = NULL,
                                     output_file_loc = tempfile(fileext = ".mp4"),
                                     width = 1200,
                                     height = 800,
                                     flyin = list(
                                       theta = c(280, 250),
                                       zoom = c(0.6, 1.5),
                                       phi = c(58, 33),
                                       duration = 4
                                     ),
                                     overwrite = TRUE
                                     ) {
  
  stopifnot(grepl("ffmpeg",Sys.getenv("PATH")))
  
  video_indeces <- get_video_indeces(time_data = gpx_table$time_right, number_of_screens = number_of_screens)
  
  elevation_data_list <- get_elevdata_list(elevdata)
  
  gpx_tab_filtered <- get_gpx_table_animate(gpx_table,
                                            video_indeces = video_indeces,
                                            lon_labels = elevation_data_list$lon,
                                            lat_labels = elevation_data_list$lat)
  
  
  if (!is.null(places) && number_of_screens > 50) {
    
    gpx_tab_filtered <- get_gpx_table_with_places(gpx_tab_filtered, places)
    
  }
  elevation_matrix <- elevation_data_list$elevation_matrix
  # Plotting the matrix as 3d
  elev_elem <- elevation_matrix %>%
    sphere_shade(texture = "desert") %>%
    add_water(detect_water(elevation_matrix), color = "desert") %>%
    add_shadow(ray_shade(elevation_matrix, zscale = zscale, maxsearch = 300), 0.5)
  
  if (!is.null(bbox_arcgis)) {
    if (class(bbox_arcgis) == "list") {
      message("Downloading overlay image")
      overlay_img <- get_image_overlay(bbox_arcgis)
      }
    if (class(bbox_arcgis) == "list") {
      overlay_img <- bbox_arcgis
    }
      elev_elem <- elev_elem %>% add_overlay(overlay_img, alphalayer = image_overlay_alpha)
  }
  
  elev_elem %>%
    plot_3d(elevation_matrix, zscale = zscale, fov = 1, theta = 280, zoom = 1.5, phi = 60, windowsize = c(width, height))

  # animate an infly that moves from outside to the 3d graphic
  message("Rendering Intro flight")
  file_names_infly <- video_util_infly(theta = flyin$theta, zoom = flyin$zoom, phi = flyin$phi, 
                                       title = title, add_elevation_plot = add_elevation_plot,
                                       width = width, height = height/4,
                                       duration = flyin$duration
                                       )
  
  message("Rendering 3d route")
  file_names_3d <- video_util_3d_animation(gpx_table = gpx_tab_filtered, 
                                           elevation_matrix = elevation_matrix,
                                           zscale = zscale)
  
  if(add_elevation_plot) {
    message("Rendering 2d elevation profiles")
    file_names_gg <- video_util_ggplot_elevation(gpx_table = gpx_tab_filtered, dpi = width/8)
  } else {
    file_names_gg <- NULL
  }

  if(add_elevation_plot | !is.null(title)) {
    message("Merging 3d and 2d images")
    video_images <- video_util_3d_and_gg(
      gpx_table = gpx_tab_filtered,
      file_names_3d = file_names_3d,
      file_names_gg = file_names_gg,
      width = width,
      height = height/4,
      frames_of_place = 60,
      title = title
    )
  } else {
    video_images <- file_names_3d
  }

  
  # ------ make it a movie -------
  all_paths <- tempfile(fileext = ".txt")
  
  writeLines(con = all_paths,
             paste0("file '", c(
               gsub("\\\\","/", file_names_infly),
               video_images
             ),"'")
             
  )
  
  outputfile <- tempfile(fileext = ".mp4")
  
  message("Rendering Video")
  system(intern = TRUE,
         paste0("ffmpeg ",
                ifelse(overwrite, "-y", "-n"),
                " -f concat -r 24 -safe 0 -i \"",
                all_paths,
                "\" -vf \"fps=24,format=yuv420p\" ", outputfile))
  cat(outputfile)
  file.copy(from = outputfile, to = output_file_loc, overwrite = overwrite)
  return(output_file_loc)
}
