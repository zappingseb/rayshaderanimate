#' Elevation matrix around Alpe d Huez
#'
#' data frame containing the elevation data for a sector around
#' Alpe d Huez with 250 m2 accuracy. Longitudinal degrees are
#' stored in the last column, latitutes are stored as column names.
#'
#' @format A data frame with 125 rows and 190 variables:
#' @source \url{https://srtm.csi.cgiar.org/srtmdata/}
"el_mat"

#' Elevation matrix around Alpe d Huez from EUDEM
#'
#' data frame containing the elevation data for a sector around
#' Alpe d Huez with 30 m2 accuracy. Longitudinal degrees are
#' stored in the last column, latitutes are stored as column names.
#' Data derived from EUDEM project.
#'
#' @format A data frame with 432 rows and 521 variables:
#' @source  \url{https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1/view}
"el_mat_eudem"

#' Elevation matrix around Schliersee
#'
#' data frame containing the elevation data for a sector around
#' Schliersee and Tegernsee in Germany with 30m2 accuracy. Longitudinal degrees are
#' stored in the last column, latitutes are stored as column names and in the last row.
#'
#' @format A data frame with 921 rows and 561 variables:
#' @source \url{https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1/view}
"elevation_data_Schliersee"

#' Places labeled around Schliersee
#'
#' data frame containing the places that should be labeled
#' during a video rendering around the Schliersee Tour. The
#' data contains longitude und latitude. Moreover each
#' place has a title and a label.
#' 
#' @format A data frame with 5 rows and 4 variables:
"places_Schliersee"

#' Places labeled around Alpe d Huez
#'
#' data frame containing the places that should be labeled
#' during a video rendering around the Schliersee Tour. The
#' data contains longitude und latitude. Moreover each
#' place has a title and a label.
#' 
#' @format A data frame with 4 rows and 4 variables:
"places_alpe_de_huez"