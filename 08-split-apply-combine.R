### -----------------------------
## advanced R & recent advances in R
## simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()



## split-apply-combine ----

# workflow:
  # 1. take input (list, data frame, array)
  # 2. split it (e.g., data frame into columns)
  # 3. apply function to the single parts
  # 4. combine it into new object
# lapply() and friends are among the best-known functionals, i.e. functions that take a function as input
# often more efficient than a for loop

# looping patters for a for loop:
  # loop over elements: for (x in xs)
  # loop over numeric indices: for (i in seq_along(xs))
  # loop over the names: for (nm in names())

# basic patterns to use lapply():
lapply(xs, function(x) {})
lapply(seq_along(xs), function(i) {})
lapply(names(xs), function(nm) {})


## lapply(): applying a function over a list or vector; returning a list



## sapply() and vapply(): applying a function over a list or vector; returning a vector

# sapply() and vapply() are similar to lapply() but simplify their output to produce an atomic vector
# sapply() guesses, vapply() takes an additional argument specifying the output type

lapply(mtcars, is.numeric)
sapply(mtcars, is.numeric)
vapply(mtcars, is.numeric, logical(1))

# why vapply is more robust: empty input
sapply(list(), is.numeric)
vapply(list(), is.numeric, logical(1))

# why vapply is more robust: different output
df <- data.frame(x = 1:10, y = letters[1:10])
sapply(df, class)
vapply(df, class, character(1))

df2 <- data.frame(x = 1:10, y = Sys.time() + 1:10)
sapply(df2, class)
vapply(df2, class, character(1))


## multiple inputs: Map()

# with lapply(), only one argument varies, the others are fixed
# sometimes, you want more arguments to vary
# here, Map() comes into play

# example: computation of mean vs. weighted mean
xs <- replicate(5, runif(10), simplify = FALSE)
ws <- replicate(5, rpois(10, 5) + 1, simplify = FALSE)

vapply(xs, mean, numeric(1))
Map(weighted.mean, xs, ws) %>% unlist

# if some of the arguments should be fixed and constant, use an anomymous function:
Map(function(x, w) weighted.mean(x, w, na.rm = TRUE), xs, ws)


## apply(): operating on matrices and arrays

a <- matrix(1:20, nrow = 5)
apply(a, 1, mean)
apply(a, 2, mean)

x <- matrix(rnorm(20, 0, 10), nrow = 4)
x1 <- sweep(x, 1, apply(x, 1, min), `-`)
x2 <- sweep(x1, 1, apply(x1, 1, max), `/`)





## the plyr package -------------------








## SPLIT-APPLY-COMBINE MIT BASE R -----------------


# Umgang mit base R apply-Funktionen
soep_classes <- lapply(soep, class)
class(soep_classes)

class(sapply(soep, class))

num <- sapply(soep, is.numeric)
soep_sub <- soep[, num]

sapply(soep_sub, mean, na.rm = TRUE)

tapply(soep_sub$miete, soep_sub$zimmer, summary)
tapply(soep_sub$hhgr, soep_sub$zimmer, summary)




######################
### IT'S YOUR SHOT ###
######################

# 1. Build a function that scales a vector so it falls in the range [0,1]. How would you apply it to every column of a data frame? How would you apply it to every numeric column of a data frame?
scale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1]) 
}
vec <- runif(10, 0, 10)
scale01(vec)

df <- mtcars
df[] <- lapply(df, scale01)

df <- iris
df_num <- sapply(df, is.numeric)
df[df_num] <- lapply(df[df_num], scale01) 


# 2. Fit the model mpg ~ disp to each of the bootstrap replicates of mtcars in the list below using no more than one line of code.
bootstraps <- lapply(1:10, function(i) {
  rows <- sample(1:nrow(mtcars), rep = TRUE)
  mtcars[rows,] 
})

models_out <- lapply(bootstraps, function(x) {lm(mpg ~ disp, data = x)})


