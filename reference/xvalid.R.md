# K-Fold Cross Validation and Accuracy Functions

A set of functions to help performing cross-validation using different
`method` (default=glm).

`mcrBin`: computing mis-classification rate for a probability prediction
of a bi-level variable.

`misMul`: Mis-prediction for a multi-level factor response

`misMulOH`: returns the mis-predictions made for multiple-level response
in one-hot format

`mse`: computes the mean squared deviation of the predictor from the
actual value.

`cvGlm`: performing a K-fold cross-validation (using GLM method by
default) on `data` for a model defined by `formula`.

## Usage

``` r
mcrBin(yhat, y, cutoff = 0.5, FUN = mean)

misMul(yhat, y, FUN = mean)

misMulOH(yhat, y, FUN = mean)

mse(yhat, y)

cvGlm(
  formula,
  data,
  K = 10,
  cost = accBin,
  method = glm,
  predType = "response",
  FUN = mean,
  na.rm = TRUE,
  ...
)
```

## Arguments

- yhat:

  the predicted value

- y:

  the actual value

- cutoff:

  the value used to convert a probability into a 0/1 output. The default
  cutoff value is 0.5.

- FUN:

  the function(s) used to calculate the summary of predictions. The
  default value is `mean`.

- formula:

  the model formula in form of y~f(X), where y is the response and f(x)
  is a function of predictors in a vector X.

- data:

  the dataset containing the response y and predictors X.

- K:

  the number of folds to be used in the cross validation.

- cost:

  the function that measures the accuracy or loss. The default value is
  `acc` function.

- method:

  the method that fits the data to the formula and returns a model
  object. The default value is `glm`.

- predType:

  is the type of prediction that is needed for the `cost` model to work
  properly. The default value is 'response'.

- ...:

  other parameters; all are passed to `method` function.

## Value

`mcrBin` returns the rate of mis-predictions at `cutoff` level.

`misMul` returns the mis-prediction rate in a multi-level categorical
variable.

`mse` returns the mean squared error (MSE) value for the predictions.

`cvGlm` returns an array of `K` calculated `cost` values computed for
the train/test pairs generated from the data.
