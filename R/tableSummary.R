#' @rdname tableSummary
#' @name tableSummary
#' @title Summarizing Functions for `table` Object
#' @description Utility functions for adding Totals
#' @param x a table or data.frame object.
#' @param na.rm a logical value; TRUE will remove NAs from `x` before processing.
#'
#'
NULL

#' @rdname tableSummary
#' @description
#' `total_col` adds a column summary to a table/data.frame.
#' @returns `total_col` returns a new object with an additional column,
#'  named `Total` or `Total.Col`
#' @export
#'
total_col <- function(x, na.rm = FALSE){
  UseMethod("total_col")
}

#' @rdname tableSummary
#' @description
#' `total_row` adds a row summary to a table/data.frame.
#' @returns `total_row` returns a new object with an additional row,
#'  named `Total` or `Total.Row`
#' @export
#'
total_row <- function(x, na.rm = FALSE){
  UseMethod("total_row")
}

#' @rdname tableSummary
#' @description
#' `total_col.table` adds a column summary to a table.
#' @export
total_col.table <- function(x, na.rm = FALSE){
  dimNames <- dimnames(x)
  # use Total for the first summary
  useTotal <- TRUE
  # Rename Total Row if needed
  totalRow <- which(dimNames[[1]]=="Total")
  if(length(totalRow)>0){
    dimNames[[1]][totalRow] <- "Total.Row"
    useTotal <- FALSE
  }
  # Check if Total already exists
  totalCol <- which(dimNames[[2]] %in% c("Total", "Total.Col"))
  if(length(totalCol)>0){
    warning(sprintf("A column named `%s` already exists; no changes were made!",
                    dimNames[[2]][totalCol])
    )
    return(x)
  }
  # Add Total Column (row sums)
  x <- cbind(x, rowSums(x, na.rm = na.rm))
  dimnames(x) <- list(dimNames[[1]],
                      c(dimNames[[2]], if(useTotal) "Total" else "Total.Col"))
  x
}

#' @rdname tableSummary
#' @description
#' `total_row.table` Adds a row summary to a table.
#' @export
#'
total_row.table <- function(x, na.rm = FALSE){
  dimNames <- dimnames(x)
  # use Total for the first summary
  useTotal <- TRUE
  # Rename Total Column if needed
  totalCol <- which(dimNames[[2]]=="Total")
  if(length(totalCol)>0){
    dimNames[[2]][totalCol] <- "Total.Col"
    useTotal <- FALSE
  }
  # Check if Total already exists
  totalRow <- which(dimNames[[1]] %in% c("Total", "Total.Row"))
  if(length(totalRow)>0){
    warning(sprintf("A row named `%s` already exists; no changes were made!",
                    dimNames[[1]][totalRow])
    )
    return(x)
  }
  # Add Total Row (column sums)
  x <- rbind(x, colSums(x, na.rm = na.rm))
  dimnames(x) <- list(c(dimNames[[1]], if(useTotal) "Total" else "Total.Row"),
  dimNames[[2]])
  x
}

#' @rdname tableSummary
#' @description
#' `total_col.matrix` adds a column summary to a matrix.
#' @export
total_col.matrix <- function(x, na.rm = FALSE){
  total_col.table(x, na.rm)
}

#' @rdname tableSummary
#' @description
#' `total_col.matrix` adds a row summary to a matrix.
#' @export
total_row.matrix <- function(x, na.rm = FALSE){
  total_row.table(x, na.rm)
}

#' @rdname tableSummary
#' @description
#' `total_col.table` adds a column summary to a data.frame.
#' @export
total_col.data.frame <- function(x, na.rm = FALSE){
  dimNames <- dimnames(x)
  # use Total for the first summary
  useTotal <- TRUE
  # Rename Total Row if needed
  totalRow <- which(dimNames[[1]]=="Total")
  if(length(totalRow)>0){
    dimNames[[1]][totalRow] <- "Total.Row"
    useTotal <- FALSE
  }
  # Check if Total already exists
  totalCol <- which(dimNames[[2]] %in% c("Total", "Total.Col"))
  if(length(totalCol)>0){
    warning(sprintf("A column named `%s` already exists; no changes were made!",
                    dimNames[[2]][totalCol])
    )
    return(x)
  }
  # Add Total Column (row sums)
  cIdx <- which(lapply(x, is.numeric) %>% unlist())
  if(sum(cIdx)==0) {
    x <- cbind(x, NA)
  } else {
    x <- cbind(x, rowSums(x[,cIdx], na.rm = na.rm))
  }
  dimnames(x) <- list(dimNames[[1]],
                      c(dimNames[[2]], if(useTotal) "Total" else "Total.Col"))
  x
}

#' @rdname tableSummary
#' @description
#' `total_row.table` Adds a row summary to a table.
#' @export
#'
total_row.data.frame <- function(x, na.rm = FALSE){
  dimNames <- dimnames(x)
  # use Total for the first summary
  useTotal <- TRUE
  # Rename Total Column if needed
  totalCol <- which(dimNames[[2]]=="Total")
  if(length(totalCol)>0){
    dimNames[[2]][totalCol] <- "Total.Col"
    useTotal <- FALSE
  }
  # Check if Total already exists
  totalRow <- which(dimNames[[1]] %in% c("Total", "Total.Row"))
  if(length(totalRow)>0){
    warning(sprintf("A row named `%s` already exists; no changes were made!",
                    dimNames[[1]][totalRow])
    )
    return(x)
  }
  # Add Total Row (column sums)
  cIdx <- which(lapply(x, is.numeric) %>% unlist())
  if(sum(cIdx)==0) {
    x <- rbind(x, NA)
  } else {
    rSum <- sapply(1:NCOL(x),
                   function(k) if(!is.numeric(x[,k])) NA else
                     sum(x[,k], na.rm = na.rm)
    )
    x <- rbind(x, rSum)
  }
  dimnames(x) <- list(c(dimNames[[1]], if(useTotal) "Total" else "Total.Row"),
                      dimNames[[2]])
  x
}
