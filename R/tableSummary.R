#' @rdname tableSummary
#' @name tableSummary
#' @title Summarizing Functions for `table` Object
#' @description Utility functions for adding Totals
#'
#'
NULL

#' @rdname tableSummary
#' @description
#' `col_total.table` adds a column summary to a table.
#' @param x a table object.
#' @returns `col_total` returns a new table object with an additional column,
#'  named `Total` or `Total.Col`
#' @export
#'
col_total.table <- function(x){
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
  x <- cbind(x, rowSums(x))
  dimnames(x) <- list(dimNames[[1]],
                      c(dimNames[[2]], if(useTotal) "Total" else "Total.Col"))
  x
}

#' @rdname tableSummary
#' @description
#' `row_total.table` Adds a row summary to a table.
#' @param x a table object.
#' @returns `row_total` returns a new table object with an additional row,
#'  named `Total` or `Total.Row`
#' @export
#'
row_total.table <- function(x){
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
  x <- rbind(x, colSums(x))
  dimnames(x) <- list(c(dimNames[[1]], if(useTotal) "Total" else "Total.Row"),
  dimNames[[2]])
  x
}
