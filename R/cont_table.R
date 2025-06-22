#' @rdname concat
#' @title Concatenating variables to create a new one
#' @description
#' A utility function for concatenates a `+`-separated list of variables.
#' @param x a data frame
#' @param formula a response-less formula (~ followed by a `+`-separated list of
#'  variables)
#' @returns A new variable by concatenating values of variables given as
#'  predictors given in the `formula`.
#' @examples
#' concat(data.frame(A=c('a', 'b', 'a', 'b'), B=c('x', 'y', 'y', 'x')), ~A+B)
#'
concat <- function(x, formula){
  varList <- strsplit(as.character(formula)[[2]], split = '\\+')[[1]]
  if(any(varList=='~'))
    varList <- strsplit(as.character(formula)[[3]], split = '\\+')[[1]]
  varList <- trimws(varList)
  ridx <- which(!varList %in% colnames(x))
  if(length(ridx)==length(varList))
    stop('No variable were found!')

  if(length(ridx)>0){
    warning('Some variables were not found: ',
            paste(varList[ridx], collapse=', '))
    varList <- varList[-ridx]
  }

  # y <- if(length(varList)==0)
  #   stop('No variable were found!')

  if(length(varList)==1) x[[varList]] else{
    y <- apply(x[, varList], 1, paste, collapse='-')
    as.vector(y)
  }
}

#' @rdname cont_table
#' @title Contingency Table
#' @description
#' Creating a contingency table for based on a `response(s) ~ predictor(s)` formula.
#'
#' @param x A data frame
#' @param formula a formula of form `response(s) ~ predictor(s)` for constructing the
#' contingency table
#'
#' @returns a contingency table which its rows and columns are identified by
#' the `formula`.
#'
#' @seealso [concat()]
#' @examples
#' cont_table(data.frame(A=c('a', 'b', 'a', 'b'), B=c('x', 'y', 'y', 'x')), A~B))
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
