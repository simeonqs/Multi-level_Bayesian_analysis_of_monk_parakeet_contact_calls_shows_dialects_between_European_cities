# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 09-09-2021
# Date last modified: 16-02-2022
# Author: Simeon Q. Smeele
# Description: Running models on the real data.
# This version includes diagnostics. 
# source('ANALYSIS/CODE/luscinia/cc/01_run_models.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('rethinking', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}
library(cmdstanr)

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_out = 'ANALYSIS/RESULTS/luscinia/cc/models/'
path_pca = 'ANALYSIS/RESULTS/luscinia/cc/pca_results.RData'
path_pco = 'ANALYSIS/RESULTS/luscinia/cc/pco_results.RData'
path_umap = 'ANALYSIS/RESULTS/luscinia/cc/umap_results.RData'
path_cc = 'ANALYSIS/RESULTS/luscinia/cc/cc_results.RData'
path_model = 'ANALYSIS/CODE/univariate model/m_4.stan'
path_base_data = 'ANALYSIS/RESULTS'
path_log = 'ANALYSIS/RESULTS/luscinia/cc/models/models_log.txt'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
load(path_pca)
load(path_pco)
load(path_umap)
load(path_cc)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Double check that keys match
if(!out_CC$key == base_data$key) stop('Keys do not match!')

# Get all data
cities = base_data$cities
unique_cities = sort(unique(cities))
trans_cities = 1:length(unique_cities)
names(trans_cities) = unique_cities

parks = base_data$parks
unique_parks = sort(unique(parks))
trans_parks = 1:length(unique_parks)
names(trans_parks) = unique_parks

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
  message('Starting ', name, ' model with ', dat$N_obs, ' observations.\n')
  
  # Run model
  # model = stan(path_model,
  #              data = dat, 
  #              chains = 4, cores = 1,
  #              iter = 2000, warmup = 500,
  #              control = list(max_treedepth = 15, adapt_delta = 0.95))
  
  model = cmdstan_model(path_model)
  fit = model$sample(data = dat, 
                     seed = 1, 
                     chains = 4, 
                     parallel_chains = 4,
                     refresh = 500)
  diag = fit$cmdstan_diagnose()  
  post = fit$draws(format = "df") %>% as.data.frame
  
  # Save
  save(list = c('fit', 'post', 'dat', 'trans_cities', 'trans_parks', 'diag'), 
       file = paste0(path_out, name, ' results.RData'))
  
} # end i loop

# Report
write.table(sprintf('Models are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Finished all models.')