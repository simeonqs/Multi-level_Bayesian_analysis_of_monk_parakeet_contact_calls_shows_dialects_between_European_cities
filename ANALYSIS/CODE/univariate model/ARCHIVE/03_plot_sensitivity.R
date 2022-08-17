# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 03-08-2021
# Date last modified: 06-08-2021
# Author: Simeon Q. Smeele
# Description: Plotting the output of the different models. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries 
libraries = c('rethinking')
for(i in libraries){
  if(! i %in% installed.packages()) lapply(i, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/univariate dialect model/functions'
path_pdf_clean = 'ANALYSIS/RESULTS/univariate dialect model/clean/results clean.pdf'
path_models_clean = 'ANALYSIS/RESULTS/univariate dialect model/clean'
path_pdf_noisy = 'ANALYSIS/RESULTS/univariate dialect model/noisy/compare to clean/results noisy.pdf'
path_models_noisy = 'ANALYSIS/RESULTS/univariate dialect model/noisy/compare to clean'

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Plot results clean
pdf(path_pdf_clean, 15, 10)
par(mfrow = c(2, 3))
files = list.files(path_models_clean, '*RData', full.names = T)
for(file in files){
  plot.par.and.est(file)
}
for(file in files){
  plot.city.diff(file)
}
for(file in files){
  plot.park.diff(file)
}
for(file in files){
  plot.data.and.est(file)
}
dev.off()

# Plot results noisy
pdf(path_pdf_noisy, 15, 10)
par(mfrow = c(2, 3))
files = list.files(path_models_noisy, '*RData', full.names = T)
for(file in files){
  plot.par.and.est(file)
}
for(file in files){
  plot.city.diff(file)
}
for(file in files){
  plot.park.diff(file)
}
for(file in files){
  plot.data.and.est(file)
}
dev.off()

# Report
cat('Succesfully plotted the results! \n')

