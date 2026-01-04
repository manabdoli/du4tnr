#' @rdname xvalid.R
#' @name xvalid
#' @title K-Fold Cross Validation and Accuracy Functions
#' @description
#' A set of functions to help performing cross-validation using different
#'  `method` (default=glm).
NULL

#' @rdname xvalid.R
#' @description
#' `mcrBin`: computing mis-classification rate for a probability prediction of
#'   a bi-level variable.
#' @param yhat the predicted value
#' @param y the actual value
#' @param cutoff the value used to convert a probability into a 0/1 output.
#'   The default cutoff value is 0.5.
#' @param FUN the function(s) used to calculate the summary of predictions. The
#'   default value is `mean`.
#' @return `mcrBin` returns the rate of mis-predictions at `cutoff` level.
#' @export
mcrBin <- function(yhat, y, cutoff=0.5, FUN=mean) {
  fns <- if(is.character(FUN)) FUN else as.character(substitute(FUN))
  if(fns[1]%in% c("c", "list")) fns <- fns[-1]
  fs <- sapply(fns, get)
#  if(length(fns)>1) fns <- fns[-1]
  prdAcc = as.numeric(y)==(1+(yhat>cutoff))
  sapply(1:length(fns), \(g) fs[[g]](1-prdAcc))
}

#' @rdname xvalid.R
#' @description
#' `misMul`: Mis-prediction for a multi-level factor response
#' @return `misMul` returns the mis-prediction rate in a multi-level categorical variable.
#' @export
misMul <- function(yhat, y, FUN=mean){
  fns <- if(is.character(FUN)) FUN else as.character(substitute(FUN))
  if(fns[1]%in% c("c", "list")) fns <- fns[-1]
  fs <- sapply(fns, get)
  prdAcc <- apply(yhat, 1, which.max)
  sapply(1:length(fns), \(g) fs[[g]](1-prdAcc))
}

#' @rdname xvalid.R
#' @description
#' `misMulOH`: returns the mis-predictions made for multiple-level response in one-hot format
#' @export
misMulOH <- function(yhat, y, FUN=mean){
  fns <- if(is.character(FUN)) FUN else as.character(substitute(FUN))
  if(fns[1]%in% c("c", "list")) fns <- fns[-1]
  fs <- sapply(fns, get)
  prds <- apply(yhat, 1, which.max)
  obsr <- if(is.factor(y)) as.integer(y) else
    if(!is.vector(y) & NCOL(y)>1) apply(y, 1, which.max) else
      y
  sapply(1:length(fns), \(g) fs[[g]](prds!=obsr))
}

#' @rdname xvalid.R
#' @description
#' `mse`: computes the mean squared deviation of the predictor from the actual value.
#' @returns `mse` returns the mean squared error (MSE) value for the predictions.
#' @export
mse <- function(yhat, y){
  mean((yhat-y)^2)
}

#' @rdname xvalid.R
#' @description
#' `cvGlm`: performing a K-fold cross-validation (using GLM method by default) on
#' `data` for a model defined by `formula`.
#' @param formula the model formula in form of y~f(X), where y is
#' the response and f(x) is a function of predictors in a vector X.
#' @param data the dataset containing the response y and predictors X.
#' @param K the number of folds to be used in the cross validation.
#' @param cost the function that measures the accuracy or loss. The default
#' value is `acc` function.
#' @param method the method that fits the data to the formula and returns
#'   a model object. The default value is `glm`.
#' @param predType is the type of prediction that is needed for the `cost` model
#' to work properly. The default value is 'response'.
#' @param na.rm a logical value; TRUE will remove NAs from `data` before processing.
#' @param ... other parameters; all are passed to `method` function.
#' @returns `cvGlm` returns an array of `K` calculated `cost` values computed for the train/test
#'   pairs generated from the data.
#' @importFrom stats as.formula glm predict
#' @export
cvGlm <- function(formula, data, K=10,
                  cost=mcrBin,
                  method=glm,
                  predType="response",
                  FUN=mean,
                  na.rm = TRUE,
                  ...){
  n <- dim(data)[1]
  if(K>n) stop('K cannot be larger than the data rows.')
  foldIdx <- ((1:n %% K)+1)[sample.int(n)]
  # Initiate
  costArr <- matrix(0, nrow = K, ncol = length(FUN))
  #
  fns <- if(is.character(FUN)) FUN else as.character(substitute(FUN))
  if(fns[1]%in% c("c", "list")) fns <- fns[-1]
  if(identical(cost, mse)) fcost = cost else
    fcost = function(yhat, y) cost(yhat, y, FUN=fns)
  # Eval formula, if needed (based on lm())
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data"), names(mf), 0L)
  mf <- mf[c(1L, m)]
  mf$drop.unused.levels <- TRUE
  mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
  #
  for(i in 1:K){
    trMdl <- method(formula=formula, data=data[foldIdx!=i,], ...)
    prds <- predict(trMdl, newdata=data[foldIdx==i,], type = predType)
    y <- mf[foldIdx==i, 1]
    if(na.rm){
      idx <- which(is.na(prds) | is.na(y))
      y <- y[-idx]
      prds <- prds[-idx]
    }
    costArr[i,] <- fcost(prds, y)
  }
  colnames(costArr) <- fns
  costArr
}
