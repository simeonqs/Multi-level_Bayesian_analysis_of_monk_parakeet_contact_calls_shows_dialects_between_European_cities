# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: dialect paper
# Date started: 01-10-2021
# Date last modified: 04-10-2021
# Author: Simeon Q. Smeele
# Description: Running distance model on DTW data. 
# source('ANALYSIS/CODE/social networks model/04_run_dist_dtw.R')
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
path_dtw = 'ANALYSIS/RESULTS/luscinia/dtw/dtw_results.RData'
path_base_data = 'ANALYSIS/RESULTS'
path_dist_mat = 'ANALYSIS/RESULTS/dist_parks.RData'
path_model = 'ANALYSIS/CODE/social networks model/m_dist_2.stan'
path_out = 'ANALYSIS/RESULTS/social networks model/dist_model.RData'
  
# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
load(path_dtw)
load(path_dist_mat)

# Prepare data
set.seed(1)
subber = sample(seq_along(base_data$file_sel), 500)
if(!out_DTW$key == base_data$key) stop('Version error.')
m = o.to.m(out_DTW$o, out_DTW$calls)
d = m.to.df(m[subber, subber], base_data$cities[subber], base_data$parks[subber], base_data$id[subber])
clean_dat = d
clean_dat$d = as.numeric(scale(d$d)) # smaller values = closer = more similar
clean_dat$same_city = sapply(d$city_pair, function(pair) # 1 = same, 0 = different
  ifelse(clean_dat$city_i[clean_dat$city_pair == pair][1] == 
           clean_dat$city_j[clean_dat$city_pair == pair][1], 1, 0))
clean_dat$same_park = sapply(d$park_pair, function(pair) # 1 = same, 0 = different
  ifelse(clean_dat$park_i[clean_dat$park_pair == pair][1] == 
           clean_dat$park_j[clean_dat$park_pair == pair][1], 1, 0))

# Subset for same city
clean_dat = clean_dat[clean_dat$same_city == 1,]
clean_dat = clean_dat[clean_dat$same_park == 0,]
clean_dat$dist = sapply(seq_along(clean_dat$park_pair), function(x){
  m_dist_parks[clean_dat$park_i[x], clean_dat$park_j[x]]
})

# Reformat and add other info
clean_dat$city = as.integer(as.factor(clean_dat$city_i))
clean_dat[c('ind_i', 'ind_j', 'park_i', 'park_j', 'city_i', 'city_j', 'ind_pair',
            'call_i', 'call_j', 'city_pair', 'same_city', 'same_park')] = NULL
clean_dat = as.list(clean_dat)
clean_dat$park_pair = as.integer(as.factor(clean_dat$park_pair))
clean_dat$N_park_pair = max(clean_dat$park_pair)
clean_dat$N_obs = length(clean_dat$d)
clean_dat$N_city = max(clean_dat$city)

# Plot
# plot(log(clean_dat$dist), clean_dat$d, col = clean_dat$city)
# plot(clean_dat$dist, clean_dat$d, col = clean_dat$city)

# Run model
model = stan(path_model,
             data = clean_dat, 
             chains = 4, cores = 4,
             iter = 2000, warmup = 500,
             control = list(max_treedepth = 15, adapt_delta = 0.95))

# Save
save(list = c('model', 'clean_dat'), file = path_out)

# Print the results
message('Here are the results:\n')
print(precis(model, depth = 1))