
swetnam_search <- ncei_paleo_api(investigators = "Swetnam")

test_that("URL is properly built", {
  expect_equal(swetnam_search$url,
               "https://www.ncdc.noaa.gov/paleo-search/study/search.json?metadataOnly=true&dataPublisher=NOAA&dataTypeId=12&locations=Continent%3ENorth%20America&searchText=.fhx&investigators=Swetnam")
})

test_that("Error message works for bad search", {
  expect_error(ncei_paleo_api(investigators = "FooBar"),
               "This search returned no results")
})
