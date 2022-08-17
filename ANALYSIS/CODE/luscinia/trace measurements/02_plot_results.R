# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 05-08-2021
# Date last modified: 30-08-2021
# Author: Simeon Q. Smeele
# Description: Plotting the output and raws of the trace measurements.  
# This version was moved and renamed to the new repo. 
# source('ANALYSIS/CODE/luscinia/trace measurements/02_plot_results.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries 
libraries = c('rethinking', 'tidyverse')
for(i in libraries){
  if(! i %in% installed.packages()) lapply(i, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_base_data = 'ANALYSIS/RESULTS'
path_pdf = 'ANALYSIS/RESULTS/luscinia/trace measurements/results.pdf'
path_models = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results'
path_log = 'ANALYSIS/RESULTS/luscinia/trace measurements/pdf_log.txt'

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Plot results
pdf(path_pdf, 10, 10)
par(mfrow = c(2, 2))
files = list.files(path_models, '*RData', full.names = T)
for(file in files){
  name = file %>% 
    str_remove('ANALYSIS/RESULTS/luscinia/trace measurements/model results/') %>% 
    str_remove(' results.RData')
  plot.est(file, main = name)
  plot.city.diff(file, real = T)
  plot.park.diff(file, real = T)
  plot.data.and.est(file, real = T)
}
dev.off()

# Report
write.table(sprintf('PDFs are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
cat('Succesfully plotted the results! \n')