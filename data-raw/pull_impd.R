
# Pull complete North American tree-ring record from the IMPD -------------

library(rIMPD)

impd_result <- ncei_paleo_api()

impd_meta <- build_impd_meta(impd_result)

# Add date tag
attr(impd_meta, "search_date") <- Sys.Date()

write.csv(impd_meta, "data-raw/impd_meta.csv")
usethis::use_data(impd_meta, overwrite = TRUE)
