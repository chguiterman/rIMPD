

# Gather example data for Shiny tool --------------------------------------

library(rIMPD)
library(dplyr)
library(purrr)

quga_dat <- search_impd(species = "QUGA")

quga_dat <- quga_dat %>%
  mutate(FHX = map(studyCode, get_impd_fhx))

usethis::use_data(quga_dat, overwrite = TRUE)
