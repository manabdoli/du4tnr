#' @title Generating Summary Tables for levels of a categorical response.
#' @description
#' This function returns summaries of numerical and categorical predictors
#'   based on the levels of a categorical response variable.
#' @importFrom stats sd
#' @importFrom dplyr any_of
#' @importFrom rlang .data
#' @param x a data.frame to be summarized
#' @param response a character string containing the name of the categorical response variable.
#' @param maxsum a numerical value (default 7) determining the number of summary details generated.
#'   For numerical predictors, this is passed to `summary()`, and for categorical variables,
#'   this is the maximum number of levels shown in the output.
#' @return `briefSummary` returns a list containing two objects, one a summary table
#' for the numerical variables (called `Numerical`) and the other a list of tables (called `Categorical`),
#'  each table summarizing one categorical predictor.
#' @export
briefSummary <- function(x, response, maxsum=7){
  numTable <- NULL
  if(any(sapply(x, is.numeric))){
    meansDF <- x %>% group_by(pick(response)) %>%
      summarise(across(where(is.numeric), mean, na.rm=TRUE)) %>%
      pivot_longer(-all_of(response), names_to = 'Variable', values_to = 'Mean')
    sdsDF <- x %>% group_by(pick(response)) %>%
      summarise(across(where(is.numeric), sd, na.rm=TRUE)) %>%
      pivot_longer(-all_of(response), names_to = 'Variable', values_to = 'SD')
    numTable <-
      meansDF %>% left_join(sdsDF, by = c(response, 'Variable')) %>%
      mutate(MeanSD=sprintf('%s (%s)',
                            formatC(.data$Mean, 4, format = 'g'),
                            formatC(.data$SD, 4, format = 'g'))) %>%
      pivot_wider(id_cols = .data$Variable,
                  names_from = all_of(response),
                  values_from = all_of('MeanSD'))
  }
  catTable <- NULL
  if(any(sapply(x, is.factor))){
    catSumm <-
      x %>% dplyr::select(all_of(response), where(is.factor)) %>%
      lapply(\(v) data.frame(x[[response]], v) %>% table(dnn=c(response, '')))
    catSumm <- catSumm[-which(names(catSumm)==response)]
    catNames <- names(catSumm)
    catSumm <- lapply(
      names(catSumm),
      \(v) {
        Count <- rowSums(catSumm[[v]], na.rm = TRUE)
        Prop <- catSumm[[v]]
        for(i in 1:dim(Prop)[1]) Prop[i,] <- round(Prop[i,]/Count[i]*100,1)
        df <- data.frame(Prop, Count=Count, check.names = FALSE, row.names = NULL)
        colnames(df)[2] <- v
        df %>% pivot_wider(
          id_cols = any_of(c(response, 'Count')),
          names_from = all_of(v), values_from = all_of('Freq'))
      }
    )
    names(catSumm) <- catNames
    catTable <- catSumm
  }

  list(Numerical=numTable, Categorical=catTable)
}
