#' @name varClean
#' @rdname varClean
#' @title Variable cleaning functions
#' @description A set of functions for cleaning variables in a dataset.
NULL

#'
#' @rdname varClean
#' @description `setNAs` is used to set a list of given values as `NA`.
#' @param x a vector to be updated with some new `NA`'s.
#' @param naVals a vector of values that should be considered as `NA`.
#' The default value is `NA` (no new NA's will be introduced).
#' @return a modified version of `x` where values in `naVals` are replaced with `NA`'s.
#' @export
#'
setNAs <- function(x, naVals=NA){
  sapply(naVals, function(v){
    x[which(x==v)] <<- NA
  })
  x
}


# Other functions to consider
## Fill Missing for longitudinal data.

