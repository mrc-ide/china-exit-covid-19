# This script file is designed to work well with the typical report
# that contains one Rmd file that needs compiling into an docx (or
# other).  If you want to do something like pass parameters, generate
# more than one rendered file, etc, replace this file with your own.
rmd <- dir(pattern = ".Rmd")
if (length(rmd) != 1L) {
  stop("More than one Rmd is present, please edit script.R")
}
rmarkdown::render(rmd)
