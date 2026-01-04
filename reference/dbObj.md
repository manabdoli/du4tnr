# dbObj creates an object with a connection to a SQLite database file and a set of functions for recording and retrieving variables in the dataset.

dbObj creates an object with a connection to a SQLite database file and
a set of functions for recording and retrieving variables in the
dataset.

## Usage

``` r
dbObj(db_path = "myVars.db")
```

## Arguments

- db_path:

  The path to the sqlite database file.

## Value

`dbObj` reurns a `du4tnr` object which includes a sqlite_storage object
and functions for updating and accessing it, including:

- **add_var(vname, value, source_file = NULL, steps = NULL)**: adds a
  variable to the database and updates the source file and steps if
  supplied.

- **import_file(vname, file_path, steps = NULL, processor = NULL)**:
  imports a data file as a variable based on the file extension
  (default) or using the `processor` function. It adds steps if provided
  and uses the file as the source.

- **add_step(vname, steps)**: Documents steps for an existing variable.

- **list_files()**: Lists files imported to the database.

- **list_vars()**: List variables added to the database.

- **list_steps(vname=NULL)**: List steps for all variables (default) or
  a given variable.

- **get_var(vname)**: Returns the value of the variable in database.

- **var_exists(vname)**: Returns TRUE if the variable is added to the
  database.

- **del_var(vname)**: Removes the variable from the database

- **isOpen_db()**: Checkes if the database connection is valid.

- **disconnect_db()**: Disconnects (closes) the database connection.

- **close_db()**: an alias for `disconnect_db`, kept for compatibility.

- **reconnect_db()**: Reconnects the current `du4tnr` to its original
  database.

- **verify_open()**: reopens the db if the connection is dropped.

Parameters used in these functions are:

- **`vname`** the variable name

- **`value`** the value to be assigned to the variable

- **`source_file`** the name of the file associated with the variable

- **`file_path`** the full to the file to be imported as a variable or
  uploaded.

- **`steps`** a character vector used for documenting steps in creating
  the variable

- **`processor`** a function for customizing importing/uploading files
