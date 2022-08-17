# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 20-09-2021
# Date last modified: 17-08-2021
# Author: Simeon Q. Smeele
# Description: Calculating the distance between parks and saving as matrix.  
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Start-up
suppressMessages(library(readxl))
suppressMessages(library(tidyverse))
suppressMessages(library(data.table))
library(geosphere)
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_overview_recordings = 'ANALYSIS/DATA/overview recordings'
path_overview_parks = 'ANALYSIS/DATA/overview parks'
path_out = 'ANALYSIS/RESULTS/dist_parks.RData'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# List files
files_overview_parks = list.files(path_overview_parks, '*csv', full.names = T)

# Load data
overview_parks = 
  lapply(files_overview_parks, read.csv2, 
         na.strings = c('', ' ', 'NA'), stringsAsFactors = F) %>% bind_rows

# Calculate distances
unique_parks = unique(overview_parks$park)
lats = sapply(unique_parks, function(park) overview_parks$lat[overview_parks$park == park][1])
longs = sapply(unique_parks, function(park) overview_parks$long[overview_parks$park == park][1])
l = length(unique_parks)
c = combn(1:l, 2)
out = sapply(1:ncol(c), function(x) {
  i = c[1,x]
  j = c[2,x]
  d = distm (c(longs[i], lats[i]), c(longs[j], lats[j]), fun = distHaversine)
  return( d )
})
out[out>15000] = 100000 # setting all parks 100 km apart if they are from different cities
m_dist_parks = o.to.m(out/1000, unique_parks)
colnames(m_dist_parks) = rownames(m_dist_parks) = unique_parks

# Save
save(m_dist_parks, file = path_out)

# Report
message('Saved the distance matrix.')