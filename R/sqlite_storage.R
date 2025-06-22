#' Enhanced SQLite Variable Storage S3 Object with File Support
#' Requires: RSQLite, DBI packages
#'
#' Generated mainly by Claude Sonnet 4
#'
#' Create SQLite Variable Storage Object
#'
#' Creates an S3 object that provides persistent storage for R variables
#' using SQLite database backend with file support and provenance tracking.
#'
#' @param db_path Character string specifying the path to the SQLite database file.
#'   Default is "variables.db" in the current working directory.
#' @return An object of class "sqlite_storage"
#' #$export
#' @examples
#' \dontrun{
#' # Create storage object
#' storage <- sqlite_storage("my_vars.db")
#'
#' # Save and load variables with provenance
#' save_var(storage, "x", c(1, 2, 3), source_file = "analysis.R",
#'          steps = "Created test vector")
#' x <- load_var(storage, "x")
#'
#' # Store file-based variables
#' save_file_var(storage, "data", "mydata.csv",
#'               steps = c("Load CSV", "Clean data", "Remove NAs"))
#'
#' # Clean up
#' close_db(storage)
#' }
sqlite_storage <- function(db_path = "variables.db") {
  obj <- list(
    db_path = db_path,
    conn = NULL
  )

  class(obj) <- "sqlite_storage"
  obj <- initialize_db(obj)
  return(obj)
}

#' Initialize Database Connection
#'
#' @param obj An object of class "sqlite_storage"
#' #$export
initialize_db <- function(obj) {
  UseMethod("initialize_db")
}

#' #$export
initialize_db.sqlite_storage <- function(obj) {
  obj$conn <- DBI::dbConnect(RSQLite::SQLite(), obj$db_path)

  # Create variables table
  DBI::dbExecute(obj$conn, "
    CREATE TABLE IF NOT EXISTS variables (
      name TEXT PRIMARY KEY,
      value BLOB,
      type TEXT,
      source_file TEXT,
      file_hash TEXT,
      steps TEXT,
      created_at TEXT,
      updated_at TEXT
    )
  ")

  # Create files table for file metadata
  DBI::dbExecute(obj$conn, "
    CREATE TABLE IF NOT EXISTS files (
      file_path TEXT PRIMARY KEY,
      file_hash TEXT,
      file_size INTEGER,
      file_modified TEXT,
      file_type TEXT,
      registered_at TEXT
    )
  ")

  # Create steps table for detailed provenance
  DBI::dbExecute(obj$conn, "
    CREATE TABLE IF NOT EXISTS variable_steps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      variable_name TEXT,
      step_order INTEGER,
      step_description TEXT,
      step_timestamp TEXT,
      FOREIGN KEY (variable_name) REFERENCES variables (name)
    )
  ")

  invisible(obj)
}

#' Calculate file hash for integrity checking
#'
#' @param file_path Path to the file
#' @return MD5 hash of the file
calculate_file_hash <- function(file_path) {
  if (!file.exists(file_path)) {
    return(NA_character_)
  }
  digest::digest(file_path, file = TRUE, algo = "md5")
}

#' Register a file in the database
#'
#' @param obj An object of class "sqlite_storage"
#' @param file_path Path to the file to register
#' #$export
register_file <- function(obj, file_path) {
  UseMethod("register_file")
}

#' #$export
register_file.sqlite_storage <- function(obj, file_path) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  file_info <- file.info(file_path)
  file_hash <- calculate_file_hash(file_path)
  file_ext <- tools::file_ext(file_path)

  # Check if file is already registered
  existing <- DBI::dbGetQuery(obj$conn,
                              "SELECT file_path, file_hash FROM files WHERE file_path = ?",
                              params = list(file_path)
  )

  if (nrow(existing) > 0) {
    if (existing$file_hash != file_hash) {
      # File has changed, update record
      DBI::dbExecute(obj$conn,
                     "UPDATE files SET file_hash = ?, file_size = ?, file_modified = ?, registered_at = ?
         WHERE file_path = ?",
                     params = list(file_hash, file_info$size, as.character(file_info$mtime),
                                   as.character(Sys.time()), file_path)
      )
      message("Updated file registration: ", file_path)
    }
  } else {
    # Register new file
    DBI::dbExecute(obj$conn,
                   "INSERT INTO files (file_path, file_hash, file_size, file_modified, file_type, registered_at)
       VALUES (?, ?, ?, ?, ?, ?)",
                   params = list(file_path, file_hash, file_info$size, as.character(file_info$mtime),
                                 file_ext, as.character(Sys.time()))
    )
    message("Registered file: ", file_path)
  }

  invisible(obj)
}

#' Save Variable to Database with Provenance
#'
#' @param obj An object of class "sqlite_storage"
#' @param name Character string, name of the variable
#' @param value Any R object to be stored
#' @param source_file Optional, path to source file used to create this variable
#' @param steps Optional, character vector describing the steps taken to create this variable
#' #$export
save_var <- function(obj, name, value, source_file = NULL, steps = NULL) {
  UseMethod("save_var")
}

#' #$export
save_var.sqlite_storage <- function(obj, name, value, source_file = NULL, steps = NULL) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  # Register source file if provided
  file_hash <- NA_character_
  if (!is.null(source_file)) {
    register_file(obj, source_file)
    file_hash <- calculate_file_hash(source_file)
  }

  serialized_value <- list(serialize(value, NULL))  # Wrap in list for SQLite BLOB
  value_type <- paste(class(value), collapse = ", ")
  timestamp <- Sys.time()
  steps_text <- if (!is.null(steps)) paste(steps, collapse = " | ") else NA_character_

  # Check if variable already exists
  existing <- DBI::dbGetQuery(obj$conn,
                              "SELECT name FROM variables WHERE name = ?",
                              params = list(name)
  )

  if (nrow(existing) > 0) {
    # Update existing variable
    DBI::dbExecute(obj$conn,
                   "UPDATE variables SET value = ?, type = ?, source_file = ?, file_hash = ?,
       steps = ?, updated_at = ? WHERE name = ?",
                   params = list(serialized_value, value_type, source_file, file_hash,
                                 steps_text, as.character(timestamp), name)
    )
    message("Updated variable: ", name)
  } else {
    # Insert new variable
    DBI::dbExecute(obj$conn,
                   "INSERT INTO variables (name, value, type, source_file, file_hash, steps, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                   params = list(name, serialized_value, value_type, source_file, file_hash,
                                 steps_text, as.character(timestamp), as.character(timestamp))
    )
    message("Saved variable: ", name)
  }

  # Save detailed steps if provided
  if (!is.null(steps)) {
    save_variable_steps(obj, name, steps)
  }

  invisible(obj)
}

#' Save Variable from File with Processing Steps
#'
#' @param obj An object of class "sqlite_storage"
#' @param name Character string, name of the variable
#' @param file_path Path to the file to load
#' @param steps Optional, character vector describing processing steps
#' @param processor Optional, custom function to process the file. If NULL, uses default processors.
#' #$export
save_file_var <- function(obj, name, file_path, steps = NULL, processor = NULL) {
  UseMethod("save_file_var")
}

#' #$export
save_file_var.sqlite_storage <- function(obj, name, file_path, steps = NULL, processor = NULL) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }

  # Register the file
  register_file(obj, file_path)

  # Load the file based on extension or custom processor
  if (!is.null(processor)) {
    value <- processor(file_path)
  } else {
    value <- load_file_by_type(file_path)
  }

  # Combine file loading with processing steps
  all_steps <- c(paste("Loaded file:", file_path), steps)

  # Save the variable with provenance
  save_var(obj, name, value, source_file = file_path, steps = all_steps)

  invisible(obj)
}

#' Load file based on its type
#'
#' @param file_path Path to the file
#' @return Loaded R object
load_file_by_type <- function(file_path) {
  ext <- tolower(tools::file_ext(file_path))

  switch(ext,
         "csv" = {
           utils::read.csv(file_path, stringsAsFactors = FALSE)
         },
         "tsv" = {
           utils::read.delim(file_path, stringsAsFactors = FALSE)
         },
         "txt" = {
           readLines(file_path)
         },
         "r" = {
           # For R files, we return the source code as text
           list(
             source = readLines(file_path),
             file_path = file_path,
             note = "R source code - use source() to execute"
           )
         },
         "rds" = {
           readRDS(file_path)
         },
         "rdata" = ,
         "rda" = {
           env <- new.env()
           load(file_path, envir = env)
           as.list(env)
         },
         "json" = {
           if (requireNamespace("jsonlite", quietly = TRUE)) {
             jsonlite::fromJSON(file_path)
           } else {
             stop("jsonlite package required for JSON files")
           }
         },
         "xlsx" = ,
         "xls" = {
           if (requireNamespace("readxl", quietly = TRUE)) {
             readxl::read_excel(file_path)
           } else {
             stop("readxl package required for Excel files")
           }
         },
         {
           # Default: try to read as text
           warning("Unknown file type, reading as text")
           readLines(file_path)
         }
  )
}

#' Save detailed steps for a variable
#'
#' @param obj An object of class "sqlite_storage"
#' @param var_name Variable name
#' @param steps Character vector of steps
save_variable_steps <- function(obj, var_name, steps) {
  if (is.null(steps)) return(invisible(obj))

  # Clear existing steps for this variable
  DBI::dbExecute(obj$conn,
                 "DELETE FROM variable_steps WHERE variable_name = ?",
                 params = list(var_name)
  )

  # Insert new steps
  for (i in seq_along(steps)) {
    DBI::dbExecute(obj$conn,
                   "INSERT INTO variable_steps (variable_name, step_order, step_description, step_timestamp)
       VALUES (?, ?, ?, ?)",
                   params = list(var_name, i, steps[i], as.character(Sys.time()))
    )
  }

  invisible(obj)
}

#' Load Variable from Database
#'
#' @param obj An object of class "sqlite_storage"
#' @param name Character string, name of the variable to load
#' @return The stored R object
#' #$export
load_var <- function(obj, name) {
  UseMethod("load_var")
}

#' #$export
load_var.sqlite_storage <- function(obj, name) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  result <- DBI::dbGetQuery(obj$conn,
                            "SELECT value FROM variables WHERE name = ?",
                            params = list(name)
  )

  if (nrow(result) == 0) {
    stop("Variable '", name, "' not found in database")
  }

  unserialize(result$value[[1]])
}

#' Get Variable Provenance
#'
#' @param obj An object of class "sqlite_storage"
#' @param name Character string, name of the variable
#' @return Data frame with provenance information
#' #$export
get_provenance <- function(obj, name) {
  UseMethod("get_provenance")
}

#' #$export
get_provenance.sqlite_storage <- function(obj, name) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  # Get variable info
  var_info <- DBI::dbGetQuery(obj$conn,
                              "SELECT name, type, source_file, file_hash, steps, created_at, updated_at
     FROM variables WHERE name = ?",
                              params = list(name)
  )

  if (nrow(var_info) == 0) {
    stop("Variable '", name, "' not found")
  }

  # Get detailed steps
  steps_info <- DBI::dbGetQuery(obj$conn,
                                "SELECT step_order, step_description, step_timestamp
     FROM variable_steps WHERE variable_name = ? ORDER BY step_order",
                                params = list(name)
  )

  # Get file info if available
  file_info <- NULL
  if (!is.na(var_info$source_file)) {
    file_info <- DBI::dbGetQuery(obj$conn,
                                 "SELECT * FROM files WHERE file_path = ?",
                                 params = list(var_info$source_file)
    )
  }

  list(
    variable = var_info,
    steps = steps_info,
    file = file_info
  )
}

#' List All Variables with Provenance
#'
#' @param obj An object of class "sqlite_storage"
#' @return A data frame with variable information including provenance
#' #$export
list_vars <- function(obj) {
  UseMethod("list_vars")
}

#' #$export
list_vars.sqlite_storage <- function(obj) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  DBI::dbGetQuery(obj$conn,
                  "SELECT name, type, source_file, created_at, updated_at FROM variables ORDER BY name"
  )
}

#' List All Registered Files
#'
#' @param obj An object of class "sqlite_storage"
#' @return A data frame with file information
#' #$export
list_files <- function(obj) {
  UseMethod("list_files")
}

#' #$export
list_files.sqlite_storage <- function(obj) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  DBI::dbGetQuery(obj$conn,
                  "SELECT file_path, file_type, file_size, file_modified, registered_at FROM files ORDER BY file_path"
  )
}

#' Check if Variable Exists
#'
#' @param obj An object of class "sqlite_storage"
#' @param name Character string, name of the variable
#' @return Logical, TRUE if variable exists
#' #$export
var_exists <- function(obj, name) {
  UseMethod("var_exists")
}

#' #$export
var_exists.sqlite_storage <- function(obj, name) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  result <- DBI::dbGetQuery(obj$conn,
                            "SELECT COUNT(*) as count FROM variables WHERE name = ?",
                            params = list(name)
  )

  result$count > 0
}

#' Delete Variable
#'
#' @param obj An object of class "sqlite_storage"
#' @param name Character string, name of the variable to delete
#' #$export
delete_var <- function(obj, name) {
  UseMethod("delete_var")
}

#' #$export
delete_var.sqlite_storage <- function(obj, name) {
  if (is.null(obj$conn)) {
    obj <- initialize_db(obj)
  }

  if (!var_exists(obj, name)) {
    warning("Variable '", name, "' does not exist")
    return(invisible(obj))
  }

  # Delete variable steps first (foreign key constraint)
  DBI::dbExecute(obj$conn,
                 "DELETE FROM variable_steps WHERE variable_name = ?",
                 params = list(name)
  )

  # Delete variable
  DBI::dbExecute(obj$conn,
                 "DELETE FROM variables WHERE name = ?",
                 params = list(name)
  )

  message("Deleted variable: ", name)
  invisible(obj)
}

#' Close Database Connection
#'
#' @param obj An object of class "sqlite_storage"
#' #$export
close_db <- function(obj) {
  UseMethod("close_db")
}

#' #$export
close_db.sqlite_storage <- function(obj) {
  if (!is.null(obj$conn)) {
    DBI::dbDisconnect(obj$conn)
    obj$conn <- NULL
    message("Database connection closed")
  }
  invisible(obj)
}

#' #$export
print.sqlite_storage <- function(x, ...) {
  cat("SQLite Variable Storage Object (Enhanced)\n")
  cat("Database path:", x$db_path, "\n")
  isOpen <- !is.null(x$conn) && DBI::dbIsValid(x$conn)
  cat("Connection status:", ifelse(!isOpen, "Closed", "Open"), "\n")

  if (isOpen) {
    vars <- list_vars(x)
    files <- list_files(x)
    cat("Stored variables:", nrow(vars), "\n")
    cat("Registered files:", nrow(files), "\n")

    if (nrow(vars) > 0) {
      cat("\nVariables:\n")
      print(vars)
    }

    if (nrow(files) > 0) {
      cat("\nFiles:\n")
      print(files)
    }
  }

  invisible(x)
}

# Example usage:
#
# # Create storage object
# storage <- sqlite_storage("enhanced_vars.db")
#
# # Save variable with steps
# save_var(storage, "processed_data", data.frame(x = 1:5, y = letters[1:5]),
#          steps = c("Created sample data", "Added letter column", "Validated structure"))
#
# # Save variable from CSV file
# # save_file_var(storage, "survey_data", "survey.csv",
# #               steps = c("Loaded raw survey", "Removed incomplete responses", "Standardized names"))
#
# # Save variable from R script
# # save_file_var(storage, "analysis_results", "analysis.R",
# #               steps = c("Executed analysis script", "Generated summary statistics"))
#
# # Load variable and get provenance
# data <- load_var(storage, "processed_data")
# provenance <- get_provenance(storage, "processed_data")
#
# # List everything
# list_vars(storage)
# list_files(storage)
#
# # Close when done
# close_db(storage)

#' #' This is created by Claude Sonnet 4
#' #'
#' #' Recommended Installation
#' #' #' # Install devtools if not already installed
#' #' install.packages("devtools")
#' #'
#' #' # Create package structure
#' #' devtools::create("sqlitestorage")
#' #' setwd("sqlitestorage")
#' #' usethis::use_mit_license()
#' #'
#' #' # Set up package development
#' #' roxygen2::roxygenize()
#' #' devtools::test() # to build test infrastructure
#' #' usethis::use_test() # to initialize a basic test file and open it for editing.
#' #'
#' #' # Add dependencies
#' #' usethis::use_package("RSQLite", min_version = "2.2.0")
#' #' usethis::use_package("DBI", min_version = "1.1.0")
#' #'
#' #' # Generate documentation
#' #' devtools::document()
#' #'
#' #' # Check package
#' #' devtools::check()
#' #'
#' #' # Install locally
#' #' devtools::install()
#' #'
