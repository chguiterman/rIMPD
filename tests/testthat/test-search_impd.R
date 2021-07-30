
library(stringr)

quga_search <- search_impd(species = "QUGA")
swetnam_search <- search_impd(investigators = "Swetnam")

test_that("Returns a data frame", {
  expect_s3_class(quga_search, "data.frame")
})

test_that("Species are correct", {
  quga_in_search <- str_extract_all(quga_search$species, "QUGA")
  expect_gte(length(quga_in_search), 4)
})

test_that("Investigators are correct", {
  tom_in_search <- str_extract_all(swetnam_search$investigators, "Swetnam")
  expect_gte(length(tom_in_search), 78)
})
