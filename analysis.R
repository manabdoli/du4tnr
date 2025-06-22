rm(list = ls())
dbo <- dbObj('myDbObj.db')
dbo$add_var("x", c(1, 2, 3),
            source_file = "analysis.R",
            steps = "Created test vector")
x <- dbo$load_var("x")

dbo$list_steps()
dbo$list_files()
dbo$list_vars()
dbo$var_exists("y")
dbo$close_db()
dbo$reconnect()
dbo
# Save and load variables with provenance
storage <- sqlite_storage("my_vars.db")
save_var(storage, "x", c(1, 2, 3), source_file = "analysis.R",
         steps = "Created test vector")
x <- load_var(storage, "x")

# Store file-based variables
save_file_var(storage, "data", "mydata.csv",
              steps = c("Load CSV", "Clean data", "Remove NAs"))

# Clean up
close_db(storage)
