# Summarizing Functions for `table` Object

Utility functions for adding Totals

`total_col` adds a column summary to a table/data.frame.

`total_row` adds a row summary to a table/data.frame.

`total_col.table` adds a column summary to a table.

`total_row.table` Adds a row summary to a table.

`total_col.matrix` adds a column summary to a matrix.

`total_col.matrix` adds a row summary to a matrix.

`total_col.table` adds a column summary to a data.frame.

`total_row.table` Adds a row summary to a table.

## Usage

``` r
total_col(x, na.rm = FALSE)

total_row(x, na.rm = FALSE)

# S3 method for class 'table'
total_col(x, na.rm = FALSE)

# S3 method for class 'table'
total_row(x, na.rm = FALSE)

# S3 method for class 'matrix'
total_col(x, na.rm = FALSE)

# S3 method for class 'matrix'
total_row(x, na.rm = FALSE)

# S3 method for class 'data.frame'
total_col(x, na.rm = FALSE)

# S3 method for class 'data.frame'
total_row(x, na.rm = FALSE)
```

## Arguments

- x:

  a table or data.frame object.

## Value

`total_col` returns a new object with an additional column, named
`Total` or `Total.Col`

`total_row` returns a new object with an additional row, named `Total`
or `Total.Row`
