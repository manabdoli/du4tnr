#' Describe a Dataset
#' @param x a dataset
#' @param maxLevels the maximum number of levels for categorical variables (default is 7)
#' @param var2row if TRUE, each variable is summarized as a row; default is
#'  FALSE, where each column represents the summary of a variable
#' @return A list of at most two tables (Numerical and Categorical) containing
#'   the summary information for variables of each type.
#'
#' @export
describe_ds <- function(x, maxLevels=7, var2row=FALSE){
  if(is.vector(x)) stop('The x is not a dataset!')
  colType <- sapply(1:ncol(x), \(k) is.numeric(x[[k]]))
  nIdx <- which(colType)
  nnIdx <- which(!colType)
  results <- list()
  if(length(nIdx)>0){
    # Numerical Summary
    numSumm <- summary(x[nIdx], maxLevels=maxLevels)
    if(var2row) numSumm <- t(numSumm)
    results$Numerical <- numSumm
  }
  if(length(nnIdx)>0){
    # Categorical/Logical/Character Summary
    catSumm <- sapply(nnIdx, \(k) table(x[k]), simplify = FALSE)
    names(catSumm) <- colnames(x[nnIdx])
    nmax <- max(sapply(catSumm, length))
    catSumm <- lapply(catSumm, function(v){
      n <- length(v)
      if(n>maxLevels){
        v <- c(v[1:(maxLevels-1)], sum(v[maxLevels:n]))
        names(v) <- c(names(v)[1:(maxLevels-1)],
                      sprintf('Other (%g)', n))
        v
      }
      if(n<maxLevels) {
        v[maxLevels] <- NA
        v[is.na(v)] <- ""
        v
      } else v
    })
    catSumm <- lapply(catSumm, function(v){
      cntnt <- paste(formatC(names(v), width=4), ":", formatC(v, width=4), sep='')
      cntnt[trimws(cntnt)==":"] <- ""
      cntnt
    })
    catSumm <- do.call('cbind', catSumm)  %>% as.table() %>% `rownames<-`(NULL)
    if(var2row) catSumm <- t(catSumm)
    results$Categorical <- catSumm
  }
  results
}

