# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 21-09-2021
# Date last modified: 21-09-2021
# Author: Simeon Q. Smeele
# Description: Plotting the results of the distance models. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries 
libraries = c('rethinking', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(lib, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_base_data = 'ANALYSIS/RESULTS'
path_pdf = 'ANALYSIS/RESULTS/luscinia/trace measurements/results - distance.pdf'
path_models = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results dist'
path_log = 'ANALYSIS/RESULTS/luscinia/trace measurements/pdf_dist_log.txt'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Plot results
pdf(path_pdf, 5, 5)
files = list.files(path_models, '*RData', full.names = T)
for(file in files){
  name = file %>% 
    str_remove('ANALYSIS/RESULTS/luscinia/trace measurements/model results dist/') %>% 
    str_remove(' results.RData')
  load(file)
  post = extract.samples(model)
  plot(NULL, xlab = 'distance [km]', ylab = 'covariance',
       xlim = c(0,15) , ylim = c(0,1.5), main = name)
  x_seq = seq(from = 0, to = 10, length.out = 1000)
  set.seed(1)
  for(i in 1:20) curve( rexp(1, 2)*exp(-rexp(1, 2)*x^2) , add = TRUE ,
                        col = alpha(1, 0.4), lwd = 4)
  for(i in sample(seq_along(post$etasq), 20)){
    curve( post$etasq[i]*exp(-post$rhosq[i]*x^2) , add = TRUE ,
           col = alpha('darkblue', 0.6), lwd = 4)
  }
}
dev.off()

# Report
write.table(sprintf('PDFs are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Succesfully plotted the results! \n')