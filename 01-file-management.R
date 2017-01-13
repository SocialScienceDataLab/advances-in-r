### -----------------------------
### advanced R & recent advances in R
### simon munzert
### -----------------------------


## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


## introduction ------------------

# interacting with the file system  can be very useful to keep your research reproducible
# example tasks:
  # fully implement a workflow based on relative, not absolute paths
  # create a rigid folder structure
  # download files in a specific folder
  # check whether file exists
  # remove temporarily stored files


## functions for folder management ---------

(current_folder <- getwd())
dir.create("data")

# get all pre-compiled data sets
dat <- as.data.frame(data(package = "datasets")$results)
dat$Item %<>% str_replace(" \\(.+\\)", "")

# store data sets in local folder
for (i in 1:50) {
  try(df_out <- dat$Item[i] %>% as.character %>% get)
  save(df_out, file = paste0("data/", dat$Item[i], ".RData"))
}

# inspect folder
dir("data")
filenames <- dir("data", full.names = TRUE)
dir("data", pattern = "US")
dir("data", pattern = "US", ignore.case = TRUE)

# check if folder exists
dir.exists("data")


## functions for file management --------
?files

# get basename (= returns the lowest level in a path)
filenames
basename(filenames)
url <- "http://www.mzes.uni-mannheim.de/d7/en/news/media-coverage/ist-die-wahlforschung-in-der-krise-der-undurchschaubare-buerger"
browseURL(url)
basename(url)

# get dirname (returns all but the lower level in a path)
dirname(url)

# get file information
file_inf <- file.info(dir(recursive = F))
?file.info
file_inf[difftime(Sys.time(), file_inf[,"mtime"], units = "days") < 7 , 1:4]


# identify file extension
tools::file_ext(filenames)

# check if file exists
file.exists(filenames)
file.exists("voterfile.RData")

# rename file
filenames_lower <- tolower(filenames)
file.rename(filenames, filenames_lower)

# remove file
file.remove(filenames_lower[1])

# copy file
file.copy(filenames_lower[2], to = "copy.rdata")
file.remove("copy.rdata")

# choose file
(foo <- file.choose())

# compress and unzip files
?zip
?unzip
?tar
?untar

# create temporary files or directories
tempfile()
tempdir()

# normalize paths
normalizePath(c(R.home(), tempdir()))
normalizePath(c(R.home(), tempdir()), winslash = '/')

# expand file paths
path.expand("~/data")




######################
### IT'S YOUR SHOT ###
######################

# go to the following webpage.
url <- "http://www.cses.org/datacenter/module4/module4.htm"
browseURL(url)

# the following piece of code identifies all links to resources on the webpage and selects the subset of links that refers to the survey questionnaire PDFs.
library(rvest)
page_links <- read_html(url) %>% html_nodes("a") %>% html_attr("href")
survey_pdfs <- str_subset(page_links, "/survey")

# set up folder data/cses-pdfs.

# download a sample of 10 of the survey questionnaire PDFs into that folder using a for loop and the download.file() function.

# check if the number of files in the folder corresponds with the number of downloads and list the names of the files.

# inspect the files. which is the largest one?

# zip all files into one zip file.



