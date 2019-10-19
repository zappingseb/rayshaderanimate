get_video_indeces <- function(time_data = c(), number_of_screens = 8) {
  stopifnot(length(time_data) > 20)
  time_distance <- max(time_data) - min(time_data)
  avg_time_step <- time_distance/length(time_data)
  
  index_from <- 1
  index_to <- 2 
  all_indeces <- c(index_from)
  
  while(index_to < length(time_data) && index_to > index_from) {
    while(
      
      if(index_to >= length(time_data)){
        FALSE
      } else {
        (time_data[index_to] - time_data[index_from]) < time_distance/number_of_screens
      }
    ) {
      index_to <- index_to + 1
    }
    all_indeces <- c(all_indeces, index_to)
    index_from <- index_to
    index_to <- index_to + 1
  }
  return(all_indeces)
}