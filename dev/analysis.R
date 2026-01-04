library(du4tnr)
rm(list = ls())
dbo <- dbObj('dev/myDbObj.db')
dbo$add_var("x", c(1, 2, 3),
            source_file = "dev/analysis.R",
            steps = "Created test vector")
(x <- dbo$get_var("x"))

dbo$add_var("y", list(a=c(1, 2, 3), b=letters[1:5],
                      c=list(d=1:4,
                             e=data.frame(f=1:4, g=letters[3:6]))))

(y <- dbo$get_var("y"))

dbo$list_steps()
dbo$list_files()
dbo$list_vars()
dbo$var_exists("y")
dbo$close_db()
dbo$reconnect_db()
dbo

## Testing misMulOH
y <- mtcars %>% dplyr::mutate(gear=factor(gear))
mdl <- nnet::smultinom(formula = gear~am+mpg, data = y)
yhat <- nnet:::predict.multinom(mdl, newdata = y, type='probs')
misMulOH(yhat, y)

