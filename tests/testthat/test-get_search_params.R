
invs <- get_search_params("investigators")
spp <- get_search_params("species")


test_that("Investigator search results are a character string", {
  expect_type(invs, "character")
})

test_that("There are many investigators in the search", {
  expect_gte(length(invs), 251)
})

test_that("Species returns a data frame", {
  expect_s3_class(spp, "data.frame")
})

test_that("There are many species in the search", {
  expect_gte(nrow(spp), 57)
})
