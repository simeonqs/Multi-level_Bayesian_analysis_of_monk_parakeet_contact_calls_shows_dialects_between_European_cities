# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 09-09-2021
# Date last modified: 18-08-2022
# Author: Simeon Q. Smeele
# Description: Simple simulation of univariate data. Simulates same amount of data as real dataset. 
# This version adds the distance matrix to test the new model. 
# source('ANALYSIS/CODE/univariate model/00_simulate_clean.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('rethinking', 'cmdstanr')
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
path_model = 'ANALYSIS/CODE/univariate model/m_4.stan'
path_dist_mat = 'ANALYSIS/RESULTS/dist_parks.RData'

# Load base data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
load(path_dist_mat)

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Run simulations
set.seed(1)
run.clean.simulation(base_data = base_data,
                     path_model = path_model,
                     path_out = path_out,
                     m_dist_parks = m_dist_parks,
                     sd_city = 0.001,
                     sd_park = 0.001,
                     sd_ind = 1,
                     sd_obs = 1)

# Report
message('Finished all simulations!')