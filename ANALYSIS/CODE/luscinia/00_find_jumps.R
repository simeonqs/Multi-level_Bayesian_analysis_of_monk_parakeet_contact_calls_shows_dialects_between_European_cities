# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 05-08-2021
# Date last modified: 17-08-2022
# Author: Simeon Q. Smeele
# Description: Find the jumps in the good Luscinia traces. 
# This version was moved to the new repo and path adjusted. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

library(readxl)
library(data.table)

# Paths
path_traces = 'ANALYSIS/DATA/18_11_traces_luscinia.csv'
path_bad_file_overview = 'ANALYSIS/DATA/Bad_Files_17_11.xlsx'

# Load data
dat = fread(path_traces)

# Remove bad traces
bad = read_xlsx(path_bad_file_overview)
dat = dat[! dat$Song %in% bad$`Bad Files`,]

# Run through files and save the names of the ones with jumps
calls = unique(dat$Song)
problem = sapply(calls, function(x){
  times = dat$Time[dat$Song == x]
  # return(any(diff(times) < 0))
  return(any(diff(times) < 0))
})

# Report
if(length(which(problem)) > 0){
  message('These traces had problems:')
  cat(paste0(calls[problem], '\n'))
} else message('No problems found.')

# Plot problem
sub = dat[dat$Song == names(problem[1])]
plot(sub$Time, sub$Fundamental_frequency, type = 'b')
