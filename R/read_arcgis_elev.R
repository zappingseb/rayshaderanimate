getImg <- function(txt) {
  raw <- jsonlite::base64_dec(txt)
  if (all(as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a))==raw[1:8])) { # it's a png...
    img <- png::readPNG(raw)
    transparent <- img[,,4] == 0
    img <- as.raster(img[,,1:3])
    img[transparent] <- NA
  } else stop("No Image!")
  return(img[, 1])
}
#' @importFrom grDevices as.raster col2rgb rgb
#' @importFrom graphics image
#' @import sp
eudem_image_create <- function(bbox_arcgis, plot2d = TRUE, plot3d = FALSE) {
  legend <- jsonlite::read_json(
    "https://image.discomap.eea.europa.eu/arcgis/rest/services/Elevation/EUElev_DEM_V11/MapServer/legend?f=pjson"
  )
  
  legend_values <- unlist(lapply(1:3, function(i)
    getImg(legend$layers[[1]]$legend[[i]]$imageData)
  ))
  legend_values <- legend_values[-43]
  
  legend_matrix <- t(matrix(
    col2rgb(legend_values[1])
  ))
  for (i in 1:length(legend_values)){
    if (i+1 < length(legend_values)){
      
      legend_matrix <- rbind(
        legend_matrix,
        t(col2rgb(legend_values[i])),
        grDevices::colorRamp(c(legend_values[i], legend_values[i+1]))(seq(1/25, 1, by=1/25)),
        t(col2rgb(legend_values[i+1]))
      )
    }
  }
  legend_matrix <- legend_matrix[!duplicated(legend_matrix), ]
  
  # plotting legend matrix
  ddf <- legend_matrix
  image(1:nrow(ddf), 1, as.matrix(1:nrow(ddf)),
        col=rgb(ddf[, "red"]/255, ddf[ ,"green"]/255, ddf[,"blue"]/255),
        xlab="", ylab = "", xaxt = "n", yaxt = "n", bty = "n")
  
  legend_max <- as.numeric(stringr::str_match(pattern = "\\-{0,1}\\d{1,4}\\.\\d{1,2}", string = legend$layers[[1]]$legend[[1]]$label))
  legend_min <- as.numeric(stringr::str_match(pattern = "\\-{0,1}\\d{1,4}\\.\\d{1,2}", string = legend$layers[[1]]$legend[[3]]$label))
  
  legend_elevation <- seq(legend_max, legend_min, by = - (legend_max - legend_min) / (nrow(legend_matrix)-1))
  
  img_elev <- get_arcgis_map_image(type = "elev", bbox = bbox_arcgis, width = 522, height = 800)
  image_elev <- png::readPNG(img_elev)
  
  rgb_image <- image_elev[1, 1, c(1:3)]
  
  elevation_matrix <- matrix(NA, nrow = dim(image_elev)[1], ncol = dim(image_elev)[2])
  
  # calculating shortest distance to legend for each pixel
  for (i in 1:dim(image_elev)[1]) {
    for (j in 1:dim(image_elev)[2]){
      
      rgb_image <- image_elev[i, j, c(1:3)] * 255
      d = sqrt(((rgb_image[1]-legend_matrix[, "red"]))^2 + ((rgb_image[2]-legend_matrix[, "green"]))^2 + ((rgb_image[3]-legend_matrix[, "blue"]))^2)
      
      elevation_matrix[i, j] <- legend_elevation[which(min(d) == d)]
    }
  }
  
  if (plot2d) {
    
    # Plotting the matrix as 2d
    elevation_matrix %>%
      sphere_shade(texture = "desert") %>%
      plot_map()
    
  }
  
  if (plot3d) {
    
    # Plotting the matrix as 3d
    elevation_matrix %>%
      sphere_shade(texture = "desert") %>%
      add_water(detect_water(elevation_matrix), color = "desert") %>%
      add_shadow(ray_shade(elevation_matrix, zscale = 3, maxsearch = 300), 0.5) %>%
      plot_3d(elevation_matrix, zscale = 10, fov = 0, theta = 135, zoom = 0.75, phi = 45, windowsize = c(1000, 800))
    
  }
  
}

