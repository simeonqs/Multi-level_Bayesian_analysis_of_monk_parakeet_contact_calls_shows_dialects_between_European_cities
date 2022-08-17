# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 07-09-2021
# Date last modified: 20-09-2021
# Author: Simeon Q. Smeele
# Description: Simple simulation of data that we might get from spcc. 
# source('ANALYSIS/CODE/social networks model/01_simulate_data.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('data.table', 'tidyverse', 'rethinking')
for(i in libraries){
  if(! i %in% installed.packages()) lapply(i, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Settings
set.seed(1)
settings = list(N_city = 3,
                N_park = 3, 
                N_ind = 3,
                N_var = 2,
                lambda_obs = 3,
                sigma_city = 1, 
                sigma_park = 0.5,
                sigma_ind = 1,
                sigma_obs = 0.1)

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_out = 'ANALYSIS/RESULTS/social networks model/sim_dat.RData'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Simulate
set.seed(1)
clean_dat = sim.sn.data(settings, plot_it = T)

# Save
save(clean_dat, file = path_out)

# Report
message(sprintf('Simulated %s calls. Saved a total of %s data points.',
                clean_dat$N_call, clean_dat$N_obs))
