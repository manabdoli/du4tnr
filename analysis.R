rm(list = ls())
dbo <- dbObj('myDbObj.db')
dbo$add_var("x", c(1, 2, 3),
            source_file = "analysis.R",
            steps = "Created test vector")
(x <- dbo$get_var("x"))

dbo$add_var("y", list(a=c(1, 2, 3), b=letters[1:5], c=list(d=1:4, e=data.frame(f=1:4, g=letters[3:6]))))

(y <- dbo$get_var("y"))

dbo$list_steps()
dbo$list_files()
dbo$list_vars()
dbo$var_exists("y")
dbo$close_db()
dbo$reconnect_db()
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
