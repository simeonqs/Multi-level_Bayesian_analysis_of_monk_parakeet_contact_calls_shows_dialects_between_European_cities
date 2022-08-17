# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 03-08-2021
# Date last modified: 06-08-2021
# Author: Simeon Q. Smeele
# Description: Simple simulation of data that we might get from PCO. This runs the three level model.
# This version adds some noise to the data by assuming that individuals can be rerecorded and that 
# multiple individuals can be recorded in the same recording. 
# This version moves all the code to a function. 
# source('ANALYSIS/CODE/univariate dialect model/02_run_three_levels_noisy.R')
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
path_out = 'ANALYSIS/RESULTS/univariate dialect model/noisy/'

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Run simulations - to compare to clean data
set.seed(1)
path_out_compare = paste0(path_out, 'compare to clean/')
run.noisy.simulation(sd_city = 1,
                     sd_park = 1,
                     sd_ind = 1,
                     sd_obs = 0.1,
                     path_out = path_out_compare)
run.noisy.simulation(sd_city = 0.001,
                     sd_park = 1,
                     sd_ind = 1,
                     sd_obs = 0.1,
                     path_out = path_out_compare)
run.noisy.simulation(sd_city = 1,
                     sd_park = 0.001,
                     sd_ind = 1,
                     sd_obs = 0.1,
                     path_out = path_out_compare)
run.noisy.simulation(sd_city = 1,
                     sd_park = 1,
                     sd_ind = 0.001,
                     sd_obs = 0.1,
                     path_out = path_out_compare)
run.noisy.simulation(sd_city = 0.001,
                     sd_park = 0.001,
                     sd_ind = 1,
                     sd_obs = 0.1,
                     path_out = path_out_compare)
run.noisy.simulation(sd_city = 0.001,
                     sd_park = 0.001,
                     sd_ind = 0.001,
                     sd_obs = 0.1,
                     path_out = path_out_compare)
