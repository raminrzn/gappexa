# GAP index and staging system (Ley B, et al. Ann Intern Med 2012;156:684-691).
# Points and stage risks as tabulated in Zhang et al., Clin Respir J 2023,
# supplement Tables S1-S2 (CC BY 4.0); points cross-checked against MDCalc.
#   Sex: female 0, male 1
#   Age (completed years): <=60 0, 61-65 1, >65 2
#   FVC % predicted: >75 0, 50-75 1, <50 2
#   DLCO % predicted: >55 0, 36-55 1, <=35 2, unable to perform 3
# Stage I 0-3, II 4-5, III 6-8 points.
#
# The published bands are whole numbers. Age and DLCO are therefore required
# as whole numbers: a DLCO of 35.5 falls between "<=35" and "36-55", and the
# source does not say which side it belongs to. FVC bands (>75, 50-75, <50)
# cover every decimal, so FVC may have decimals.

.gap_stage_risk <- data.frame(
  stage = c("I", "II", "III"),
  mortality_1y = c(0.056, 0.162, 0.392),
  mortality_2y = c(0.109, 0.299, 0.621),
  mortality_3y = c(0.163, 0.421, 0.768),
  stringsAsFactors = FALSE
)

.gap_whole <- function(x, field, lo, hi) {
  x <- .gap_num(x, field, lo, hi)
  if (x != round(x)) {
    stop("`", field, "` must be a whole number: the GAP bands are defined on ",
         "whole numbers. Round it first.", call. = FALSE)
  }
  x
}

.gap_unable <- function(x) {
  is.character(x) && length(x) == 1L &&
    tolower(gsub("[^a-z]", "", tolower(x))) %in%
    c("unable", "unabletoperform", "cannotperform", "cantperform",
      "couldnotperform")
}

#' GAP index and stage for idiopathic pulmonary fibrosis
#'
#' The mortality figures are stage-level estimates from the original
#' derivation cohort, not individual predictions, and not the continuous GAP
#' calculator. A 2023 external validation found they overestimate mortality in
#' stage I.
#'
#' @param sex `"male"` or `"female"`.
#' @param age Age in completed years (whole number).
#' @param fvc FVC, % predicted.
#' @param dlco DLCO, % predicted (whole number), or `"unable"` if the patient
#'   could not perform the test. Missing is not the same as unable.
#' @return A data frame with `points` (0-8), `stage` (I-III) and the stage's
#'   `mortality_1y`, `mortality_2y`, `mortality_3y` (0-1).
#' @references Ley B, Ryerson CJ, Vittinghoff E, et al. *Ann Intern Med.*
#'   2012;156(10):684-691. \doi{10.7326/0003-4819-156-10-201205150-00004}
#' @examples
#' gap_index(sex = "male", age = 68, fvc = 62, dlco = 40)
#' gap_index(sex = "female", age = 58, fvc = 80, dlco = "unable")
#' @export
gap_index <- function(sex, age, fvc, dlco) {
  key <- tolower(trimws(as.character(sex)))
  male <- if (key %in% c("male", "m")) 1 else if (key %in% c("female", "f")) 0 else
    stop('Unrecognised `sex`: "', sex, '". Use "male" or "female".', call. = FALSE)
  age <- .gap_whole(age, "age", 18, 110)
  fvc <- .gap_num(fvc, "fvc", 1, 200)
  dlco_pts <- if (.gap_unable(dlco)) 3 else {
    d <- .gap_whole(dlco, "dlco", 1, 200)
    if (d > 55) 0 else if (d >= 36) 1 else 2
  }
  age_pts <- if (age <= 60) 0 else if (age <= 65) 1 else 2
  fvc_pts <- if (fvc > 75) 0 else if (fvc >= 50) 1 else 2
  points <- male + age_pts + fvc_pts + dlco_pts
  stage <- if (points <= 3) "I" else if (points <= 5) "II" else "III"
  row <- .gap_stage_risk[.gap_stage_risk$stage == stage, ]
  data.frame(points = points, stage = stage, mortality_1y = row$mortality_1y,
             mortality_2y = row$mortality_2y, mortality_3y = row$mortality_3y,
             stringsAsFactors = FALSE)
}
