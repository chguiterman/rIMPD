#' Search the IMPD
#'
#' This function provides a means for fast and efficient searches of the North
#' American tree-ring fire scar datasets housed on the International Multiproxy
#' Paleofire Database (IMPD)
#'
#' @inheritParams ncei_paleo_api
#'
#' @return A data frame of search results from the North American IMPD,
#'   including: \itemize{
#'   \item{"siteName" -- name of the site}
#'   \item{"studyCode" -- unique site identifier as defined by the IMPD}
#'   \item{"investigators" -- list of investigators for the study site}
#'   \item{"first_year" -- earliest year of the tree-ring data}
#'   \item{"last_year" -- latest year of the tree-ring data}
#'   \item{"latitude" and "longitude"  -- site coordinates}
#'   \item{"elevation" -- site elevation in meters above sea level}
#'   \item{"species" -- tree species codes}
#'   \item{"reference" -- literature citation for site data}
#'   \item{"doi" -- Digital Object Identifier for the site data}
#'   \item{"contr_year" -- the year the site data were contriuted to the IMPD}
#'   \item{"NOAAStudyId" -- unique study identifier used by NOAA}
#'   \item{"NOAASiteId" -- unique site identifier used by NOAA}
#'   \item{"url" -- site landing page on the NCEI server}
#'   }
#'
#'
#' @note If you search the IMPD a lot, you might find inconsistent results. For
#'   one, the IMPD is constantly being updated with new sites and thus growing.
#'   But sometimes not all sites will appear in a search that had been showing
#'   up previously. This is not a issue in `rIMPD`, rather it has to do with the
#'   NCEI API being accessed by `rIMPD`. Should you have trouble with the
#'   search, or notice data errors in the results, then email "paleo at
#'   noaa.gov". The WDS-Paleo team has been very helpful in building this
#'   package and are always working to improve the API and paleo resources.
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
#'
#' # Retrieve sites from Oregon and Washington states
#' or_wa <- rbind(search_impd(location = "Oregon"),
#'                search_impd(location = "Washington"))

search_impd <- function(investigators = NULL,
                        location = NULL,
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
                 location = location,
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
