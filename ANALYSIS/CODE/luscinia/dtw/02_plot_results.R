# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 05-08-2021
# Date last modified: 28-08-2021
# Author: Simeon Q. Smeele
# Description: Plotting the output and raws of the real data. 
# This version plots results for PCO1 and PCA1. 
# This version was moved to the new repo and path names fixed. 
# source('ANALYSIS/CODE/luscinia/dtw/02_plot_results.R')
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
path_pdf = 'ANALYSIS/RESULTS/luscinia/dtw/results.pdf'
path_pdf_pca = 'ANALYSIS/RESULTS/luscinia/dtw/results_city_pca.pdf'
path_models = 'ANALYSIS/RESULTS/luscinia/dtw/models'
path_log = 'ANALYSIS/RESULTS/luscinia/dtw/pdf_log.txt'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Plot results
pdf(path_pdf, 10, 10)
par(mfrow = c(2, 2))
files = list.files(path_models, '*RData', full.names = T)
for(file in files){
  name = file %>% 
    str_remove('ANALYSIS/RESULTS/luscinia/dtw/models/') %>% 
    str_remove(' results.RData')
  plot.est(file, main = name)
  plot.city.diff(file, real = T)
  plot.park.diff(file, real = T)
  plot.data.and.est(file, real = T)
}
dev.off()

# Plot result PCA1 and PCA2
pdf(path_pdf_pca, 10, 5)
par(mfrow = c(1, 2))
files = files[str_detect(files, 'pca')]
for(file in files){
  name = file %>% 
    str_remove('ANALYSIS/RESULTS/luscinia/dtw/models/') %>% 
    str_remove(' results.RData')
  plot.city.diff(file, real = T)
}
dev.off()

# Report
write.table(sprintf('PDFs are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Succesfully plotted the results! \n')