#' Describe a Dataset
#' @param x a dataset
#' @param maxsum the maximum number of summary items to supply
#' @return A list of at most two tables (Numerical and Categorical) containing
#'   the summary information for variables of each type.
#'
#' @export
describe_ds <- function(x, maxsum=7, long=FALSE){
  if(is.vector(x)) stop('The x is not a dataset!')
  colType <- sapply(1:ncol(x), \(k) is.numeric(x[[k]]))
  nIdx <- which(colType)
  nnIdx <- which(!colType)
  results <- list()
  if(length(nIdx)>0){
    # Numerical Summary
    numSumm <- summary(x[nIdx], maxsum=maxsum)
    if(long) numSumm <- t(numSumm)
    results$Numerical <- numSumm
  }
  if(length(nnIdx)>0){
    # Categorical/Logical/Character Summary
    catSumm <- sapply(nnIdx, \(k) table(x[k]), simplify = FALSE)
    names(catSumm) <- colnames(x[nnIdx])
    nmax <- max(sapply(catSumm, length))
    catSumm <- lapply(catSumm, function(v){
      n <- length(v)
      if(n>maxsum){
        v <- c(v[1:(maxsum-1)], sum(v[maxsum:n]))
        names(v) <- c(names(v)[1:(maxsum-1)],
                      sprintf('Other (%g)', n))
        v
      }
      if(n<maxsum) {
        v[maxsum] <- NA
        v[is.na(v)] <- ""
        v
      } else v
    })
    catSumm <- lapply(catSumm, function(v){
      cntnt <- paste(formatC(names(v), width=4), ":", formatC(v, width=4), sep='')
      cntnt[trimws(cntnt)==":"] <- ""
      cntnt
    })
    catSumm <- do.call('cbind', catSumm)  |> as.table() |> `rownames<-`(NULL)
    if(long) catSumm <- t(catSumm)
    results$Categorical <- catSumm
  }
  results
}

