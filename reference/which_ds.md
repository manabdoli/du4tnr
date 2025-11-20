# Searching a column name in datasets (data frames)

A helper function for looking up one variable name in a list of
datasets.

Looking up the name of several variables in a list of datasets.

## Usage

``` r
whichds(columnName = NULL, ...)

which_ds(columnName = NULL, ...)
```

## Arguments

- columnName:

  a character vector of name of variables of interest.

- ...:

  a comma separated list of datasets

- dss:

  is a list of all datasets where variable names will be searched for.

## Value

is a named, logical array that determines which dataset includes
variables listed in `columnName`.
