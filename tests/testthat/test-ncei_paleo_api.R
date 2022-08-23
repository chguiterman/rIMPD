
swetnam_search <- ncei_paleo_api(investigators = "Swetnam")

test_that("URL is properly built and functions online", {
  expect_false(httr::http_error(swetnam_search[["url"]]))
})

test_that("Error message works for bad search", {
  expect_error(ncei_paleo_api(investigators = "FooBar"),
               "The search yielded no results, try different parameters in your next search")
})
