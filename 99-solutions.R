### -----------------------------
## advanced R & recent advances in R
## simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


## 01-file-management ---------------------------

# go to the following webpage.
url <- "http://www.cses.org/datacenter/module4/module4.htm"
browseURL(url)

# the following piece of code identifies all links to resources on the webpage and selects the subset of links that refers to the survey questionnaire PDFs.
library(rvest)
page_links <- read_html(url) %>% html_nodes("a") %>% html_attr("href")
survey_pdfs <- str_subset(page_links, "/survey")

# set up folder data/cses-pdfs.
dir.create("data/cses-pdfs", recursive = TRUE)

# download a sample of 10 of the survey questionnaire PDFs into that folder using a for loop and the download.file() function.
baseurl <- "http://www.cses.org"
for (i in 1:10) {
  filename <- basename(survey_pdfs[i])
  if(!file.exists(paste0("data/cses-pdfs/", filename))){
    download.file(paste0(baseurl, survey_pdfs[i]), destfile = paste0("data/cses-pdfs/", filename))
    Sys.sleep(runif(1, 0, 1))
  }
}

# check if the number of files in the folder corresponds with the number of downloads and list the names of the files.
length(list.files("data/cses-pdfs"))
list.files("data/cses-pdfs")

# inspect the files. which is the largest one?
file.info(dir("data/cses-pdfs", full.names = TRUE)) %>% View()


# zip all files into one zip file.
zip("data/cses-pdfs/cses-mod4-questionnaires.zip", dir("data/cses-pdfs", full.names = TRUE))



## 03-functions ---------------------------

# program a function ultimateAnswer() that always returns the number 42!
ultimateAnswer <- function(x) {42}

# program a function normalize() that produces normalizes a numeric vector x to mean(x) = 0 and sd(x) = 1!
normalize <- function(x, na.rm = FALSE) {
  y <-  (x - mean(x, na.rm = na.rm))/sd(x, na.rm = na.rm)
  y
}

vec <- c(1, 5, 10, NA)
normalize(vec, na.rm = TRUE) %>% summary
normalize(vec, na.rm = TRUE) %>% sd(na.rm = TRUE)

# use sapply() and an anonymous function to find the coefficient of variation for all variables in the mtcars dataset!
sapply(mtcars, function(x) sd(x)/mean(x))

# use integrate and an anonymous function to find the area under the curve for the following functions:
# a) y = x ^ 2 - x, x in [0, 10]
# b) y = sin(x) + cos(x), x in [-pi, pi]
integrate(function(x) x^2 - x, lower = 0, upper = 10)
integrate(function(x) sin(x) + cos(x), lower = -pi, upper = pi)


# try to inspect the source code of the summary function when applied to a data.frame object.
methods(summary)
getAnywhere(summary.data.frame)


# the following code makes a list of all functions in the base package. use it to answer the following questions: 
# a) which base function has the most arguments?
# b) how many base functions have no arguments? what's special about them?

objs <- mget(ls("package:base"), inherits = TRUE)
funs <- Filter(is.function, objs)

foo <- sapply(funs, formals) %>% sapply(length)
sort(foo) %>% tail()
table(foo)
funs[foo==0]

# what does the following code return? why? what does each of the three c's mean?
c <- 10
c(c = c)

# what does the following function return? Make a prediction before running the code yourself.
f <- function(x) { 
  f <- function(x) { 
    f <- function(x) {
      x ^ 2
    } 
    f(x) + 1
  } 
  f(x) * 2
} 
f(10)

# create infix versions of the set functions intersect(), union(), and setdiff().
vec1 <- c(1, 2, 3)
vec2 <- c(3, 4, 5)

intersect(vec1, vec2)
`%x%` <- function(a, b) intersect(a, b)
vec1 %x% vec2

union(vec1, vec2)
`%oo%` <- function(a, b) union(a, b)
vec1 %oo% vec2

setdiff(vec1, vec2)
setdiff(vec2, vec1)
`%<>%` <- function(a, b) setdiff(a, b)
vec1 %<>% vec2





## 05-string-processing ---------------------------

## 1. describe the types of strings that conform to the following regular expressions and construct an example that is matched by the regular expression.
str_extract_all("Phone 150$, PC 690$", "[0-9]+\\$") # example
str_extract_all("Just any sentence, I don't know. Today is a nice day.", "\\b[a-z]{1,4}\\b")
str_extract_all(c("log.txt", "example.html", "bla.txt2"), ".*?\\.txt$")
str_extract_all("log.txt, example.html, bla.txt2", ".*?\\.txt$")
str_extract_all(c("01/01/2000", "1/1/00", "01.01.2000"), "\\d{2}/\\d{2}/\\d{4}")
str_extract_all(c("<br>laufen</br>", "<title>Cameron wins election</title>"), "<(.+?)>.+?</\\1>")


## 2. consider the mail address  chunkylover53[at]aol[dot]com.
# a) transform the string to a standard mail format using regular expressions.
# b) imagine we are trying to extract the digits in the mail address using [:digit:]. explain why this fails and correct the expression.
email <- "chunkylover53[at]aol[dot]com"
email_new <- email %>% str_replace("\\[at\\]", "@") %>% str_replace("\\[dot\\]", ".")
str_extract(email_new, "[:digit:]+")



## 06-manipulating-data-frames ---------------------------

# 1. Find all flights that 
# a) Had an arrival delay of two or more hours
# b) Arrived more than two hours late, but didn't leave late
# c) have a missing dep_time - and speculate why this might be the case by looking at other variables.

filter(dat, arr_delay >= 120) %>% dim
filter(dat, arr_delay >= 120, dep_delay <= 0) %>% dim
filter(dat, is.na(dep_time)) %>% View

# 2. Which flights travelled longest, which shortest?
arrange(dat, air_time) %>% head
arrange(dat, desc(air_time)) %>% head

# 3. Does the result of running the following code surprise you? If no, explain! If yes, figure out why the output looks how it looks!
select(dat, contains("TIME")) %>% View

# 4. Find the 10 most delayed flights using a ranking function. How do you want to handle ties? Have a look at ?min_rank and ?rank first!
mutate(dat, delay_rank = min_rank(desc(arr_delay))) %>% arrange(arr_delay) %>% View

# 5. Which carrier has the worst delays, which ranks best?

dat %>% group_by(carrier) %>% summarize(mean_delay = mean(arr_delay, na.rm = TRUE)) %>% arrange(mean_delay)
table(dat$carrier)
flights %>% group_by(carrier) %>% summarise(n_flights = n())

# 6. Delays are typically temporally correlated: even once the problem that caused the initial delay has been resolved, later flights are delayed to allow earlier flights to leave. Using lag() explore how the delay of a flight is related to the delay of the immediately preceding flight.
foo <- arrange(dat, year, month, day, dep_time) %>% mutate(prev_delay = lag(dep_delay))
plot(foo$dep_delay, foo$prev_delay)
lm(dep_delay ~ prev_delay, data = foo) %>% summary()


## 07-split-apply-combine ---------------------------

# 1. Below is a function that scales a vector so it falls in the range [0,1]. How would you apply it to every column of a data frame? How would you apply it to every numeric column of a data frame? Try to come up with solutions using both base R and plyr functions. Use the data.frames mtcars and iris as examples.
scale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1]) 
}
vec <- runif(10, 0, 10)
scale01(vec)

# base R
df <- mtcars
df[] <- lapply(df, scale01) # or:
df <- lapply(df, scale01) %>% as.data.frame

df <- iris
df_num <- sapply(df, is.numeric)
df[df_num] <- lapply(df[df_num], scale01) 

# plyr
df <- mtcars
df[] <- llply(df, scale01) 

df <- iris
numcolwise(scale01)(df)
ddply(df, .(), numcolwise(scale01))



# 2. Fit the model mpg ~ disp to each of the bootstrap replicates of mtcars in the list below using no more than one line of code.
bootstraps <- lapply(1:10, function(i) {
  rows <- sample(1:nrow(mtcars), rep = TRUE)
  mtcars[rows,] 
})

models_out <- lapply(bootstraps, function(x) {lm(mpg ~ disp, data = x)})

