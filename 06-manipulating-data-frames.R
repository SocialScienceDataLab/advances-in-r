### -----------------------------
## advanced R & recent advances in R
## simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


## manipulating data frames with dplyr ----------

# dplyr, by Hadley Wickham, provides a flexible grammar of data manipulation
# three main goals
  # identify the most important data manipulation verbs and make them easy to use from R
  # provide fast performance for in-memory data
  # use the same interface to work with data no matter where it's stored, whether in a data frame, data table or database.

# get data from nycflights13 package
# source: [https://goo.gl/8hlrJb]
# info about the dataset:
browseURL("http://www.transtats.bts.gov/DatabaseInfo.asp?DB_ID=120&Link=0")
dat <- flights %>% as.data.frame
head(dat)

# filter observations
filter(dat, month == 1, day == 1) %>% head()
slice(dat, 1:10)

# arrange rows
arrange(dat, dep_time, arr_time) %>% head()
dat[order(dat$dep_time, dat$arr_time),] %>% head()
arrange(dat, desc(dep_time), arr_time)	

# select variables
select(dat, year, month, day) %>% head
select(dat, year:day) %>% head
select(dat, -(year:day)) %>% head
select(dat, contains("time")) %>% head
  # also possible: starts_with("abc"), ends_with("xyz"), matches("(.)\\1"), num_range("x", 1:3)
?select_helpers


# extract unique rows
distinct(dat, tailnum) %>% head # similar to base::unique(), but faster

# rename variables
select(dat, tail_num = tailnum) %>% head
rename(dat, tail_num = tailnum) %>% head

# create variables (add new columns)
mutate(dat, gain = arr_delay - dep_delay, speed = distance / air_time * 60) %>% head
mutate(dat, gain = arr_delay - dep_delay, gain_per_hour = gain / (air_time / 60)) %>% head # you can even refer to columns that you've created in the same call!

# create variables, only keep new ones
transmute(dat, gain = arr_delay - dep_delay, gain_per_hour = gain / (air_time / 60)) %>% head

# summarize values; colapse data frame into single row
summarize(dat, delay_mean = (mean(dep_delay, na.rm = TRUE)))

# randomly sample rows
sample_n(dat, 10) %>% dim
?sample_n

sample_frac(dat, .01) %>% dim

# grouped operations with group_by()
  # verbs above are useful on their own, but...
  # can be applied to groups of observations within a dataset
  # group_by() helps you break down your dataset into specified groups of rows
  # afterwards, applying verbs from above on the grouped object, they'll be automatically applied by group
  # very convenient: same syntax applies!

unique(dat$tailnum) %>% length
by_tailnum <- group_by(dat, tailnum)
class(by_tailnum)

delay <- summarise(by_tailnum,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dist < 2000)

ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area()

# useful functions to feed summarise with
destinations <- group_by(dat, dest)
summarise(destinations,
          planes = n_distinct(tailnum), # equivalent to length(unique(x))
          flights = n()
)


## manipulating data frames with data.table ----------

# another popular kid on the blog
# focus on performance, i.e. dealing with large datasets (GBs of data)
# not immediately intuitive syntax
# to learn more, visit
browseURL("https://www.datacamp.com/courses/data-analysis-the-data-table-way")
browseURL("https://github.com/Rdatatable/data.table/wiki")


######################
### IT'S YOUR SHOT ###
######################

# 1. Find all flights that 
  # a) Had an arrival delay of two or more hours
  # b) Arrived more than two hours late, but didn't leave late
  # c) have a missing dep_time - and speculate why this might be the case by looking at other variables.

# 2. Which flights travelled longest, which shortest?

# 3. Does the result of running the following code surprise you? If no, explain! If yes, figure out why the output looks how it looks!
select(dat, contains("TIME")) %>% View

# 4. Find the 10 most delayed flights using a ranking function. How do you want to handle ties? Have a look at ?min_rank and ?rank first!

# 5. Which carrier has the worst delays, which ranks best?

# 6. Delays are typically temporally correlated: even once the problem that caused the initial delay has been resolved, later flights are delayed to allow earlier flights to leave. Using lag() explore how the delay of a flight is related to the delay of the immediately preceding flight.
