
#' tabsort
#'
#' Returns a sorted (descending) frequency tbl
#'
#' @param .data Data
#' @param ... Unquoted column names of variables to include in table. Default
#'   is to use all columns.
#' @param prop Logical indicating whether to include a proportion of total
#'   obs column.
#' @param sort Logical indicating whether to sort the returned object.
#' @param na_omit Logical indicating whether to exclude missing. If all
#'   responses are missing, a missing value is used as the single category.
#' @return Frequency tbl
#' @examples
#'
#' ## generate example data
#' x <- sample(letters[1:4], 200, replace = TRUE)
#' y <- sample(letters[5:8], 200, replace = TRUE)
#'
#' ## count and sort frequencies for each vector
#' tabsort(x)
#' tabsort(y)
#'
#' ## combine x and y into data frame
#' dat <- data.frame(x, y)
#'
#' ## select columns and create freq table
#' tabsort(dat, x)
#' tabsort(dat, x, y)
#'
#' @export
tabsort <- function(.data, ..., prop = TRUE, na_omit = TRUE, sort = TRUE) {
  UseMethod("tabsort")
}

#' @export
tabsort.default <- function(.data, ..., prop = TRUE, na_omit = TRUE, sort = TRUE) {
  ## get names from dots
  vars <- names(pretty_dots(...))

  ## validate
  if (!is.logical(prop)) {
    stop("'prop' should be logical, indicating whether to return proportions. ",
      "If you supplied a vector with the name 'prop' please rename to ",
      "something else", call. = FALSE)
  }

  ## if only named objects are supplied
  if (missing(.data) && length(vars) > 0) {
    .data <- data.frame(..., stringsAsFactors = FALSE)

    ## if no data at all is supplied
  } else if (missing(.data)) {
    stop("must supply data or named object")

    ## if unnamed atomic vector & one or more named objects are supplied
  } else if (!is.recursive(.data) && length(vars) > 0) {

    ## rename .data using expression text
    assignname <- deparse(substitute(.data))
    .data <- list(.data, ...)
    names(.data) <- c(assignname, vars)

    ## if single unnamed vector is supplied
  } else if (!is.recursive(.data)) {
    .data <- data.frame(x = .data, stringsAsFactors = FALSE)

    ## otherwise use tidy selection of any supplied var names
  } else {
    .data <- select_data(.data, ...)
  }
  if (na_omit) {
    if (is.data.frame(.data)) {
      .data <- na_omit_data.frame(.data)
    } else {
      .data <- na_omit_list(.data)
    }
  }
  ## check/fix names
  if ("n" %in% names(.data)) {
    warning("variable n renamed to .n", call. = FALSE)
    names(.data)[names(.data) == "n"] <- ".n"
  }
  if ("prop" %in% names(.data)) {
    warning("variable prop renamed to .prop", call. = FALSE)
    names(.data)[names(.data) == "prop"] <- ".prop"
  }
  x <- as_tbl_data(do.call("table", as.list(.data)))
  if (prop) {
    x$prop <- x$n / sum(x$n, na.rm = TRUE)
  }
  if (sort) {
    x <- x[order(x$n, decreasing = TRUE), ]
  }
  x
}


#' @inheritParams tabsort
#' @rdname tabsort
#' @export
ntbl <- function(.data, ...) {
  .data <- select_data(.data, ...)
  as_tbl_data(table(.data))
}
