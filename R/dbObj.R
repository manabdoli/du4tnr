#' dbObj a function that creates a sqlite-storage object.
#'
#' @export
dbObj <- function(dp_path = "myVars.db"){
  obj <- NULL
  # Creating the object
  obj <- sqlite_storage(dp_path)
  # Adding/Updating a variable
  add_var <- function(name, value, source_file = NULL, steps = NULL){
    obj <<- save_var(obj, name, value, source_file, steps)
  }
  # Adding/updating a file
  add_file <- function(name, file_path, steps = NULL, processor = NULL) {
    obj <<- save_file_var(obj, name, file_path, steps, processor)
  }
  # Adding Steps
  add_step <- function(obj, var_name, steps){
    obj <<- save_variable_steps(obj, var_name, steps)
  }
  # List File
  list_files <- function(){
    list_files.sqlite_storage(obj)
  }
  # List Variables
  list_vars <- function(){
    list_vars.sqlite_storage(obj)
  }
  # List Steps
  list_steps <- function(name=NULL){
    vNames <- list_vars()
    if(is.null(name)) name <- vNames$name
    for(v in name)
      print(get_provenance.sqlite_storage(obj, v))
  }
  # Load Variables
  load_var <- function(name) {
    load_var.sqlite_storage(obj, name)
  }
  # Check if a variable exists
  var_exists <- function(name){
    var_exists.sqlite_storage(obj, name)
  }
  # Delete a variable
  del_var <- function(name){
    delete_var.sqlite_storage(obj, name)
  }
  # Close DB
  close_db <- function(){
    obj <<- close_db.sqlite_storage(obj)
  }
  # Initialize
  reconnect <- function(){
    obj <<- initialize_db.sqlite_storage(obj)
  }
  #
  structure(list(getObj = function() obj,
                 add_var = add_var,
                 add_file = add_file,
                 add_step = add_step,
                 list_files = list_files,
                 list_vars = list_vars,
                 list_steps = list_steps,
                 load_var = load_var,
                 var_exists = var_exists,
                 del_var = del_var,
                 close_db = close_db,
                 reconnect = reconnect),
            class = c('du4tnr', 'list'))
}

#' @export
print.du4tnr <- function(x, ...){
  print.sqlite_storage(x$getObj())
}
