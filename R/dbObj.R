#' dbObj creates an object with a connection to a SQLite database file and a
#'  set of functions for recording and retrieving variables in the dataset.
#'
#' @param db_path The path to the sqlite database file.
#' @param vname the variable name
#' @param value the value to be assigned to the variable
#' @param source_file the name of the file associated with the variable
#' @param file_path the full to the file to be imported as a variable or uploaded.
#' @param steps a character vector used for documenting steps in creating the variable
#' @param processor a function for customizing importing/uploading files
#'
#' @return `dbObj` reurns a `du4tnr` object which includes a sqlite_storage
#'  object and functions for updating and accessing it, including:
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
#' * **close_db()**: Closes the database connection.
#' * **reconnect_db()**: Reconnects the current `du4tnr` to its original database.
#' @md
#' @export
dbObj <- function(dp_path = "myVars.db"){
  obj <- NULL
  # Creating the object
  obj <- sqlite_storage(dp_path)
  # Adding/Updating a variable
  add_var <- function(vname, value, source_file = NULL, steps = NULL){
    obj <<- save_var(obj, vname, value, source_file, steps)
  }
  # Reads a dataset file into a variable
  import_file <- function(vname, file_path, steps = NULL, processor = NULL) {
    obj <<- save_file_var(obj, vname, file_path, steps, processor)
  }
  # Documents Steps used in creating a variable
  add_step <- function(vname, steps){
    obj <<- save_variable_steps(obj, vname, steps)
  }
  # List File imported
  list_files <- function(){
    list_files.sqlite_storage(obj)
  }
  # List Variables
  list_vars <- function(){
    list_vars.sqlite_storage(obj)
  }
  # List Steps
  list_steps <- function(vname=NULL){
    vNames <- list_vars()
    if(is.null(vname)) vname <- vNames$name
    for(v in vname)
      print(get_provenance.sqlite_storage(obj, v))
  }
  # Gets the Load Variables to memory
  get_var <- function(vname) {
    load_var.sqlite_storage(obj, vname)
  }
  # Check if a variable exists
  var_exists <- function(vname){
    var_exists.sqlite_storage(obj, vname)
  }
  # Delete a variable
  del_var <- function(vname){
    delete_var.sqlite_storage(obj, vname)
  }
  # Close DB
  close_db <- function(){
    obj <<- close_db.sqlite_storage(obj)
  }
  # Initialize
  reconnect_db <- function(){
    obj <<- initialize_db.sqlite_storage(obj)
  }
  #
  structure(list(getObj = function() obj,
                 add_var = add_var,
                 import_file = import_file,
                 add_step = add_step,
                 list_files = list_files,
                 list_vars = list_vars,
                 list_steps = list_steps,
                 get_var = get_var,
                 var_exists = var_exists,
                 del_var = del_var,
                 close_db = close_db,
                 reconnect_db = reconnect_db),
            class = c('du4tnr', 'list'))
}

#' @export
print.du4tnr <- function(x, ...){
  print.sqlite_storage(x$getObj())
}
