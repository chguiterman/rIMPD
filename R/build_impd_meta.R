#' Assemble tidy table from IMPD search results
#'
#' This function extracts desired information form the search results to the
#' IMPD and returns a tidy data frame of the results
#'
#' @param api Resulting object from [ncei_paleo_api()]
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @importFrom tidyr unnest
#' @importFrom dplyr transmute mutate select group_by summarize left_join
#' @importFrom purrr map map_dbl map_chr pluck
#' @importFrom lubridate year
#' @importFrom stringr str_c
#'
#' @export
#' @examples
#' api <- ncei_paleo_api("Swetnam")
#' meta <- build_impd_meta(api)


build_impd_meta <- function(api) {
  if (! "rIMPD" %in% names(attributes(api)) ||
      attr(api, "rIMPD") != "ncei_api") {
    stop("The input data are incorrect. They must be a JSON from the NCEI API")
  }

  # Unwrap API JSON file
  in_list <- unnest(api$content$study, .data$site)

  # Build initial data frame
  out_df <- in_list %>%
    transmute(.data$uuid,
              .data$siteName,
              .data$studyCode,
              .data$investigators,
              first_year = .data$earliestYearCE,
              last_year = .data$mostRecentYearCE
    )
  out_noaa_params <- in_list %>%
    transmute(.data$uuid,
              .data$doi,
              contr_year = year(.data$contributionDate),
              .data$NOAAStudyId,
              .data$NOAASiteId,
              url = .data$onlineResourceLink
    )
  # Extract Lat-Long coordinates
  out_coords <- out_df %>%
    select(.data$uuid) %>%
    mutate(coords = pluck(in_list, "geo", "geometry", "coordinates"),
           latitude = map_dbl(.data$coords, ~ as.numeric(.x[1])),
           longitude = map_dbl(.data$coords, ~ as.numeric(.x[2])),
           elevation = as.numeric(pluck(in_list, "geo", "properties", "minElevationMeters"))
    ) %>%
    select(- .data$coords)

  # Extract species codes
  out_spp <- out_df %>%
    select(.data$uuid) %>%
    mutate(species_list = map(in_list[["paleoData"]], "species"),
           species_df = map(.data$species_list, ~.x[[1]]$speciesCode),
           species = map_chr(.data$species_df, str_c, collapse = ", ")
    ) %>%
    select(.data$uuid, .data$species)

  # Extract published references
  pub_list <- unnest(in_list, .data$publication)
  if (nrow(pub_list) > 0 ) {
    out_pub <- pub_list  %>%
      select(.data$uuid, .data$citation) %>%
      group_by(.data$uuid) %>%
      summarize(reference = str_c(.data$citation, collapse = "; "))
  }
  else out_pub <- data.frame(uuid = NA, citation = NA)

  # Combine
  out_df <- out_df %>%
    left_join(out_coords, by = "uuid") %>%
    left_join(out_spp, by = "uuid") %>%
    left_join(out_pub, by = "uuid") %>%
    left_join(out_noaa_params, by = "uuid") %>%
    select(- .data$uuid)

  attr(out_df, "rIMPD") <- "impd_meta"
  out_df
}
