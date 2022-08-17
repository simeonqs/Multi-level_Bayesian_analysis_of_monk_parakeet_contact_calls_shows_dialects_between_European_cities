# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 26-08-2021
# Date last modified: 16-02-2022
# Author: Simeon Q. Smeele
# Description: Running models on the real data. 
# This version is using the preprocessed data and key. 
# This version uses cmdstanr. 
# source('ANALYSIS/CODE/spcc/03_run_models.R')
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
path_base_data = 'ANALYSIS/RESULTS'
path_functions = 'ANALYSIS/CODE/functions'
path_out = 'ANALYSIS/RESULTS/spcc/models/'
path_pca = 'ANALYSIS/RESULTS/spcc/pca_results.RData'
path_pco = 'ANALYSIS/RESULTS/spcc/pco_results.RData'
path_umap = 'ANALYSIS/RESULTS/spcc/umap_results.RData'
path_dtw = 'ANALYSIS/RESULTS/spcc/dtw_results.RData'
path_model = 'ANALYSIS/CODE/univariate model/m_4.stan'
path_log = 'ANALYSIS/RESULTS/spcc/models/models_log.txt'

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Load data
load(path_pca)
load(path_pco)
load(path_umap)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Find parks
parks = base_data$parks
unique_parks = sort(unique(parks))
trans_parks = 1:length(unique_parks)
names(trans_parks) = unique_parks

# Find cities
cities = base_data$cities

# Translate cities
unique_cities = sort(unique(cities))
trans_cities = 1:length(unique_cities)
names(trans_cities) = unique_cities

# Run different measurements
for(i in 1:6){
  
  # Pick data
  PC_dat = list(pca_out$scores[,1], pca_out$scores[,2], 
                pco_out$vectors[,1], pco_out$vectors[,2],
                as.numeric(umap_out_2D$layout[,1]), as.numeric(umap_out_2D$layout[,2]))[[i]]
  name = c('pca1', 'pca2', 'pco1', 'pco2', 'umap1', 'umap2')[i]
  
  # Combine data
  dat = data.frame(city = trans_cities[cities],
                   park = trans_parks[parks],
                   ind = as.integer(as.factor(base_data$id)),
                   PC1 = scale(PC_dat))
  dat = dat[order(dat$city, dat$park),]
  dat = as.list(dat)
  dat$N_city = max(dat$city)
  dat$N_park = max(dat$park)
  dat$N_ind = max(dat$ind)
  dat$N_obs = length(dat$PC1)
  
  # Print
  message(paste('Starting', name, 'model with', dat$N_obs, 'observations. \n'))
  
  # Run model
  model = cmdstan_model(path_model)
  fit = model$sample(data = dat, 
                     seed = 1, 
                     chains = 4, 
                     parallel_chains = 4,
                     refresh = 500,
                     adapt_delta = 0.95)
  diag = fit$cmdstan_diagnose()  
  post = fit$draws(format = "df") %>% as.data.frame
  
  # Save
  save(list = c('fit', 'post', 'dat', 'trans_cities', 'trans_parks', 'diag'), 
       file = paste0(path_out, name, ' results.RData'))
  
} # End PC_dat loop

# Report
write.table(sprintf('Models are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Finished all models.')