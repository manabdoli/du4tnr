# du4tnr

``` r
library(du4tnr)
```

## Idea

Through working with different cohort of student researchers in NAARE
program at CSUF, I recognized that while leaving students to do data
cleaning and pre-processing is a valuable part of their training, but it
becomes a nightmare when it comes to validating their final work
products.

To maintain some consistency and make their preprocessing choices
transparent, I created an R-package and named it `NACCdata`, after
[NACC](https://naccdata.org/), which is the organization that provided
us with the data. Since I did not have the permission to share the data,
I created a new, data-less package: `du4tnr` (Data Utility for
Transparency and Reproduciblity). I also added a new feature for
recording datasets/variables in a SQLite database to facilitate sharing
verified datasets among a large group of collaborators.

## Features

### `cleanDS`: Clean Dataset using instructions in a Data.Fream

The main feature in the original package was to reduce selection,
renaming, setting missing values to NA, and redefining levels of
categorical variables. This was an important step as `NACC` data had a
large number of variables (1936) and it used numerical values for
presenting categorical variables and for all missing values.

Let’s use `mtcars` as an example:

- `cleanMTcars` contains the instruction for cleaning `mtcars`:
  - The first two rows show how categorical variables are turned into
    factors with meaningful levels.
  - The last row shows how records with `gear==5` are considered as
    `NA`.

``` r
cleanMTcars <- data.frame(
  Name=c('vs', 'am', 'gear'),
  CurrentVal=c('0,1','0,1',''),
  NewLevel=c('V-shape,Straight','Manual,Automatic',''),
  NA_Vals=c('','','5'),
  Rename=c('Engine.Shape','Transmission', 'Forward.Gears'))
cleanMTcars
#>   Name CurrentVal         NewLevel NA_Vals        Rename
#> 1   vs        0,1 V-shape,Straight          Engine.Shape
#> 2   am        0,1 Manual,Automatic          Transmission
#> 3 gear                                   5 Forward.Gears
```

- `cleanDS` uses the `cleanMTcars` to select, clean and rename three
  variables:

``` r
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
```

- `CleanDS` can pass through other variables using `addCols` parameter,
  and can skip renaming if needed (`Rename=FALSE`):

``` r
processedMTcars <- cleanDS(mtcars, cleanDF=cleanMTcars,
                         Rename=FALSE, addCols=colnames(mtcars))

processedMTcars %>% head(10)
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

### SQLite Storage

This feature is added to create a repository that can be shared with
other collaborator and save time in recreating commonly used datasets.
It can also increase the integrity of the data compared to the case that
CSV files are shared between colleagues.

Let’s start from scracth:

``` r
dbPath <- 'myProject.db'
res <- NULL
if(file.exists(dbPath)){
  if(!file.remove(dbPath)){
    closeAllConnections()
    unlink(dbPath, force = TRUE)
  }
}
if(file.exists(dbPath)) stop('Cannot remove ', dbPath, '!\n', 
                             'Close it by `db_close()` or restart R.')
```

``` r
# Create a new SQLite database or open an existing one:
projDB <- dbObj(db_path = dbPath)
print(projDB)
#> SQLite Variable Storage Object
#> Database path: myProject.db 
#> Connection status: Open 
#> Stored items: 0 
#> Registered files: 0
```

``` r
# Add mtcars, cleanMTcars, and processedMTcars to the database
projDB$add_var(vname = 'MTCars0', value = mtcars)
#> Saved variable: MTCars0
projDB$add_var(vname = 'cleaningInstructions', value = cleanMTcars)
#> Saved variable: cleaningInstructions
projDB$add_var(vname = 'MTcars-Processed', value = processedMTcars, 
               steps = c("rename and relabel `vs` and `am`", "set `gear==5` to `NA`"))
#> Saved variable: MTcars-Processed
print(projDB)
#> SQLite Variable Storage Object
#> Database path: myProject.db 
#> Connection status: Open 
#> Stored items: 3 
#> Registered files: 0 
#> 
#> items:
#>                   name       type source_file                 created_at
#> 1              MTCars0 data.frame        <NA> 2026-01-04 03:39:25.749745
#> 2     MTcars-Processed data.frame        <NA> 2026-01-04 03:39:25.753969
#> 3 cleaningInstructions data.frame        <NA>   2026-01-04 03:39:25.7522
#>                   updated_at
#> 1 2026-01-04 03:39:25.749745
#> 2 2026-01-04 03:39:25.753969
#> 3   2026-01-04 03:39:25.7522
```

Let’s close the database:

``` r
# Close the database
projDB$close_db()
#> Database connection closed
print(projDB)
#> SQLite Variable Storage Object
#> Database path: myProject.db 
#> Connection status: Closed
```

Let’s reuse it:

``` r
projDB$reconnect_db() # No need to reintroduce the path
print(projDB$list_vars()) # Just listing variables
#>                   name       type source_file                 created_at
#> 1              MTCars0 data.frame        <NA> 2026-01-04 03:39:25.749745
#> 2     MTcars-Processed data.frame        <NA> 2026-01-04 03:39:25.753969
#> 3 cleaningInstructions data.frame        <NA>   2026-01-04 03:39:25.7522
#>                   updated_at
#> 1 2026-01-04 03:39:25.749745
#> 2 2026-01-04 03:39:25.753969
#> 3   2026-01-04 03:39:25.7522
```

Now, let’s access the database using a second object:

``` r
myDB <- dbObj(db_path = dbPath)
print(myDB$list_vars())
#>                   name       type source_file                 created_at
#> 1              MTCars0 data.frame        <NA> 2026-01-04 03:39:25.749745
#> 2     MTcars-Processed data.frame        <NA> 2026-01-04 03:39:25.753969
#> 3 cleaningInstructions data.frame        <NA>   2026-01-04 03:39:25.7522
#>                   updated_at
#> 1 2026-01-04 03:39:25.749745
#> 2 2026-01-04 03:39:25.753969
#> 3   2026-01-04 03:39:25.7522
```

And let’s create a source file to remove NAs and add the result as a new
variable:

``` r
# Create an R Script
fConn <- file("cleanMtcars.R")
writeLines(con = fConn, text = '
# Removing NAs from processedMTcars
cleansedMTcatrs <- processedMTcars[complete.cases(processedMTcars),]
')
close(fConn)
# Run the R Script
source("cleanMtcars.R")
# Add the new variable and its source file to the dataset
myDB$add_var(vname = "MTcars-cleaned", cleansedMTcatrs,
             steps = "Remove NAs")
#> Saved variable: MTcars-cleaned
print(myDB)
#> SQLite Variable Storage Object
#> Database path: myProject.db 
#> Connection status: Open 
#> Stored items: 4 
#> Registered files: 0 
#> 
#> items:
#>                   name       type source_file                 created_at
#> 1              MTCars0 data.frame        <NA> 2026-01-04 03:39:25.749745
#> 2     MTcars-Processed data.frame        <NA> 2026-01-04 03:39:25.753969
#> 3       MTcars-cleaned data.frame        <NA> 2026-01-04 03:39:26.039446
#> 4 cleaningInstructions data.frame        <NA>   2026-01-04 03:39:25.7522
#>                   updated_at
#> 1 2026-01-04 03:39:25.749745
#> 2 2026-01-04 03:39:25.753969
#> 3 2026-01-04 03:39:26.039446
#> 4   2026-01-04 03:39:25.7522
```

Let’s check the first instance of the database:

``` r
projDB$list_vars()
#>                   name       type source_file                 created_at
#> 1              MTCars0 data.frame        <NA> 2026-01-04 03:39:25.749745
#> 2     MTcars-Processed data.frame        <NA> 2026-01-04 03:39:25.753969
#> 3       MTcars-cleaned data.frame        <NA> 2026-01-04 03:39:26.039446
#> 4 cleaningInstructions data.frame        <NA>   2026-01-04 03:39:25.7522
#>                   updated_at
#> 1 2026-01-04 03:39:25.749745
#> 2 2026-01-04 03:39:25.753969
#> 3 2026-01-04 03:39:26.039446
#> 4   2026-01-04 03:39:25.7522
```

``` r
myDB$close_db()
#> Database connection closed
```

### Descriptive Functions

The package offers a few simple functions that we have found useful in
summarizing and describing data.

#### `con_table`: Creating contingency tables

The following creates a contingency table between `vs` and `gear`:

``` r
x <- projDB$get_var("MTcars-cleaned")
cont_table(x, vs~gear)
#>           gear
#> vs          3  4
#>   V-shape  12  2
#>   Straight  3 10
```

`con_table()` can use more than one variable for rows or columns:

``` r
cont_table(x, vs~gear+am)
#>           gear+am
#> vs         3-Manual 4-Automatic 4-Manual
#>   V-shape        12           2        0
#>   Straight        3           6        4
```

This function can also count NAs, when needed:

``` r
y <- projDB$get_var("MTcars-Processed")
cont_table(y, vs+am~gear, useNA = 'ifany')
#>                     gear
#> vs+am                 3  4 <NA>
#>   Straight-Automatic  0  6    1
#>   Straight-Manual     3  4    0
#>   V-shape-Automatic   0  2    4
#>   V-shape-Manual     12  0    0
```

#### `total_col()` and `total_row()`: Adding Marginal Sums to Tables and Data.frames

These functions can add total column and row to a count table and
data.frame:

``` r
cont_table(y, vs+am~gear, useNA = 'ifany') %>% 
  total_row() %>% total_col()
#>                     3  4 <NA> Total.Col
#> Straight-Automatic  0  6    1         7
#> Straight-Manual     3  4    0         7
#> V-shape-Automatic   0  2    4         6
#> V-shape-Manual     12  0    0        12
#> Total.Row          15 12    5        32
```

``` r
y %>% total_row() %>% tail(10)
#>                        vs        am gear   mpg cyl   disp   hp   drat      wt
#> Camaro Z28        V-shape    Manual    3  13.3   8  350.0  245   3.73   3.840
#> Pontiac Firebird  V-shape    Manual    3  19.2   8  400.0  175   3.08   3.845
#> Fiat X1-9        Straight Automatic    4  27.3   4   79.0   66   4.08   1.935
#> Porsche 914-2     V-shape Automatic   NA  26.0   4  120.3   91   4.43   2.140
#> Lotus Europa     Straight Automatic   NA  30.4   4   95.1  113   3.77   1.513
#> Ford Pantera L    V-shape Automatic   NA  15.8   8  351.0  264   4.22   3.170
#> Ferrari Dino      V-shape Automatic   NA  19.7   6  145.0  175   3.62   2.770
#> Maserati Bora     V-shape Automatic   NA  15.0   8  301.0  335   3.54   3.570
#> Volvo 142E       Straight Automatic    4  21.4   4  121.0  109   4.11   2.780
#> Total                <NA>      <NA>   NA 642.9 198 7383.1 4694 115.09 102.952
#>                    qsec carb
#> Camaro Z28        15.41    4
#> Pontiac Firebird  17.05    2
#> Fiat X1-9         18.90    1
#> Porsche 914-2     16.70    2
#> Lotus Europa      16.90    2
#> Ford Pantera L    14.50    4
#> Ferrari Dino      15.50    6
#> Maserati Bora     14.60    8
#> Volvo 142E        18.60    2
#> Total            571.16   90
```

#### `describe_ds()`: Generates a Summary of Variables

This function creates a summary of each variable, including the counts
of NAs, if any.

``` r
describe_ds(y, maxLevels = 3, var2row = FALSE)
#> $Numerical
#>       gear            mpg             cyl             disp      
#>  Min.   :3.000   Min.   :10.40   Min.   :4.000   Min.   : 71.1  
#>  1st Qu.:3.000   1st Qu.:15.43   1st Qu.:4.000   1st Qu.:120.8  
#>  Median :3.000   Median :19.20   Median :6.000   Median :196.3  
#>  Mean   :3.444   Mean   :20.09   Mean   :6.188   Mean   :230.7  
#>  3rd Qu.:4.000   3rd Qu.:22.80   3rd Qu.:8.000   3rd Qu.:326.0  
#>  Max.   :4.000   Max.   :33.90   Max.   :8.000   Max.   :472.0  
#>  NA's   :5                                                      
#>        hp             drat             wt             qsec      
#>  Min.   : 52.0   Min.   :2.760   Min.   :1.513   Min.   :14.50  
#>  1st Qu.: 96.5   1st Qu.:3.080   1st Qu.:2.581   1st Qu.:16.89  
#>  Median :123.0   Median :3.695   Median :3.325   Median :17.71  
#>  Mean   :146.7   Mean   :3.597   Mean   :3.217   Mean   :17.85  
#>  3rd Qu.:180.0   3rd Qu.:3.920   3rd Qu.:3.610   3rd Qu.:18.90  
#>  Max.   :335.0   Max.   :4.930   Max.   :5.424   Max.   :22.90  
#>                                                                 
#>       carb      
#>  Min.   :1.000  
#>  1st Qu.:2.000  
#>  Median :2.000  
#>  Mean   :2.812  
#>  3rd Qu.:4.000  
#>  Max.   :8.000  
#>                 
#> 
#> $Categorical
#>      vs            am            
#> [1,]  V-shape:  18    Manual:  19
#> [2,] Straight:  14 Automatic:  13
#> [3,]
```

#### `which_ds()`: Searching datasets for variables

When dealing with multiple large datasets, we can use this functions to
see which one has the variable we have in mind:

``` r
which_ds(c('Species', 'am', 'mpg', 'gpm'), 
         iris=iris, x=x, y=y)
#>          iris     x     y
#> Species  TRUE FALSE FALSE
#> am      FALSE  TRUE  TRUE
#> mpg     FALSE  TRUE  TRUE
#> gpm     FALSE FALSE FALSE
```

A more visible format:

``` r
which_ds(c('Species', 'am', 'mpg', 'gpm'), 
         iris=iris, x=x, y=y)+0
#>         iris x y
#> Species    1 0 0
#> am         0 1 1
#> mpg        0 1 1
#> gpm        0 0 0
```

### Future Development

- Adding `respSummary` to summarize variables for different levels of a
  categorical response.

- Cross-Validation with different cost functions.
