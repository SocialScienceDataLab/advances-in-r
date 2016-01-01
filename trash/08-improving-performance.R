### -----------------------------
## advanced R & recent advances in R
## simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()



## why improving performance? ----

# R is not designed to optimize computing speed
# instead, R is designed to be well understandable for data analysts
# R is slow compared to other programming languages for a variety of reasons, e.g. its highly dynamic nature and the fact that the R Core Team is rather conservative in accepting new code that improves performance
# for more info, see
browseURL("http://adv-r.had.co.nz/Performance.html")
# alter



## how to measure performance ----

# microbenchmark package
library(microbenchmark)
?microbenchmark

x <- runif(1000)
microbenchmark(
  sqrt(x),
  x ^ 0.5,
  x ^ (1 / 2),
  exp(log(x) / 2)
)


# base system.time() function
x <- runif(1000)
system.time(replicate(1000, sqrt(x)))
system.time(replicate(1000, x ^ 0.5))


# summary
# microbenchmark packge provides precise timings that merely reflect the time it takes to evaluate <expr>
# however, only meaningful for small pieces of source code
# for larger chunks of code, use R profiler






## parallelization ----------

dplyr
data.table

browseURL("http://r4ds.had.co.nz/transform.html")
