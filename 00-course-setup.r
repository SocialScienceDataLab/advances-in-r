### -----------------------------
### workshop setup
### simon munzert
### -----------------------------


# install packages from CRAN
p_needed <- c("plyr", # for consistent split-apply-combine functionality
              "dplyr",  # provides data manipulating functions
              "stringr", # for string processing
              "stringi", # more tools for string processing
              "magrittr", #  for piping
              "ggplot2", # for graphics
              "tidyr", # for tidying data frames
              "broom", # for tidying model output
              "janitor", # for basic data tidying and examinations
              "rvest", # web scraping suite
              "codetools", # low level code analysis tools for R
              "pryr", # tools for computing on R and understanding the language at a deeper level
              "babynames", # dataset compiled by Hadley Wickham; contains US baby names provided by the SSA and data on all names used for at least 5 children of either sex
              "nycflights13" # data set on all 336776 flights departing from NYC in 2013
              )
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}

lapply(p_needed, require, character.only = TRUE)
