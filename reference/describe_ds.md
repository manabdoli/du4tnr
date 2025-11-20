# Describe a Dataset

Describe a Dataset

## Usage

``` r
describe_ds(x, maxLevels = 7, var2row = FALSE)
```

## Arguments

- x:

  a dataset

- maxLevels:

  the maximum number of levels for categorical variables (default is 7)

- var2row:

  if TRUE, each variable is summarized as a row; default is FALSE, where
  each column represents the summary of a variable

## Value

A list of at most two tables (Numerical and Categorical) containing the
summary information for variables of each type.
