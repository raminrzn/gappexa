.gap_vars <- c("sex", "age", "fvc", "dlco")
.gap_alias <- c(gender = "sex", fvc_percent_predicted = "fvc",
                fvc_pct = "fvc", dlco_percent_predicted = "dlco",
                dlco_pct = "dlco")

#' GAP index (ModelsCloud entry point)
#' @param model_input Named list with `sex`, `age`, `fvc`, `dlco`; see
#'   [gap_index()].
#' @param ... The same fields as named arguments.
#' @return See [gap_index()].
#' @export
model_run <- function(model_input = NULL, ...) {
  args <- .gap_normalize(model_input, list(...), .gap_vars, .gap_alias)
  if (is.null(args) || length(args) == 0) args <- get_default_input()
  missing <- setdiff(.gap_vars, names(args))
  if ("dlco" %in% missing) {
    stop("`dlco` is required. Enter \"unable\" only if the patient could not ",
         "perform the test; that scores 3 points.", call. = FALSE)
  }
  if (length(missing) > 0) {
    stop("Missing required variable(s): ", paste(missing, collapse = ", "), ".",
         call. = FALSE)
  }
  do.call(gap_index, args)
}

#' Example GAP inputs (generated, not published cases)
#' @param n Optional number of rows.
#' @param ... Ignored.
#' @export
get_sample_input <- function(n = NULL, ...) {
  df <- data.frame(sex = c("male", "female"), age = c(68, 58),
                   fvc = c(62, 80), dlco = c("40", "unable"),
                   stringsAsFactors = FALSE)
  if (!is.null(n)) df <- utils::head(df, n)
  df
}

#' Default GAP input
#' @param ... Ignored.
#' @export
get_default_input <- function(...) {
  list(sex = "male", age = 68, fvc = 62, dlco = 40)
}
