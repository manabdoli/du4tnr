# Generating Summary Tables for levels of a categorical response.

This function returns summaries of numerical and categorical predictors
based on the levels of a categorical response variable.

## Usage

``` r
briefSummary(x, response, maxsum = 7)
```

## Arguments

- x:

  a data.frame to be summarized

- response:

  a character string containing the name of the categorical response
  variable.

- maxsum:

  a numerical value (default 7) determining the number of summary
  details generated. For numerical predictors, this is passed to
  [`summary()`](https://rdrr.io/r/base/summary.html), and for
  categorical variables, this is the maximum number of levels shown in
  the output.

## Value

`briefSummary` returns a list containing two objects, one a summary
table for the numerical variables (called `Numerical`) and the other a
list of tables (called `Categorical`), each table summarizing one
categorical predictor.
