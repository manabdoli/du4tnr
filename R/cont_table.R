#' @rdname cont_table
#' @title Contingency Table
#' @description
#' Creating a contingency table based on a `response(s) ~ predictor(s)` formula.
#'
#' @param x A data frame
#' @param formula a `response(s) ~ predictor(s)` formula. If multiple variables
#'  are used as the response or predictor, `concat` is used to create a new variable
#'  by concatenating the values of all variables used.
#'  @param useNA This is passed to `table()` and can take these values:
#'  c("no", "ifany", "always"). The default value is "no".
#' @returns a contingency table based on the `formula`: Rows representing
#'  `response(s) ` and columns representing `predictor(s)`.
#'
#' @seealso [concat()]
#' @examples
#' cont_table(data.frame(A=c('a', 'b', 'a', 'b'), B=c('x', 'y', 'y', 'x')), A~B))
#' cont_table(data.frame(A=c('a', 'b', 'a', 'b', 'a', 'b'),
#'    B=c('x', 'y', 'y', 'x', 'y', 'x'), C=c('f', 'g')), A~B+C)
#'
#' @export
cont_table <- function(x, formula, useNA="no"){
  # check if the `formula` is of formula type and turn it into one if not.
  if(!inherits(x = formula, what = "formula")) formula <- as.formula(formula)
  response <- strsplit(as.character(formula)[[2]], split = '\\+')[[1]]
  response <- trimws(response)
  ridx <- which(!response %in% colnames(x))
  if(length(ridx)>0) response <- response[-ridx]
  yname <- ''
  y <- if(length(response)>0){
    yname <- paste(response, collapse = '+')
    if(length(response)==1) x[[response]] else{
      y <- apply(x[, response], 1, paste, collapse='-')
      as.vector(y)
    }
  } else{
    y <- rep(1, nrow(x))
  }

  predictors <- strsplit(as.character(formula)[[3]], split = '\\+')[[1]]
  predictors <- trimws(predictors)
  ridx <- which(!predictors %in% colnames(x))
  if(length(ridx)>0) predictors <- predictors[-ridx]

  zname <- ''
  z <- if(length(predictors)>0){
    zname <- paste(predictors, collapse = '+')
    if(length(predictors)==1) x[[predictors]] else{
      z <- apply(x[, predictors], 1, paste, collapse='-')
      as.vector(z)
    }
  } else{
    z <- rep(1, nrow(x))
  }

  table(y, z, dnn = c(yname, zname), useNA = useNA)
}
