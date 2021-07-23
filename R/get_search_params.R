#' Extract IMPD search parameters for `investigators` and `species`
#'
#' This function pulls from the updated store of contributor names and species
#' to help users specify their searches.
#'
#' @param output Two data sets are available, "investigators" (the default) and
#'   "species"
#'
#' @note The list of investigators names also includes those who have
#'   contributed to the charcoal and pollen databases of the IMPD. Some names
#'   may not generate search results here because `rIMPD` specifies tree-ring
#'   records.
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_split
#' @importFrom tibble as_tibble
#' @importFrom stats setNames
#'
#' @export
#'
#' @examples
#' # Retrieve the list of IMPD contributors
#' get_search_params("investigators")
#'
#' # Retrieve a data frame of species codes
#' get_search_params("species")

get_search_params <- function(output = c("investigators", "species")) {
  resp <- GET("https://www.ncdc.noaa.gov/paleo-search/study/params.json")

  params <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                     simplifyDataFrame = TRUE)

  investigators <- params[["investigators"]][["NOAA"]][["12"]]
  species_list <- str_split(params[["species"]][["NOAA"]][["12"]], ":")
  species_df <- do.call(rbind, species_list) %>%
    as_tibble(.name_repair = "minimal") %>%
    setNames(c("species", "spp_code"))

  output <- match.arg(output)

  if (output == "investigators") {
    out <- investigators
  }
  if (output == "species") {
    out <- species_df
  }
  out
}
