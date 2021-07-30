
api <- ncei_paleo_api("Swetnam")
meta <- build_impd_meta(api)

fake_df <- tibble::tribble(
            ~colA, ~colB,
            "a",   1,
            "b",   2,
            "c",   3
)

test_that("Builds a tibble", {
  expect_s3_class(meta, "tbl_df")
})

test_that("Names are correct", {
  expect_named(meta,
               c("siteName", "studyCode","investigators", "first_year",
                 "last_year", "latitude", "longitude", "elevation",
                 "species", "reference", "doi", "contr_year",
                 "NOAAStudyId", "NOAASiteId", "url"))
})

test_that("Error catch is robust", {
  expect_error(build_impd_meta(fake_df),
               "The input data are incorrect. They must be a JSON from the NCEI API")
})
