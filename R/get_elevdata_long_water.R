
get_elevdata_long_water <- function(elevdata) {
  dtc <- detect_water(elevdata %>% unlabel_elevdata)
  elmat_df <- as.data.frame(dtc)
  elmat_df <- cbind(elmat_df, elevdata[1:(nrow(elevdata) -1), ncol(elevdata)]) %>% as.data.frame
  colnames(elmat_df) <- c(colnames(elevdata)[(ncol(elevdata) - 1):1], "deg_elmat_lat")
  elmat_df <- rbind(elmat_df, elevdata[nrow(elevdata), c((ncol(elevdata) -1):1, ncol(elevdata))]) %>% as.data.frame
  
  
  water_data <- get_elevdata_long(elmat_df)
  real_data <- get_elevdata_long(elevdata)
  real_data$value[which(water_data$value == 1)] <- min(real_data$value)
  
  browser()
  my_plot <- ggplot() +
    geom_tile(
      data = real_data,
      aes_string("as.numeric(as.character(variable))","deg_elmat_lat",  fill = "value"),
      alpha = 0.75) +
    scale_y_continuous("Latitude", expand = c(0,0)) +
    scale_fill_gradientn("Elevation", colours = terrain.colors(10)) +
    # annotate(geom = 'tile', x =   water_data$variable, y =    water_data$deg_elmat_lat, 
             # fill = (c("#FFFFFF00", "#63C600FF"))(water_data$value)) +
    coord_fixed()
  plot_gg(my_plot, shadow_intensity = 0.7, width = 5, height = 5, multicore = TRUE, scale = 350,
          zoom = 0.5,
          theta = 30,
          phi = 60, windowsize = c(800, 800), 
          raytrace = TRUE, saved_shadow_matrix = shadow_mat)
  return(get_elevdata_long(elmat_df))
}