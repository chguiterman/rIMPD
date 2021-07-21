#' Search the IMPD
#'
#' This function provides a means for fast and efficient searches of the North
#' American tree-ring fire scar datasets housed on the International Multiproxy
#' Paleofire Database (IMPD)
#'
#' @inheritParams ncei_paleo_api
#'
#' @return A data frame of search results from the North American IMPD
#'
#' @importFrom magrittr %>%
#'
#' @export
#' @examples
#' # Find Tom Swetnam's fire-history sites
#' search_impd(investigators = "Swetnam")
#'
#' # Find all sites with Gambel oak
#' search_impd(species = "QUGA")

search_impd <- function(investigators = NULL,
                        minLat = NULL,
                        maxLat = NULL,
                        minLon = NULL,
                        maxLon = NULL,
                        minElev = NULL,
                        maxElev = NULL,
                        earliestYear = NULL,
                        latestYear = NULL,
                        species = NULL) {
  ncei_paleo_api(investigators = investigators,
                 minLat = minLat,
                 maxLat = maxLat,
                 minLon = minLon,
                 maxLon = maxLon,
                 minElev = minElev,
                 maxElev = maxElev,
                 earliestYear = earliestYear,
                 latestYear = latestYear,
                 species = species) %>%
    build_impd_meta()
}
