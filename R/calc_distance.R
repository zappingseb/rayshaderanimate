#' Calculate the distance between two places in m
#' 
#' @param points_from \code{data.frame} A data frame with a 'lng' at 'lat' column
#'  containing a list of points from where the distance shall be calculated
#' @param points_to \code{data.frame} A data frame with a 'lng' at 'lat' column
#'  with just a single point that the distance shall be calculated to
#' @importFrom RANN nn2
#' @importFrom sp proj4string coordinates spTransform CRS
#' @details 
#' 
#' Can be found at https://stackoverflow.com/questions/39454249/checking-whether-coordinates-fall-within-a-given-radius?noredirect=1&lq=1
#' 
#' @return A table of the distances inside the 'nn.dists' column of the table for each point of the \code{points_from} input
#' 
#' @export
#' @author Sebastian Wolf \email{sebastian@@mail-wolf.de} 
calc_distance <- function(
  points_from = data.frame(lng=c(),lat=c()),
  points_to = data.frame(lng=c(),lat=c())
){
  if(!"lng" %in% names(points_to)){
    stop("longitude needed in 'points_to' as lng")
  }
  if(!"lat" %in% names(points_to)){
    stop("latitude needed in 'points_to' as lat")
  }
  
  if(!"lng" %in% names(points_from)){
    stop("longitude needed in 'points_from' as lng")
  }
  if(!"lat" %in% names(points_from)){
    stop("latitude needed in 'points_from' as lat")
  }
  
  ## First define a function from Josh OBrien's answer to convert
  ## a longitude to its UTM zone
  long2UTM <- function(long) {
    (floor((long + 180)/6) %% 60) + 1
  }
  
  ## Assuming that all points are within a zone (within 6 degrees in longitude),
  ## we use the first shop's longitude to get the zone.
  z <- long2UTM(points_from[ceiling(dim(points_from)[1]/2),"lng"])
  
  ## convert the bus lat/long coordinates to UTM for the computed zone
  ## using the other Josh O'Brien linked answer
  bus2 <- points_from[,c("lng","lat")]
  names(bus2) <- c("lng","lat")
  
  sp::coordinates(bus2) <- c("lng", "lat")
  sp::proj4string(bus2) <- sp::CRS("+proj=longlat +datum=WGS84")
  bus.xy <- sp::spTransform(bus2, sp::CRS(paste0("+proj=utm +zone=",z," ellps=WGS84")))
  
  # Create a Pointsmap
  points_to <- points_to[,c("lng","lat")]
  sp::coordinates(points_to) <- c("lng", "lat")
  sp::proj4string(points_to) <- sp::CRS("+proj=longlat +datum=WGS84")
  city.xy <- sp::spTransform(points_to, sp::CRS(paste0("+proj=utm +zone=",z," ellps=WGS84")))
  
  ## Compile the distance between Berlin and all Segments
  res <- RANN::nn2(city.xy@coords, bus.xy@coords,1)
  return(res)
}