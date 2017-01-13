### -----------------------------
## advanced R & recent advances in R
## simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


## basic data tidying and examination with janitor ----------

# clean variable names
  # only lowercase letters, with _ as separator
  # handles special characters and spaces 
  # appends numbers to duplicated names
foo_df <- as.data.frame(matrix(ncol = 6))
names(foo_df) <- c("hIgHlo", "REPEAT VALUE", "REPEAT VALUE", "% successful (2009)",  "abc@!*", "")
foo_df
janitor::clean_names(foo_df)
make.names(names(foo_df)) # base R solution - not very convincing

# convert multiple values to NA
convert_to_NA(letters[1:5], c("b", "d"))
convert_to_NA(sample(c(1:5, 98, 99), 20, replace = TRUE), c(98,99))

# clean frequency tables
head(mtcars)
table(mtcars$cyl)
janitor::tabyl(mtcars$cyl, show_na = TRUE, sort = TRUE)
janitor::tabyl(mtcars$cyl, show_na = TRUE, sort = TRUE) %>% add_totals_row()

# clean cross tabulations
mtcars %$% table(cyl, gear)
mtcars %>% janitor::crosstab(cyl, gear)
mtcars %>% janitor::crosstab(cyl, gear) %>% adorn_crosstab(denom = "row", show_totals = TRUE)

# use first valid value of multiple variables to get rid of NAs
set.seed(123)
x <- sample(c(1:10, rep(NA, 5)))
y <- sample(c(1:10, rep(NA, 5)))
z <- sample(c(1:10, rep(NA, 5)))
foo_df <- data.frame(x, y, z)
foo_df
foo_df %$% ifelse(!is.na(x), x, ifelse(!is.na(y), y, ifelse(!is.na(z), z, NA)))
foo_df %$% use_first_valid_of(x, y, z)

# more functionality available; see
browseURL("https://cran.r-project.org/web/packages/janitor/vignettes/introduction.html")
browseURL("https://github.com/sfirke/janitor") # worth a look if you have to deal with messy Excel/spreadsheet data



## tidying data frames with tidyr ----------------

https://www.r-bloggers.com/how-to-reshape-data-in-r-tidyr-vs-reshape2/
  https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html

# Hadley Wickham's paper on tidy data:
browseURL("https://www.jstatsoft.org/article/view/v059i10")

# Wickham is proponent of "one column, one variable" paradigm
# corresponds to "long" format for panel data sets
# fit nicely with dplyr, ggplot and similar packages that operate on data frames
# tidyr essentially provides yet another set of functions to deal with reshaping data frames to fit these rules:
  # each variable must have its own column
  # each observation must have its own row
  # each value must have its own cell

# several ways of organizing data...

# already tidy
table1

table1 %>% mutate(rate = cases / population * 10000)
table1 %>% count(year, wt = cases)


table2

table3

# column names represent variable values (year); each row represents two observations, not one
table4a


table4b

# getting rid of observations scattered across multiple rows with spread(), a.k.a. moving from long to wide format
(tidy2 <- table2 %>% spread(key = type, value = count))


# getting rid of values in variable names with gather() a.k.a moving from wide to long format
(tidy4a <- table4a %>% gather(`1999`, `2000`, key = "year", value = "cases"))
(tidy4b <- table4b %>% gather(`1999`, `2000`, key = "year", value = "population"))
left_join(tidy4a, tidy4b)




# reshaping with tidyr in one slide
browseURL("https://twitter.com/FrederikAust/status/789101346595151872/photo/1")






## tidying model output with broom ----------

# overview at
browseURL("ftp://cran.r-project.org/pub/R/web/packages/broom/vignettes/broom.html")
browseURL("ftp://cran.r-project.org/pub/R/web/packages/broom/vignettes/broom_and_dplyr.html")

## motivation
# model inputs usually have to be tidy
# model outputs less so...
# this makes dealing with model results (e.g., visualizing coefficients, comparing results across models, etc.) sometimes difficult

## example: linear model output
model_out <- lm(mpg ~ wt, mtcars) # linear relationship between miles/gallon and weight (in 1000 lbs)
model_out
summary(model_out)

# examine model object
str(model_out)
coef(summary(model_out)) # matrix of coefficients with variable terms in row names
broom::tidy(model_out)
?tidy.lm

# add fitted values and residuals to original data
broom::augment(model_out) %>% head
?augment.lm

# inspect summary statistics
broom::glance(model_out)
?glance.lm

# many supported models; see
?tidy # ... and click on "index"


# the true power of broom unfolds in settings where you want to combine results from multiple analyses (using subgroups of data, different models, bootstrap replicates of the original data frame, permutations, imputations, ...)

data(Orange)
Orange

# inspect relationship between age and circumference
cor(Orange$age, Orange$circumference) 
ggplot(Orange, aes(age, circumference, color = Tree)) + geom_line()

# using broom and dplyr together works like a charm
Orange %>% group_by(Tree) %>% summarize(correlation = cor(age, circumference))
cor.test(Orange$age, Orange$circumference)
Orange %>% group_by(Tree) %>% do(tidy(cor.test(.$age, .$circumference)))

# also works for regressions
Orange %>% group_by(Tree) %>% do(tidy(lm(age ~ circumference, data=.)))

# if you want not just the tidy output, but the augment and glance outputs as well, while still performing each regression only once, you do:
regressions <- mtcars %>% group_by(cyl) %>%
  do(fit = lm(wt ~ mpg + qsec + gear, .))
regressions
regressions %>% tidy(fit)
regressions %>% augment(fit)
regressions %>% glance(fit)

# other examples online
browseURL("ftp://cran.r-project.org/pub/R/web/packages/broom/vignettes/kmeans.html") # k-means clustering
browseURL("ftp://cran.r-project.org/pub/R/web/packages/broom/vignettes/bootstrapping.html") # bootstrapping
