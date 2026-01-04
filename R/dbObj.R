#' @title dbObj: Datbase Object
#' @description
#' creates an object with a connection to a SQLite database file and a
#'  set of functions for recording and retrieving variables in the dataset.
#'
#' @param db_path The path to the sqlite database file.
#' @return `dbObj` reurns a `du4tnr` object which includes a sqlite_storage
#'  object and functions for updating and accessing it, including:
#'
#' * **add_var(vname, value, source_file = NULL, steps = NULL)**: adds a variable to
#'  the database and updates the source file and steps if supplied.
#' * **import_file(vname, file_path, steps = NULL, processor = NULL)**: imports
#'  a data file as a variable based on the file extension (default) or using the
#'  `processor` function. It adds steps if provided and uses the file as the source.
#' * **add_step(vname, steps)**: Documents steps for an existing variable.
#' * **list_files()**: Lists files imported to the database.
#' * **list_vars()**: List variables added to the database.
#' * **list_steps(vname=NULL)**: List steps for all variables (default) or a given
#'  variable.
#' * **get_var(vname)**: Returns the value of the variable in database.
#' * **var_exists(vname)**: Returns TRUE if the variable is added to the database.
#' * **del_var(vname)**: Removes the variable from the database
#' * **isOpen_db()**: Checkes if the database connection is valid.
#' * **disconnect_db()**: Disconnects (closes) the database connection.
#' * **close_db()**: an alias for `disconnect_db`, kept for compatibility.
#' * **reconnect_db()**: Reconnects the current `du4tnr` to its original database.
#' * **verify_open()**: reopens the db if the connection is dropped.
#'
#' Parameters used in these functions are:
#'
#' * **`vname`** the variable name
#' * **`value`** the value to be assigned to the variable
#' * **`source_file`** the name of the file associated with the variable
#' * **`file_path`** the full to the file to be imported as a variable or uploaded.
#' * **`steps`** a character vector used for documenting steps in creating the variable
#' * **`processor`** a function for customizing importing/uploading files
#'
#' @md
#' @export
dbObj <- function(db_path = "myVars.db"){
  obj <- NULL
  # Creating the object
  obj <- sqlite_storage(db_path)
  # Adding/Updating a variable
  add_var <- function(vname, value, source_file = NULL, steps = NULL){
    verify_open()
    obj <<- save_var(obj, vname, value, source_file, steps)
  }
  # Reads a dataset file into a variable
  import_file <- function(vname, file_path, steps = NULL, processor = NULL) {
    verify_open()
    obj <<- save_file_var(obj, vname, file_path, steps, processor)
  }
  # Documents Steps used in creating a variable
  add_step <- function(vname, steps){
    verify_open()
    obj <<- save_variable_steps(obj, vname, steps)
  }
  # List File imported
  ls_files <- function(){
    verify_open()
    list_files(obj)
  }
  # List Variables
  ls_vars <- function(){
    verify_open()
    list_vars(obj)
  }
  # List Steps
  ls_steps <- function(vname=NULL){
    verify_open()
    vNames <- ls_vars()
    if(is.null(vname)) vname <- vNames$name
    for(v in vname)
      print(get_provenance.sqlite_storage(obj, v))
  }
  # Gets the Load Variables to memory
  get_var <- function(vname) {
    verify_open()
    load_var(obj, vname)
  }
  # Check if a variable exists
  exists_var <- function(vname){
    verify_open()
    var_exists(obj, vname)
  }
  # Delete a variable
  del_var <- function(vname){
    verify_open()
    delete_var(obj, vname)
  }
  # Close DB
  discon_db <- function(){
    verify_open()
    obj <<- disconnect_db(obj)
  }
  # Is DB open?
  is_open <- function(){
    isOpen_db(obj)
  }
  # Initialize
  recon_db <- function(){
    obj <<- initialize_db(obj)
  }
  # Verify bd is open
  verify_open <- function(){
    if(!is_open()) recon_db()
  }
  #
  structure(list(getObj = function() obj,
                 add_var = add_var,
                 import_file = import_file,
                 add_step = add_step,
                 list_files = ls_files,
                 list_vars = ls_vars,
                 list_steps = ls_steps,
                 get_var = get_var,
                 var_exists = exists_var,
                 del_var = del_var,
                 isOpen_db = is_open,
                 disconnect_db = discon_db,
                 close_db = discon_db,
                 reconnect_db = recon_db),
            class = c('du4tnr', 'list'))
}

#' @export
print.du4tnr <- function(x, ...){
  print.sqlite_storage(x$getObj())
}
