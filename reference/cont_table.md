# Contingency Table

Creating a contingency table based on a `response(s) ~ predictor(s)`
formula.

## Usage

``` r
cont_table(x, formula, useNA = "no")
```

## Arguments

- x:

  A data frame

- formula:

  a `response(s) ~ predictor(s)` formula. If multiple variables are used
  as the response or predictor, `concat` is used to create a new
  variable by concatenating the values of all variables used.

- useNA:

  This is passed to [`table()`](https://rdrr.io/r/base/table.html) and
  can take these values: c("no", "ifany", "always"). The default value
  is "no".

## Value

a contingency table based on the `formula`: Rows representing
`response(s) ` and columns representing `predictor(s)`.

## See also

[`concat()`](https://manabdoli.github.io/du4tnr/reference/util.R.md)

## Examples

``` r
cont_table(data.frame(A=c('a', 'b', 'a', 'b'), B=c('x', 'y', 'y', 'x')), A~B)
#>    B
#> A   x y
#>   a 1 1
#>   b 1 1
cont_table(data.frame(A=c('a', 'b', 'a', 'b', 'a', 'b'),
   B=c('x', 'y', 'y', 'x', 'y', 'x'), C=c('f', 'g')), A~B+C)
#>    B+C
#> A   x-f x-g y-f y-g
#>   a   1   0   2   0
#>   b   0   2   0   1
```
