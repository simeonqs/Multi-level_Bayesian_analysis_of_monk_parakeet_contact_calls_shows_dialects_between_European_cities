# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 14-09-2021
# Date last modified: 11-02-2022
# Author: Simeon Q. Smeele
# Description: Simple simulation of univariate data. Simulates same amount of data as real dataset.
# This script includes mislabeling of three types. 
# source('ANALYSIS/CODE/univariate model/01_simulate_noisy.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('rethinking')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_out = 'ANALYSIS/RESULTS/univariate model/'
path_base_data = 'ANALYSIS/RESULTS'
path_model = 'ANALYSIS/CODE/univariate model/m_5.stan'

# Load base data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Run simulations
set.seed(1)
for(lambda_rerec in seq(1, 2, 0.25))
  for(p_next_chunk in seq(0, 0.7, 0.1))
    run.noisy.simulation(base_data = base_data,
                         path_model = path_model,
                         path_out = path_out,
                         sd_city = 0.001,
                         sd_park = 0.001,
                         sd_ind = 1,
                         sd_obs = 1,
                         lambda_ind_per_rec = 1.5,
                         lambda_rerec = lambda_rerec,
                         p_next_chunk = p_next_chunk)

# Report
message('Finished all simulations!')