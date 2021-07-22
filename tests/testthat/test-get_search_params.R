
test_that("Investigator search", {
  expect_type(get_search_params("investigator"), "character")
  expect_gte(length(get_search_params("investigator")), 251)
})

test_that("Species search", {
  expect_s3_class(get_search_params("species"), "data.frame")
  expect_gte(nrow(get_search_params("species")), 57)
})
