#' Extract IMPD search parameters for `investigators`, `species`, and `location`
#'
#' Retrieve the updated store of contributor names, site locations, and tree
#' species to help specify searches of the International Multiproxy
#' Paleofire Database (IMPD).
#'
#' @param output Three data sets are available: "investigators" (the default),
#'   "location", and "species"
#'
#' @note The list of investigators names also includes those who have
#'   contributed to the charcoal and pollen databases of the IMPD. Some names
#'   may not generate search results here because `rIMPD` specifies tree-ring
#'   records. Also, apologies to Canadians for using "state" as a
#'   variable name in the output for "location"
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_split str_detect
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
#' @importFrom dplyr filter
#' @importFrom rlang abort
#' @importFrom glue glue
#'
#' @export
#'
#' @examples
#' # Retrieve the list of IMPD contributors
#' get_search_params("investigators")
#'
#' # Retrieve a data frame of species codes
#' get_search_params("species")

get_search_params <- function(output) {
  if (missing(output)) {
    abort(
      glue("Please provide one of c('investigators', 'species', 'location')")
    )
  }
  if (length(output) > 1) {
    abort(
      glue("Please provide only one of c('investigators', 'species', 'location')")
    )
  }

  resp <- GET("https://www.ncdc.noaa.gov/paleo-search/study/params.json")

  params <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                     simplifyDataFrame = TRUE)

  investigators <- as_tibble(params[["investigators"]][["NOAA"]][["12"]]) %>%
    setNames("investigator")

  species_list <- str_split(params[["species"]][["NOAA"]][["12"]], ":")
  species_df <- do.call(rbind, species_list) %>%
    as_tibble(.name_repair = "minimal") %>%
    setNames(c("species", "spp_code"))

  location_list <- params[["locations"]][["NOAA"]][["12"]]
  NA_locs_list <- location_list[
    str_detect(location_list, "Continent>North America>")
  ] %>%
    str_split(">")
  loc_df <- do.call(rbind,
                    NA_locs_list[lengths(NA_locs_list) > 3]
                    ) %>%
    as_tibble(.name_repair = "minimal") %>%
    setNames(c("setting", "continent", "country", "state_province")) %>%
    select(3:4) %>%
    filter(.data$country != "Central America")

  if (output == "investigators") {
    out <- investigators
  }
  if (output == "location") {
    out <- loc_df
  }
  if (output == "species") {
    out <- species_df
  }
  out
}
