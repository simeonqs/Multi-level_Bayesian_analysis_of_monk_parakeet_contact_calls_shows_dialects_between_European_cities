# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 20-09-2021
# Date last modified: 20-09-2021
# Author: Simeon Q. Smeele
# Description: Running the social networks model on the dtw data. 
# NOTE: subsetting for now to test. Also disabled key!
# source('ANALYSIS/CODE/luscinia/dtw/04_run_sn_model.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('rethinking', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Settings
N_sub = 1000

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_out = 'ANALYSIS/RESULTS/luscinia/dtw/models/sn_model.RData'
path_model = 'ANALYSIS/CODE/social networks model/m_3.stan'
path_dtw = 'ANALYSIS/RESULTS/luscinia/dtw/dtw_results.RData'
path_base_data = 'ANALYSIS/RESULTS'
path_log = 'ANALYSIS/RESULTS/luscinia/dtw/models/sn_model_log.txt'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
load(path_dtw)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Double check that keys match
# if(!out_DTW$key == base_data$key) stop('Keys do not match!')

# Clean data
s = sample(seq_along(base_data$file_sel), N_sub, replace = F)
log_o = log(out_DTW$o)
log_o = log_o - min(log_o)
log_o = log_o / max(log_o)
m = o.to.m(log_o, out_DTW$calls)
d = m.to.df(m[s,s], 
            as.integer(as.factor(base_data$cities[s])), 
            as.integer(as.factor(base_data$parks[s])), 
            as.integer(as.factor(base_data$id[s])))
clean_dat = as.list(d)
clean_dat$d = as.numeric(scale(d$d)) # smaller values = closer = more similar
clean_dat$N_city_pair = max(d$city_pair)
clean_dat$N_park_pair = max(d$park_pair)
clean_dat$N_ind_pair = max(d$ind_pair)
clean_dat$N_city = max(d$city_j)
clean_dat$N_park = max(d$park_j)
clean_dat$N_ind = max(d$ind_j)
clean_dat$N_call = max(d$call_j)
clean_dat$N_obs = length(d$call_i)
clean_dat$same_city = sapply(1:max(d$city_pair), function(pair) # 1 = same, 0 = different
  ifelse(clean_dat$city_i[clean_dat$city_pair == pair][1] == 
           clean_dat$city_j[clean_dat$city_pair == pair][1], 1, 0))
clean_dat$same_park = sapply(1:max(d$park_pair), function(pair) # 1 = same, 0 = different
  ifelse(clean_dat$park_i[clean_dat$park_pair == pair][1] == 
           clean_dat$park_j[clean_dat$park_pair == pair][1], 1, 0))
clean_dat$same_ind = sapply(1:max(d$ind_pair), function(pair) # 1 = same, 0 = different
  ifelse(clean_dat$ind_i[clean_dat$ind_pair == pair][1] == 
           clean_dat$ind_j[clean_dat$ind_pair == pair][1], 1, 0))

# Print
message('Starting model with ', clean_dat$N_obs, ' observations.')

# Run model
model = stan(path_model,
             data = clean_dat, 
             chains = 4, cores = 4,
             iter = 2000, warmup = 500,
             control = list(max_treedepth = 15, adapt_delta = 0.95))

# Save
save('model', file = path_out)

# Print the results
message('Here are the results:')
print(precis(model, depth = 1))

# Report
write.table(sprintf('Models are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Finished!')