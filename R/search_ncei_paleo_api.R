#' Search the NCEI Paleo API for IMPD records
#'
#' Query the IMPD for fire-scar records based on search parameters
#'
#' @param investigators Name of investigator listed by the IMPD
#' @param minLat Minimum latitude of sites, in decimal degrees (WGS84)
#' @param maxLat Maximum latitude of sites, in decimal degrees (WGS84)
#' @param minLon Minimum longitude of sites, in decimal degrees (WGS84)
#' @param maxLon Maximum longitude of sites, in decimal degrees (WGS84)
#' @param minElev Minimum elevation of sites, in meters
#' @param maxElev Maximum elevation of sites, in meters
#' @param earliestYear In calendar years CE (use negative for BCE)
#' @param latestYear In calendar years CE (use negative for BCE)
#' @param species Use four-letter codes for tree species
#'
#' @importFrom magrittr %>%
#' @import httr
#' @import jsonlite
#' @import rlang
#' @import glue
#'
#' @export
#'
#' @examples
#' # Search the IMPD for Tom Swetnam's contributions
#' swetnam_search <- search_ncei_paleo_api(investigators = "Swetnam")

search_ncei_paleo_api <- function(investigators = NULL,
                                  minLat = NULL,
                                  maxLat = NULL,
                                  minLon = NULL,
                                  maxLon = NULL,
                                  minElev = NULL,
                                  maxElev = NULL,
                                  earliestYear = NULL,
                                  latestYear = NULL,
                                  species = NULL) {
  url <- parse_url("https://www.ncdc.noaa.gov/paleo-search/study/search.json")
  url$scheme = "https"
  url$query = list(metadataOnly="true",
                   dataPublisher = "NOAA",
                   dataTypeId = "12",
                   locations = "Continent>North America",
                   searchText = ".fhx",
                   investigators = investigators,
                   minLat = minLat,
                   maxLat = maxLat,
                   minLon = minLon,
                   maxLon = maxLon,
                   minElev = minElev,
                   maxElev = maxElev,
                   earliestYear = earliestYear,
                   latestYear = latestYear,
                   species = species
  )
  search_url <- build_url(url)
  resp <- GET(url, user_agent("https://github.com/chguiterman/rIMPD"))
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                               simplifyDataFrame = TRUE)
  if (length(parsed$study) == 0) {
    abort(glue("This search returned no results\ncheck the url: {search_url}"))
  }
  else {
    structure(
      list(
        url = search_url,
        content = parsed,
        response = resp
      ),
      rIMPD = "ncei_api"
    )
  }
}
