#' @name which_ds
#' @rdname which_ds
#' @title Searching a column name in datasets (data frames)
#'
#' @param columnName a vector of variable names to be looked up is different datasets.
#' @param ... is a list of all datasets where variable names will be searched for.
#' @return is a named, logical array that determines which dataset includes
#'   variables listed in `columnName`.
NULL

#' @rdname which_ds
#' @description
#' A helper function for looking up one variable name in a list of datasets.
#' @param columnName the name of the variable of interest
#' @param ... a comma separated list of datasets.
whichds <- function(columnName=NULL,
                     ...){
  dlist <- list(...)
  if(length(dlist)==0) return(NULL)
  sapply(dlist,
         function(l) any(columnName %in% names(l)))
}

#' @export which_ds
#' @description
#' Looking up the name of several variables in a list of datasets.
#' @param columnName a character vector of name of variables of interest.
#' @param ... a comma separated list of datasets
which_ds <- function(columnName=NULL,
                     ...){
  dlist <- list(...)
  if(length(dlist)==0) return(NULL)
  if(length(columnName)==1)
    whichds(columnName = columnName, ...) else {
      vzd_wds <- Vectorize(whichds, "columnName", SIMPLIFY = F)
      vzd_wds(columnName = columnName, ...) %>%
        do.call(what="rbind")
    }
}

