# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: voice paper
# Date started: 28-08-2021
# Date last modified: 20-09-2021
# Author: Simeon Q. Smeele
# Description: Checking the model outputs. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('rethinking', 'tidyverse')
for(i in libraries){
  if(! i %in% installed.packages()) lapply(i, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_model = 'ANALYSIS/RESULTS/social networks model/sim_model.RData'

# Load data
load(path_model)
post = extract.samples(model)

# Plot precis
plot(precis(model))

# Compare slope to prior
prior = rnorm(1e6, 0, 0.5) %>% density
plot(prior, xlim = c(-3, 3), ylim = c(0, 3), main = '',
     xlab = '', ylab = 'density')
polygon(prior, col = alpha('grey', 0.5))
post$b_bar %>% density %>% polygon(col = alpha(4, 0.8))

