video_animation_rayshade <- function(gpx_table, elevdata, number_of_screens = 500, theta = c(360, 340),
                                     output_file_loc = tempfile(fileext = ".mp4"), places = NULL) {
  
  video_indeces <- get_video_indeces(time_data = gpx_table$time_right, number_of_screens = number_of_screens)
  elev_data_old <- elevdata
  browser()
  elevdata <- elevdata[c((nrow(elevdata) - 1):1, nrow(elevdata)), c((ncol(elevdata) - 1):1, ncol(elevdata))]
  elevdata[nrow(elevdata), ] <- elevdata[nrow(elevdata), c((ncol(elevdata) - 1):1,ncol(elevdata)) ]
  elevdata[, ncol(elevdata)] <- elevdata[c((nrow(elevdata)-1):1,nrow(elevdata)) , ncol(elevdata)]
  
  colnames(elevdata) <- colnames(elevdata)[c((ncol(elevdata) - 1):1, ncol(elevdata))]
  
  lon_elevdata <- as.numeric(colnames(elevdata)[(ncol(elevdata) - 1):1])
  lat_elevdata <- as.numeric(elevdata$deg_elmat_lat[1:(nrow(elevdata) -1)])

  gpx_tab_filtered <- gpx_table[video_indeces, ]
  
  gpx_tab_filtered$lon_idx <- vapply(gpx_tab_filtered$lon, function(x) which.min(abs(x - lon_elevdata)), numeric(1))
  gpx_tab_filtered$lat_idx <- vapply(gpx_tab_filtered$lat, function(x) which.min(abs(x - lat_elevdata)), numeric(1))
 
  elevation_matrix <- elevdata %>% unlabel_elevdata() %>% t
  
  gpx_tab_filtered$rel_speed_col <- scales::colour_ramp(viridisLite::viridis(10, option = "A", begin = 1, end = 0))(-gpx_tab_filtered$rel_speed / -max(gpx_tab_filtered$rel_speed))
  
  gpx_tab_filtered$label <- rep(NA, nrow(gpx_tab_filtered))
  
  place_indeces <- c()
  
  if (!is.null(places) && number_of_screens > 50) {
    
    for (row_index in 1:nrow(places)) {
      
      place_indeces <- c(place_indeces, which.min(
        
         sqrt((gpx_tab_filtered$lat - places$lat[row_index]) ^ 2 + (gpx_tab_filtered$lon - places$lon[row_index]) ^ 2))
      )
      
      gpx_tab_filtered$label[place_indeces[length(place_indeces)]] <- as.character(places$label[row_index])
    }
    
  }
  
  image_size <- define_image_size(bbox_arcgis, major_dim = 600)
  overlay_file <- tempfile(fileext = ".png")
  get_arcgis_map_image(bbox_arcgis, map_type = "World_Topo_Map", file = overlay_file,
                       width = image_size$width, height = image_size$height, 
                       sr_bbox = 4326)
  overlay_file_rot <- tempfile(fileext = ".png")
  magick::image_write(magick::image_flop(magick::image_flip(image_read(path = overlay_file))), overlay_file_rot)
  overlay_img <- png::readPNG(overlay_file_rot)
  
  # Plotting the matrix as 3d
  elevation_matrix %>%
    sphere_shade(texture = "desert") %>%
    add_water(detect_water(elevation_matrix), color = "desert") %>%
    add_shadow(ray_shade(elevation_matrix, zscale = 3, maxsearch = 300), 0.5) %>%
    add_overlay(overlay_img, alphalayer = 0.5) %>%
    plot_3d(elevation_matrix, zscale = 15, fov = 1, theta = 135, zoom = 0.75, phi = 45, windowsize = c(1000, 800))
  
  theta_angles <- rev(theta[1] - theta[2] * 1/(1 + exp(seq(-3, 3, length.out = length(video_indeces)))))
  
  for (i in 1:nrow(gpx_tab_filtered)) {
    
    render_label(elevation_matrix, x = gpx_tab_filtered[i, "lon_idx"], y = gpx_tab_filtered[i, "lat_idx"], z = 100, 
                 zscale = 15, text = NULL, textsize = 15, linewidth = 6, freetype = FALSE, color = gpx_tab_filtered[i, "rel_speed_col"]) 
    render_camera(theta = theta_angles[i])
    
    if (!is.na(gpx_tab_filtered[i, "label"])) {
      render_label(elevation_matrix, x = gpx_tab_filtered[i, "lon_idx"], y = gpx_tab_filtered[i, "lat_idx"], z = 600, 
                   zscale = 15, text = gpx_tab_filtered[i, "label"],
                   textsize = 15, linewidth = 5, freetype = FALSE, color = "black") 
      
    }
    
    render_snapshot(filename = file.path(tempdir(), paste0("video_rayshade_two", i, ".png")), clear = FALSE)
    
    if ("distance" %in% names(gpx_table)) {
      gp_before <- ggplot(data = gpx_table, mapping = aes(x = as.numeric(distance)/1000,
                                                          y = as.numeric(ele))) +
        geom_area(fill = "#cccccc") +
        geom_area(
          mapping = aes(x = ifelse(distance < gpx_tab_filtered[i, "distance"],
                                   distance/1000, -1)), fill = "#a5e2ec") +
        theme_bw() + xlim(0, max(gpx_table$distance)/1000) + xlab("Distance [km]")
    } else {
      
      gp_before <- ggplot(data = gpx_table, mapping = aes(x = as.numeric(time_right),
                                                   y = as.numeric(ele))) +
        geom_area(fill = "#cccccc") +
        geom_area(
          mapping = aes(x = ifelse(as.numeric(time_right) < as.numeric(gpx_tab_filtered[i, "time_right"]),
                                   as.numeric(time_right), 0)), fill = "#a5e2ec") +
        theme_bw() + xlim(min(gpx_table$time_right), max(gpx_table$time_right)) +
        theme(axis.text.x = element_blank, axis.title.x = element_blank())
    }
    
    gp <- gp_before +
      theme(axis.line.x = element_blank(), axis.line.y = element_blank(),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.ticks = element_blank(), panel.border = element_blank()
      ) + ylab("Elevation [m]") +
      coord_cartesian(ylim = c(min(as.numeric(gpx_table$ele)), max(as.numeric(gpx_table$ele))))
    
    ggsave(file.path(tempdir(), paste0("video_rayshade_two_elevation", i, ".png")), plot = gp, width = 8, height = 2, dpi = 125)
  }
  
  for (i in 1:length(video_indeces)) {
    magick::image_write(
      image = magick::image_append(
        c(magick::image_read(file.path(tempdir(), paste0("video_rayshade_two", i, ".png"))),
          magick::image_read(file.path(tempdir(), paste0("video_rayshade_two_elevation", i, ".png")))
        ),
        stack = TRUE
      ),
      path = file.path(tempdir(), paste0("video_rayshade_two_combined", i, ".png"))
    )
  }
  
  # ------ make it a movie -------
  all_paths <- tempfile(fileext = ".txt")
  
  writeLines(con = all_paths,
             paste0("file '",tempdir(), "\\video_rayshade_two_combined", c(1:length(video_indeces), rep(length(video_indeces), 48)), ".png'")
             
  )
  
  outputfile <- tempfile(fileext = ".mp4")
  
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