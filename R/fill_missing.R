#' Filling missing values
#' Replacing a missing value with prior values.
#' @importFrom vctrs vec_fill_missing
#' @param x a vector to be updated
#' @param value The value to be considered as missing; if missing, NA is used as
#'   the default.
#' @param direction the direction where non-missing values are reused.
#' @returns The updated x vector where missing values are filled by existing
#'   values.
#' @export
fill_missing <- function(x, value=NULL, direction='down'){
  if(!(missing(value) || is.na(value))){
    naIdx <- is.na(x)
    x[which(x==value)] <- NA
    x <- vctrs::vec_fill_missing(x, direction = direction)
    if(length(naIdx)>0) x[naIdx] <- NA
    x
  } else
    vctrs::vec_fill_missing(x, direction = direction)
}

#' @rdname fill_missing
#' @description
#' Complements missing value of `x` with the values of `y`
#'
fill_complement <- function(x, y, fill_missing = 'down'){
  x[is.na(x)] <- y[is.na(x)]
  if(!is.null(fill_missing) & !is.na(fill_missing))
    x <- fill_missing(x, direction = fill_missing)
}

