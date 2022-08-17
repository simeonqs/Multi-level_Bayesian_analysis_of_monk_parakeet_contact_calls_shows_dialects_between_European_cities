# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: voice paper
# Date started: 10-09-2021
# Date last modified: 10-09-2021
# Author: Simeon Q. Smeele
# Description: Checking the model outputs. 
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
path_model = 'ANALYSIS/RESULTS/univariate model/results_clean_1_1_1_0.1.RData'

# Load data
load(path_model)
post = extract.samples(model)

# Plot precis
plot(precis(model))

# Plot data
plot(dat$city + runif(length(dat$city), -0.1, 0.1), dat$PC1, col = dat$park)

t = precis(model, depth = 3)
View(t)

rhats = t$Rhat4[str_detect(t@row.names, 'ind')]
plot(dat$PC1, col = ifelse(rhats[dat$ind] > 1.1, 2, 1), pch = dat$park)
