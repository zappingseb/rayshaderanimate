#' @importFrom magick image_write image_append image_read
video_util_3d_and_gg <- function(gpx_table, file_names_3d, file_names_gg = NULL, width, 
                                 height, frames_of_place = 60, title = NULL) {
  
  video_images_output <- file.path(tempdir(), paste0("video_rayshade_two_combined", 1:nrow(gpx_table), ".png"))
  vapply(video_images_output, file.remove, logical(1))
  
  for (i in 1:nrow(gpx_table)) {
    message(paste0(i, "/", nrow(gpx_table)),"\r",appendLF=FALSE)
    flush.console()
    
    if (!is.null(title)) {
      if (is.na(gpx_table[i, "label"])){
        title_image <- video_util_empty_screen(width = width, height = height)
      } else {
        title_image <- video_util_title(heading = gpx_table[i, "title"], width = width, height = height)
      }
    }
    image <- magick::image_read(c(
      if (!is.null(title)) {title_image},
      file_names_3d[i],
      if (!is.null(file_names_gg)) {file_names_gg[i]}
    ))
    magick::image_write(
      image = magick::image_append(image = image, stack = TRUE),
      path = video_images_output[i]
    )
  }
  
  img_ids <- c()
  for (i in 1:nrow(gpx_table)){
    if (is.na(gpx_table[i, "label"])){
      img_ids <- c(img_ids, i)
    } else {
      img_ids <- c(img_ids, rep(i, frames_of_place))
    }
  }
  img_ids <- c(img_ids, rep(nrow(gpx_table), 72))
  
  return(gsub("\\\\","/", video_images_output[img_ids]))
}