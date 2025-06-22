#' Cleaning a Dataset
#'
#' @param x the dataset to be cleaned; the default dataset is `UDS`
#' @param cleanDF a data.frame that includes instructions for cleaning x;
#' columns at least should include the following columns:
#' * `Name`: Containing names of variables to be extracted,
#' * `CurrentVal`, `NewLevel`: The current values and their replacement levels,
#' * `NA_Vals`: The values or levels to be replaced with an NA.
#' * `Rename`: Suggested new variable names, if needed,
#' See the examples for a CleanDF sample.
#'
#' @param Rename a logical value indicating whether the variable names should
#'   be replaced with values in the `Rename` column, if given.
#' @param addCols list of columns to include as they are.
#'
#' @returns returns a selection of variables that have been cleaned with new
#'   levels and NA values.
#'
#' @examples
#' # Creating a sample cleanDF data frame:
#'  sampleCleanDF <- data.frame(
#'     Name=c('NACCID', 'NACCVNUM', 'NACCALZD', 'NACCBMI', 'NACCAGE', 'HISPANIC'),
#'     CurrentVal=c('','','8,0,1','','','0,1,9'),
#'     NewLevel=c('','','Normal,Dementia,Alzheimer','','','Non-Hispanic, Hispanic, 9'),
#'     NA_Vals=c('','','','"-4, 888.8"','','"9"'),
#'     Rename=c('','VisitNum', 'AlzD', 'BMI','AGE','Hispanic'))
#' # Extracting Data
#' cleanDS(x, cleanDF=sampleCleanDF, Rename=FALSE)
#'
#' @export
cleanDS <- function(x,
                    cleanDF=data.frame(
                      Name=c('NACCID', 'NACCVNUM', 'NACCALZD', 'NACCBMI', 'NACCAGE', 'HISPANIC'),
                      CurrentVal=c('','','8,0,1','','','0,1,9'),
                      NewLevel=c('','','Normal,Dementia,Alzheimer','','','Non-Hispanic, Hispanic, 9'),
                      NA_Vals=c('','','','"-4, 888.8"','','"9"'),
                      Rename=c('','VisitNum', 'AlzD', 'BMI','AGE','Hispanic')),
                    Rename=FALSE, addCols=NULL){
  # Select variables
  addCols <- setdiff(addCols, cleanDF$Name)
  y <- if(!is.null(addCols)) x[,addCols, drop=FALSE]
  x <- x[, cleanDF$Name]
  # Parse Existing Values
  vals <- cleanDF$CurrentVal %>%
    # Remove enclosing quotations ""
    sapply(\(v) sub("^[\"|']", "", v)) %>%
    sapply(\(v) gsub("[\"|']$", "", v)) %>%
    # Removing White Spaces
    strsplit(split = ",") %>% lapply(trimws)

  vals <- lapply(1:length(vals), function(k)
    switch(class(x[[k]]),
           integer = as.integer(vals[[k]]),
           numeric = as.numeric(vals[[k]]),
           vals[[k]])
  )
  valsLen <- sapply(vals, length)
  valsLen[is.na(vals)] <- 0 # exclude NAs

  # Parse New Values
  new_vals <- cleanDF$NewLevel %>%
    # Remove enclosing quotations ""
    sapply(\(v) sub("^[\"|']", "", v)) %>%
    sapply(\(v) gsub("[\"|']$", "", v)) %>%
    # Removing White Spaces
    strsplit(split = ",") %>% lapply(trimws)

  newValsLen <- sapply(new_vals, length)
  newValsLen[is.na(new_vals)] <- 0 # exclude NAs

  ## Check levels
  misMatch <- which(newValsLen!=valsLen)
  if(length(misMatch)>0) {
    cat('Mismatched levels:\n', cleanDF$Name[misMatch], '\n')
    stop('Mismatched levels was found!')
  }
  # Create new factors as needed
  sapply(which(valsLen>0), function(k){
    x[[cleanDF$Name[k]]] <<- factor(x[[cleanDF$Name[k]]],
                                        vals[[k]], trimws(new_vals[[k]]))
  })
  # Parse NA Values
  na_vals <- strsplit(gsub('"','',cleanDF$NA_Vals), split = ',')
  xClass <- sapply(x, class)
  na_vals <- lapply(1:length(na_vals), function(k)
    switch(xClass[k],
           integer = as.integer(na_vals[[k]]),
           numeric = as.numeric(na_vals[[k]]),
           trimws(na_vals[[k]]))
  )
  naLen <- sapply(na_vals, length)
  # Set NAs for non-factor columns, as needed
  sapply(which(naLen>0 & xClass!='factor'), function(k){
    x[[cleanDF$Name[k]]][which(x[[cleanDF$Name[k]]] %in% na_vals[[k]])] <<- NA
  })
  # Set NAs for factor columns, as needed
  sapply(which(naLen>0 & xClass=='factor'), function(k){
    levels(x[[cleanDF$Name[k]]])[levels(x[[cleanDF$Name[k]]])%in% na_vals[[k]]] <<- NA
  })
  # Use new names if needed
  if(Rename){
    idx <- which(nchar(cleanDF$Rename)==0)
    if(length(idx)>0)
      cleanDF$Rename[idx] <- cleanDF$Name[idx]
    colnames(x) <- cleanDF$Rename
  }
  if(is.null(y)) x else cbind(x, y)
}

