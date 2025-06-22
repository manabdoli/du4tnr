#' @name which_ds
#' @rdname which_ds
#' @title Find the dataset containing given column names
#'
#' @param columnName a vector of variable names to be looked up is different datasets.
#' @param dss is a list of all datasets where variable names will be searched for.
#' @return is a named, logical array that determines which dataset includes
#'   variables listed in `columnName`.
NULL

#' @rdname which_ds
#' @description
#' A helper function for looking up one variable name in a list of datasets.
whichds <- function(columnName=NULL,
                     dss=list(UDS=UDS, MRI=mri_data,
                              PET=pet_data, BIOM=biomarker_data)){
  sapply(dss,
         function(l) any(columnName %in% names(l)))
}

#' @export which_ds
which_ds <- function(columnName=NULL,
                     dss=list(UDS=UDS, MRI=mri_data,
                              PET=pet_data, BIOM=biomarker_data)){
  if(length(columnName)==1)
    whichds(columnName = columnName, dss = dss) else {
      vzd_wds <- Vectorize(which_ds, "columnName", SIMPLIFY = F)
      vzd_wds(columnName = columnName, dss = dss) |>
        do.call(what="rbind")
    }
}

