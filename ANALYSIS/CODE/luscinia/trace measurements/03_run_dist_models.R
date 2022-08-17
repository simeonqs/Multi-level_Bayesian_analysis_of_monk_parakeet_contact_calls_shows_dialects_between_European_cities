# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 23-08-2021
# Date last modified: 21-09-2021
# Author: Simeon Q. Smeele
# Description: Runs the models on the trace measurements from the multivariate model folder. 
# This version was moved and renamed to the new repo. 
# This version runs the dist models. 
# source('ANALYSIS/CODE/luscinia/trace measurements/03_run_dist_models.R')
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
path_pdf = 'ANALYSIS/RESULTS/luscinia/trace measurements/results trace measurements.pdf'
path_model = 'ANALYSIS/CODE/univariate model/m_6.stan'
path_base_data = 'ANALYSIS/RESULTS'
path_data = 'ANALYSIS/RESULTS/luscinia/trace measurements/trace_measurements.RData'
path_out = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results dist/'
path_log = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results log.txt'
path_dist_mat = 'ANALYSIS/RESULTS/dist_parks.RData'

# Load data 
load(path_data)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
load(path_dist_mat)

# Get all data
files = brm_dat$ind
parks = brm_dat$park
cities = brm_dat$city
unique_cities = sort(unique(cities))
trans_cities = 1:length(unique_cities)
names(trans_cities) = unique_cities
unique_parks = sort(unique(parks))
trans_parks = 1:length(unique_parks)
names(trans_parks) = unique_parks

# Run different measurements
for(i in 1:6){
  
  # Pick data
  PC_dat = brm_dat[[sprintf('y%s', i)]]
  name = c('mean frequcency', 'sd frequency', 'number peaks', 'duration', 'mean freq mod', 'sd freq mod')[i]
  
  # Combine data
  dat = data.frame(city = trans_cities[cities],
                   park = trans_parks[parks],
                   ind = as.integer(as.factor(files)),
                   PC1 = scale(PC_dat))
  dat = dat[order(dat$city, dat$park),]
  dat = as.list(dat)
  dat$N_city = max(dat$city)
  dat$N_park = max(dat$park)
  dat$N_ind = max(dat$ind)
  dat$N_obs = length(dat$PC1)
  dat$d_mat = m_dist_parks[names(trans_parks), names(trans_parks)]
  
  # Print
  cat('Starting', name, 'model with', dat$N_obs, 'observations. \n')
  
  # Run model
  model = stan(path_model,
               data = dat, 
               chains = 4, cores = 4,
               iter = 2000, warmup = 500,
               control = list(max_treedepth = 15, adapt_delta = 0.95))
  
  # Save
  save(list = c('model', 'dat', 'trans_cities'), file = paste0(path_out, name, ' results.RData'))
  
  # Print the results
  cat('Here are the results: \n')
  print(precis(model, depth = 1))
  
} # End PC_dat loop

# Save log
write.table(sprintf('Models are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Finished!')