# Cleaning a Dataset

Cleaning a Dataset

## Usage

``` r
cleanDS(x, cleanDF, Rename = FALSE, addCols = NULL)
```

## Arguments

- x:

  the dataset to be cleaned

- cleanDF:

  a data.frame that includes instructions for cleaning x; columns at
  least should include the following columns:

  - `Name`: Containing names of variables to be extracted,

  - `CurrentVal`: The list of valid values

  - `NewLevel`: Level names to be used for categorical variables

  - `NA_Vals`: The values or levels to be replaced with an NA.

  - `Rename`: Suggested new variable names, if needed. If `CurrentVal`
    is given, all values not listed in it will be replaced by NA.

- Rename:

  a logical value indicating whether the variable names should be
  replaced with values in the `Rename` column, if given.

- addCols:

  list of additional columns to be included without any change.

## Value

returns a dataset consisting of variables in `Name` (cleaned) and
`addCols` (copied).

## Examples

``` r
# Creating a sample cleanDF data frame for `mtccars` dataset:
 cleanMTcars <- data.frame(
    Name=c('vs', 'am', 'gear'),
    CurrentVal=c('0,1','0,1',''),
    NewLevel=c('V-shape,Straight','Manual,Automatic',''),
    NA_Vals=c('','','5'),
    Rename=c('Engine.Shape','Transmission', 'Forward.Gears'))
# Extracting Data
cleanDS(mtcars, cleanDF=cleanMTcars, Rename=TRUE) %>% tail(10)
#>                  Engine.Shape Transmission Forward.Gears
#> AMC Javelin           V-shape       Manual             3
#> Camaro Z28            V-shape       Manual             3
#> Pontiac Firebird      V-shape       Manual             3
#> Fiat X1-9            Straight    Automatic             4
#> Porsche 914-2         V-shape    Automatic            NA
#> Lotus Europa         Straight    Automatic            NA
#> Ford Pantera L        V-shape    Automatic            NA
#> Ferrari Dino          V-shape    Automatic            NA
#> Maserati Bora         V-shape    Automatic            NA
#> Volvo 142E           Straight    Automatic             4
cleanDS(mtcars, cleanDF=cleanMTcars, Rename=FALSE, addCols=colnames(mtcars)) %>% head(10)
#>                         vs        am gear  mpg cyl  disp  hp drat    wt  qsec
#> Mazda RX4          V-shape Automatic    4 21.0   6 160.0 110 3.90 2.620 16.46
#> Mazda RX4 Wag      V-shape Automatic    4 21.0   6 160.0 110 3.90 2.875 17.02
#> Datsun 710        Straight Automatic    4 22.8   4 108.0  93 3.85 2.320 18.61
#> Hornet 4 Drive    Straight    Manual    3 21.4   6 258.0 110 3.08 3.215 19.44
#> Hornet Sportabout  V-shape    Manual    3 18.7   8 360.0 175 3.15 3.440 17.02
#> Valiant           Straight    Manual    3 18.1   6 225.0 105 2.76 3.460 20.22
#> Duster 360         V-shape    Manual    3 14.3   8 360.0 245 3.21 3.570 15.84
#> Merc 240D         Straight    Manual    4 24.4   4 146.7  62 3.69 3.190 20.00
#> Merc 230          Straight    Manual    4 22.8   4 140.8  95 3.92 3.150 22.90
#> Merc 280          Straight    Manual    4 19.2   6 167.6 123 3.92 3.440 18.30
#>                   carb
#> Mazda RX4            4
#> Mazda RX4 Wag        4
#> Datsun 710           1
#> Hornet 4 Drive       1
#> Hornet Sportabout    2
#> Valiant              1
#> Duster 360           4
#> Merc 240D            2
#> Merc 230             2
#> Merc 280             4
```
