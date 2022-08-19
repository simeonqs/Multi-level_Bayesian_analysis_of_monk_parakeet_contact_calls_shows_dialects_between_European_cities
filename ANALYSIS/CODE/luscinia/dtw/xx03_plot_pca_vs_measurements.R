# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 31-08-2021
# Date last modified: 31-08-2021
# Author: Simeon Q. Smeele
# Description: Plotting PC's vs measurements to see what they pick up on. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('rethinking', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_pca = 'ANALYSIS/RESULTS/luscinia/dtw/pca_results.RData'
path_dtw = 'ANALYSIS/RESULTS/luscinia/dtw/dtw_results.RData'
path_data = 'ANALYSIS/RESULTS/luscinia/trace measurements/trace_measurements.RData'
path_base_data = 'ANALYSIS/RESULTS'
path_pdf = 'ANALYSIS/RESULTS/luscinia/dtw/pca_vs_measurements.pdf'
path_log = 'ANALYSIS/RESULTS/luscinia/dtw/pca_vs_measurements_log.txt'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
load(path_pca)
load(path_data)
load(path_dtw)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Double check that keys match
if(!out_DTW$key == base_data$key) stop('Keys do not match!')

# Plot
pdf(path_pdf, 10, 5)
par(mfrow = c(1, 2))
for(i in 1:6){
  
  m_dat = brm_dat[[sprintf('y%s', i)]]
  name = c('mean frequcency', 'sd frequency', 'number peaks', 'duration', 'mean freq mod', 'sd freq mod')[i]
  plot(m_dat, pca_out$scores[,1], main = sprintf('%s vs pca_1', name), xlab = name, ylab = 'PCA 1')
  plot(m_dat, pca_out$scores[,2], main = sprintf('%s vs pca_2', name), xlab = name, ylab = 'PCA 2')
  
}
dev.off()

# Report
message('Done.')
write.table(sprintf('key %s.', base_data$key), path_log,
            row.names = F, col.names = F)