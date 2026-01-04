#' Cleaning a Dataset
#'
#' @param x the dataset to be cleaned
#' @param cleanDF a data.frame that includes instructions for cleaning x;
#' columns at least should include the following columns:
#' * `Name`: Containing names of variables to be extracted,
#' * `CurrentVal`: The list of valid values
#' * `NewLevel`: Level names to be used for categorical variables
#' * `NA_Vals`: The values or levels to be replaced with an NA.
#' * `Rename`: Suggested new variable names, if needed.
#' If `CurrentVal` is given, all values not listed in it will be replaced by NA.
#'
#' @param Rename a logical value indicating whether the variable names should
#'   be replaced with values in the `Rename` column, if given.
#' @param addCols list of additional columns to be included without any change.
#'
#' @returns returns a dataset consisting of variables in `Name` (cleaned) and `addCols` (copied).
#'
#' @examples
#' # Creating a sample cleanDF data frame for `mtccars` dataset:
#'  cleanMTcars <- data.frame(
#'     Name=c('vs', 'am', 'gear'),
#'     CurrentVal=c('0,1','0,1',''),
#'     NewLevel=c('V-shape,Straight','Manual,Automatic',''),
#'     NA_Vals=c('','','5'),
#'     Rename=c('Engine.Shape','Transmission', 'Forward.Gears'))
#' # Extracting Data
#' cleanDS(mtcars, cleanDF=cleanMTcars, Rename=TRUE) %>% tail(10)
#' cleanDS(mtcars, cleanDF=cleanMTcars, Rename=FALSE, addCols=colnames(mtcars)) %>% head(10)
#'
#' @export
cleanDS <- function(x, cleanDF, Rename=FALSE, addCols=NULL){
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

