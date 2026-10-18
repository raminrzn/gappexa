# Points and stage risks: Zhang et al. 2023 supplement Tables S1-S2, reproducing
# Ley et al. 2012. Points cross-checked against MDCalc's GAP index. Patients
# below are generated test cases, not published examples.

test_that("each band edge scores as tabulated", {
  p <- function(...) gap_index(...)$points
  base <- function(sex = "female", age = 50, fvc = 90, dlco = 70)
    p(sex = sex, age = age, fvc = fvc, dlco = dlco)
  expect_equal(base(), 0)
  expect_equal(base(sex = "male"), 1)
  expect_equal(c(base(age = 60), base(age = 61), base(age = 65), base(age = 66)),
               c(0, 1, 1, 2))
  expect_equal(c(base(fvc = 75.1), base(fvc = 75), base(fvc = 50),
                 base(fvc = 49.9)), c(0, 1, 1, 2))
  expect_equal(c(base(dlco = 56), base(dlco = 55), base(dlco = 36),
                 base(dlco = 35), base(dlco = "unable")), c(0, 1, 1, 2, 3))
  expect_equal(p(sex = "male", age = 70, fvc = 40, dlco = "unable to perform"), 8)
})

test_that("stage boundaries and all three risk vectors match Table S2", {
  s <- function(...) gap_index(...)
  # 3 points -> I, 4 -> II, 5 -> II, 6 -> III
  r3 <- s("male", 61, 60, 70)          # 1 + 1 + 1 + 0
  r4 <- s("male", 66, 60, 70)          # 1 + 2 + 1 + 0
  r5 <- s("male", 66, 60, 50)          # 1 + 2 + 1 + 1
  r6 <- s("male", 66, 45, 50)          # 1 + 2 + 2 + 1
  expect_equal(c(r3$points, r4$points, r5$points, r6$points), 3:6)
  expect_equal(c(r3$stage, r4$stage, r5$stage, r6$stage), c("I", "II", "II", "III"))
  expect_equal(unlist(r3[3:5]), c(mortality_1y = 0.056, mortality_2y = 0.109, mortality_3y = 0.163))
  expect_equal(unlist(r4[3:5]), c(mortality_1y = 0.162, mortality_2y = 0.299, mortality_3y = 0.421))
  expect_equal(unlist(r6[3:5]), c(mortality_1y = 0.392, mortality_2y = 0.621, mortality_3y = 0.768))
})

test_that("ambiguous or missing inputs are refused, not guessed", {
  expect_error(gap_index("male", 68, 62, 35.5), "whole number")
  expect_error(gap_index("male", 68.5, 62, 40), "whole number")
  expect_error(model_run(list(sex = "male", age = 68, fvc = 62)), "unable")
  expect_error(model_run(list(sex = "male", age = 68, fvc = 62, dlco = NULL)), "unable")
  expect_error(gap_index("male", 68, 62, "not done"), "dlco")
})
