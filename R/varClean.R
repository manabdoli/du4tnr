#' @name varClean
#' @rdname varClean
#' @title Variable cleaning functions
#' @description A set of functions for cleaning variables in a dataset.
NULL

#'
#' @rdname varClean
#' @description `setNAs` is used to set some values as `NA`.
#' @param x a vector to be updated with some new `NA`'s.
#' @param naVals a vector of values that should be considered as `NA`.
#' The default value is `NA` (no new NA's will be introduced).
#' @return a modified version of `x` where values in `naVals` are replaced with `NA`'s.
#' @export
#'
setNAs <- function(x, naVals=NA){
  sapply(x, function(v){
    ifelse(v %in% naVals, NA, v)
  })
}

#'
#' @rdname varClean
#' @description The `var2cat` is a wrapper for `factor()`, which creates a
#'   factor variable with some defined levels and replacing all values left out
#'   with `NA`'s.
#' @param levels a vector of valid values(levels) to remain in the resulting factor;
#'  anything other values will be replaced with `NA`'s.
#' @param labels a vector of strings to be used when printing factor `levels`.
#'   The default value is the vector used as `levels`.
#'
#' @export
var2cat <- function(x, levels, labels=levels){
  if(length(levels)!=length(labels))
    stop('Error: Length of levels and labels should be the same!')
  # # Set values missing in levels to NA
  # x[!x%in%levels] <- NA
  # Augment levels if needed
  factor(x, levels, labels)
}
