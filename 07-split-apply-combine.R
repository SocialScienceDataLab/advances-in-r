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


## base R apply functions -----------

# apply(): operating on matrices and arrays
a <- matrix(1:20, nrow = 5)
apply(a, 1, mean)
apply(a, 2, mean)

# lapply(): applying a function over a list or vector; returning a list
# sapply() and vapply(): applying a function over a list or vector; returning a vector
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

# note: there's also mapply, which has SIMPLIFY = TRUE by default
mapply(function(x, w) weighted.mean(x, w, na.rm = TRUE), xs, ws)

# apply function over ragged arraw
dat <- data.frame(x = 1:20, y = rep(letters[1:5], each = 4))
tapply(dat$x, dat$y, sum) # data, index, function




## the plyr package -------------------

# plyr provides an alternative grammar to base R's split-apply-combine functions
# introductory JSTATSOFT article here: https://goo.gl/NHa8rM
# basic format is two letters followed by ply()
# first letter: input format, second letter: output format
# three main letters: d = data.frame, a = array (including matrices), l = list
# other less common options: m = multi-argument function input, r = replicate a function n times, _ = throw away the output
# examples:
ddply() # input: data.frame, output: data.frame
ldply() # input: list, output: data.frame
dlply() # input: data.frame, output: list

# ddply()
ddply(babynames, "year", function(x) {
  max_prop <- max(x$prop)
  max_n <- max(x$n)
  data.frame(max_prop = max_prop, max_n = max_n)
})

# transform and summarize
  # summarize creates new data.frame
  # transform modifies existing data.frame
bnames <- ddply(babynames, "year", summarize, max_prop = max(prop))
bnames <- ddply(babynames, c("sex", "year"), transform, rank = rank(-prop, ties.method = "first"))


# call a multi-argument function with values taken from columns of an data frame or array, and combine results into a data frame
mdply(data.frame(mean = 1:5, sd = 1:5), rnorm, n = 3)


# useful post:
browseURL("http://stackoverflow.com/questions/3505701/r-grouping-functions-sapply-vs-lapply-vs-apply-vs-tapply-vs-by-vs-aggrega")



######################
### IT'S YOUR SHOT ###
######################

# 1. Below is a function that scales a vector so it falls in the range [0,1]. How would you apply it to every column of a data frame? How would you apply it to every numeric column of a data frame? Try to come up with solutions using both base R and plyr functions. Use the data.frames mtcars and iris as examples.
scale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1]) 
}
vec <- runif(10, 0, 10)
scale01(vec)


# 2. Fit the model mpg ~ disp to each of the bootstrap replicates of mtcars in the list below using no more than one line of code.
bootstraps <- lapply(1:10, function(i) {
  rows <- sample(1:nrow(mtcars), rep = TRUE)
  mtcars[rows,] 
})


