### -----------------------------
## advanced R & recent advances in R
## simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


## functional programming ----------

# R is a functional programming lanugage, i.e. it provides many tools for the creation and manipulation of functions
# you can do virtually anything with functions: assign them to variables, store them in lists, pass them as arguments to other functions, ...
# very helpful in obeying the DRY principle


# motivation

# Generate a sample dataset 
set.seed(1014) 
df <- data.frame(replicate(6, sample(c(1:5, -99), 6, rep = TRUE))) 
names(df) <- letters[1:6] 
df

# how to replace -99 with NA?
df$a[df$a == -99] <- NA
df$b[df$b == -99] <- NA
df$c[df$c == -98] <- NA
df$d[df$d == -99] <- NA
df$e[df$e == -99] <- NA
df$f[df$g == -99] <- NA

fix_missing <- function(x) { 
  x[x == -99] <- NA
  x 
}
# lapply is called a "functional" because it takes a function as an argument
df[] <- lapply(df, fix_missing) # littler trick to make sure we get back a data frame, not a list

# easy to generalize to a subset of columns
df[1:3] <- lapply(df[1:3], fix_missing)
df

# what if different codes for missing values are used?
fix_missing_99 <- function(x) { 
  x[x == -99] <- NA
  x 
}

fix_missing_999 <- function(x) { 
  x[x == -999] <- NA
  x 
}

## NOOO! Instead:
missing_fixer <- function(x, na.value) { 
  x[x == na.value] <- NA
  x
}

## applying multiple functions
summary_ext <- function(x) { 
  c(mean(x, na.rm = TRUE), 
    median(x, na.rm = TRUE), 
    sd(x, na.rm = TRUE), 
    mad(x, na.rm = TRUE), 
    IQR(x, na.rm = TRUE)) 
}
lapply(df, summary_ext)

# better: store functions in lists
summary_ext <- function(x) { 
  funs <- c(mean, median, sd, mad, IQR)
  lapply(funs, function(f) f(x, na.rm = TRUE)) 
}
sapply(df, summary_ext)

# using anonymous functions
sapply(mtcars, function(x) length(unique(x)))




######################
### IT'S YOUR SHOT ###
######################

# 1. Use sapply() and an anonymous function to find the coefficient of variation for all variables in the mtcars dataset!
sapply(mtcars, function(x) sd(x)/mean(x))

# 2. Use integrate and an anonymous function to find the area under the curve for the following functions:
  # a) y = x ^ 2 - x, x in [0, 10]
  # b) y = sin(x) + cos(x), x in [-pi, pi]

integrate(function(x) x^2 - x, lower = 0, upper = 10)
integrate(function(x) sin(x) + cos(x), lower = -pi, upper = pi)


