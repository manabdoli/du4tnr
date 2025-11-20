# Internal helper functions

Calculate file hash for integrity checking

A utility function that creates a new variable by joining the values of
a given list of variables.

## Usage

``` r
calculate_file_hash(file_path)

concat(x, formula)
```

## Arguments

- file_path:

  Path to the file

- x:

  a data frame where variables are taken from.

- formula:

  a response-less formula (~ followed by a `+`-separated list of
  variables)

## Value

MD5 hash of the file

A new variable by concatenating values of variables given by `formula`.

## Examples

``` r
concat(data.frame(A=c('a', 'b', 'a', 'b'), B=c('x', 'y', 'y', 'x')), ~A+B)
#> Error in concat(data.frame(A = c("a", "b", "a", "b"), B = c("x", "y",     "y", "x")), ~A + B): could not find function "concat"
```
