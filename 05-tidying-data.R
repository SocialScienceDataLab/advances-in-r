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

# Hadley Wickham's paper on tidy data:
browseURL("https://www.jstatsoft.org/article/view/v059i10")

# Wickham is proponent of "one column, one variable" paradigm
# corresponds to "long" format for panel data sets
# fit nicely with dplyr, ggplot and similar packages that operate on data frames
# tidyr essentially provides yet another set of functions to deal with reshaping data frames to fit these rules:
  # each variable must have its own column
  # each observation must have its own row
  # each value must have its own cell

# related to reshape2 and reshape, although tidyr is not designed for general reshaping
  # gather() ~ melt() 
      # --> takes multiple columns and gathers them into key-value pairs 
      # --> wide to long
  # spread() ~ cast() 
      # --> takes two columns (key and value) and spreads in to multiple columns 
      # --> long to wide

# additional functions:
  # separate()
      # --> pull apart a column that represents multiple variables
  # unite()
      # complement to separate()

# example: gather()
  # demo("so-17481212")
race <- read.table(header = TRUE, check.names = FALSE, text = "
  Name    50  100  150  200  250  300  350
  Carla  1.2  1.8  2.2  2.3  3.0  2.5  1.8
  Mace   1.5  1.1  1.9  2.0  3.6  3.0  2.5
  Lea    1.7  1.6  2.3  2.7  2.6  2.2  2.6
  Karen  1.3  1.7  1.9  2.2  3.2  1.5  1.9
")
race
race_long <- gather(race, key = Time, value = Score, -Name, convert = TRUE) 
race_long
race_long %>% arrange(Name, Time)

# example: spread()
  # demo("so-16032858")
results <- data.frame(
  Ind = paste0("Ind", 1:10),
  Treatment = rep(c("Treat", "Cont"), each = 10),
  value = 1:20
  )
results
spread(results, key = Treatment, value = value)

# example: separate()
df <- data.frame(x = c(NA, "a.b", "a.d", "b.c"))
df %>% separate(x, c("A", "B"))
df %>% separate(x, c("A", "B"), sep = -2)
df %>% separate(x, c("A", "B"), sep = "\\.")

# example 2: separate() - every row doesn't split into the same number of pieces
df <- data.frame(x = c("a", "a b", "a b c", NA))
df %>% separate(x, c("a", "b"))
# the same behaviour but no warnings, fill with missing values on specified side
df %>% separate(x, c("a", "b"), extra = "drop", fill = "right")
df %>% separate(x, c("a", "b"), extra = "drop", fill = "left")
# do not drop extra pieces, only splits at most length(into) times
df %>% separate(x, c("a", "b"), extra = "merge", fill = "right")
df %>% separate(x, c("a", "b", "c"), extra = "merge", fill = "right")

# example: separate_rows()
df <- data.frame(
  x = 1:3,
  y = c("a", "d,e,f", "g,h"),
  z = c("1", "2,3,4", "5,6"),
  stringsAsFactors = FALSE
)
df
separate_rows(df, y, z, convert = TRUE)

# example: unite()
df <- data.frame(
  country = rep(c("Afghan", "Brazil", "China"), each = 2),
  century = rep(c("19", "20"), 3),
  year = rep(c("99", "00"), 3),
  stringsAsFactors = FALSE
)
df
unite(df, century, year, col = "year", sep = "")

# example: gather() + separate() + spread()
# demo("dadmom")

dadmom <- read_dta("http://www.ats.ucla.edu/stat/stata/modules/dadmomw.dta")
dadmom # 3+1 variables in 5 columns

dadmom %>% gather(key, value, named:incm)

dadmom %>% gather(key, value, named:incm) %>%
           separate(key, c("variable", "type"), -2) 

dadmom %>% gather(key, value, named:incm) %>%
           separate(key, c("variable", "type"), -2) %>%
           spread(variable, value, convert = TRUE)


## handling missing values
df <- data.frame(y = LETTERS[1:6], x = c(1, NA, NA, 3, NA, 4))
df
drop_na(df)
fill(df, x, .direction = "up")
replace_na(df, list(x = 2))
fill(df)




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
