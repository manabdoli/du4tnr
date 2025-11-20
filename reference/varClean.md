# Variable cleaning functions

A set of functions for cleaning variables in a dataset.

`setNAs` is used to set a list of given values as `NA`.

## Usage

``` r
setNAs(x, naVals = NA)
```

## Arguments

- x:

  a vector to be updated with some new `NA`'s.

- naVals:

  a vector of values that should be considered as `NA`. The default
  value is `NA` (no new NA's will be introduced).

## Value

a modified version of `x` where values in `naVals` are replaced with
`NA`'s.
