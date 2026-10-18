test_that("gateway returns JSON and ignores platform fields", {
  js <- gateway(model_input = get_default_input(), execution_id = "z",
                callback_url = "https://example.invalid/cb")
  r <- jsonlite::fromJSON(js)
  expect_equal(r$points, 5)
  expect_equal(r$stage, "II")
  expect_equal(model_run(list(sex = "female", age = 58, fvc = 80, dlco = "unable"))$points, 3)
})
