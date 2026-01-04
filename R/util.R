#' @rdname util.R
#' @name Utility functions for internal use
#' @title Internal helper functions
#' @keywords internal
NULL

#' @rdname util.R
#' @description
#' Calculate file hash for integrity checking
#'
#' @param file_path Path to the file
#' @return MD5 hash of the file
calculate_file_hash <- function(file_path) {
  if (!file.exists(file_path)) {
    return(NA_character_)
  }
  digest::digest(file_path, file = TRUE, algo = "md5")
}


#' @rdname util.R
#' @title Concatenating variables to create a new one (as Interaction Variable)
#' @description
#' A utility function that creates a new variable by joining the values of a given
#'  list of variables.
#' @param x a data frame where variables are taken from.
#' @param formula a response-less formula (~ followed by a `+`-separated list of
#'  variables)
#' @returns A new variable by concatenating values of variables given by `formula`.
#' @examples
#' du4tnr:::concat(data.frame(A=c('a', 'b', 'a', 'b'), B=c('x', 'y', 'y', 'x')), ~A+B)
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

  if(length(varList)==1) x[[varList]] else{
    y <- apply(x[, varList], 1, paste, collapse='-')
    as.vector(y)
  }
}
