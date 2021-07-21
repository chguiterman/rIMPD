
test_that("`get_impd_fhx()` returns an FHX object", {
  expect_s3_class(get_impd_fhx("ca124001"), "fhx")
})

test_that("`get_impd_fhx()` errors on >1 study code", {
  expect_error(get_impd_fhx(c("hht", "ttr")))
})
