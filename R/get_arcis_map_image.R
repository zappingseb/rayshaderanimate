#' Download a map image from the ArcGIS REST API
#'
#' @param bbox bounding box coordinates (list of 2 points with long/lat values)
#' @param map_type map type to download - options are World_Street_Map, World_Imagery, World_Topo_Map
#' @param file file path to save to. Default is NULL, which will create a temp file.
#' @param width image width (pixels)
#' @param height image height (pixels)
#' @param sr_bbox Spatial Reference code for bounding box
#' @param type MapServer will get a map, else elevation data gets downloaded
#'  
#' @details This function uses the ArcGIS REST API, specifically the
#' "Execute Web Map Task" task. You can find links below to a web UI for this
#' rest endpoint and API documentation.
#'
#' Web UI: https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute
#' API docs: https://developers.arcgis.com/rest/services-reference/export-web-map-task.htm
#'
#' @return file path for the downloaded .png map image
#' @export
#' @examples
#' bbox <- list(
#'   p1 = list(long = -122.522, lat = 37.707),
#'   p2 = list(long = -122.354, lat = 37.84)
#' )
#' overlay_file <- get_arcgis_map_image(bbox)
#' @import httr 
#' @importFrom glue glue
#' @importFrom jsonlite unbox toJSON
get_arcgis_map_image <- function(bbox, map_type = "World_Street_Map", file = NULL,
    width = NULL, height = NULL, sr_bbox = 4326, type = "MapServer") {

  url <- parse_url("https://utility.arcgisonline.com/arcgis/rest/services/Utilities/PrintingTools/GPServer/Export%20Web%20Map%20Task/execute")

  if(is.null(height) || is.null(width)) {
    hw <- define_image_size(bbox = bbox)
    height <- hw$height
    width <- hw$width
  }

  # define JSON query parameter
  web_map_param <- list(
      baseMap = list(
          baseMapLayers = list(
              list(url =
                      if (type == "MapServer") {
                        jsonlite::unbox(glue::glue("https://services.arcgisonline.com/ArcGIS/rest/services/{map_type}/MapServer",
                                map_type = map_type))
                      }else{
                        jsonlite::unbox("https://image.discomap.eea.europa.eu/arcgis/rest/services/Elevation/EUElev_DEM_V11/MapServer")
                      }
              )
          )
      ),
      exportOptions = list(
          outputSize = c(width, height)
      ),
      mapOptions = list(
          extent = list(
              spatialReference = list(wkid = jsonlite::unbox(sr_bbox)),
              xmax = jsonlite::unbox(max(bbox$p1$long, bbox$p2$long)),
              xmin = jsonlite::unbox(min(bbox$p1$long, bbox$p2$long)),
              ymax = jsonlite::unbox(max(bbox$p1$lat, bbox$p2$lat)),
              ymin = jsonlite::unbox(min(bbox$p1$lat, bbox$p2$lat))
          )
      )
  )

  res <- GET(
      url,
      query = list(
          f = "json",
          Format = "PNG32",
          Layout_Template = "MAP_ONLY",
          Web_Map_as_JSON = jsonlite::toJSON(web_map_param))
  )

  if (status_code(res) == 200) {
    body <- content(res, type = "application/json")
    message(jsonlite::toJSON(body, auto_unbox = TRUE, pretty = TRUE))
    if (is.null(file))
      file <- tempfile("overlay_img", fileext = ".png")

    img_res <- GET(body$results[[1]]$value$url)
    img_bin <- content(img_res, "raw")
    writeBin(img_bin, file)
    message(paste("image saved to file:", file))
  } else {
    message(res)
  }
  return(file)
}
