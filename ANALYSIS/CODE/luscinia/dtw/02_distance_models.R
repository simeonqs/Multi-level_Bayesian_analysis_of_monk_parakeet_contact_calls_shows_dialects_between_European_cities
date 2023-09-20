# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter I
# Date started: 17-02-2023
# Date last modified: 17-02-2023
# Author: Simeon Q. Smeele
# Description: Modelling the effect of distance within park. 
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
path_functions = 'ANALYSIS/CODE/functions'
path_pco = 'ANALYSIS/RESULTS/luscinia/dtw/pco_results.RData'
path_base_data = 'ANALYSIS/RESULTS'
path_model = 'ANALYSIS/CODE/univariate model/m_5.stan'
path_dist_parks = 'ANALYSIS/RESULTS/dist_parks.RData'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
load(path_pco)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
load(path_dist_parks)

# Bind pco on base_data
pco_1_2 = as.data.frame(pco_out$vectors[,1:2])
binded = cbind(base_data, pco_1_2)

# Subset data for only Athens
sub = binded
sub$key = NULL
sub = as.data.frame(sub)
sub = sub[sub$cities == 'Athens',]

# Combine data
dat = data.frame(park = as.integer(as.factor(sub$parks)),
                 ind = as.integer(as.factor(sub$id)),
                 PC = scale(sub$Axis.1))
dat = as.list(dat)
dat$N_park = max(dat$park)
dat$N_ind = max(dat$ind)
dat$N_obs = length(dat$PC)

# Create dmat
dat$dmat = m_dist_parks[sub$parks, sub$parks]
dat$dmat = dat$dmat/max(dat$dmat)

# Run model
model = cmdstan_model(path_model)
fit = model$sample(data = dat, 
                   seed = 1, 
                   chains = 4, 
                   parallel_chains = 4,
                   refresh = 500,
                   adapt_delta = 0.95)
fit$output_files() %>%
  rstan::read_stan_csv() %>%
  precis()
post = fit$output_files() %>%
  rstan::read_stan_csv() %>%
  extract.samples()

# Plot
pdf('~/Desktop/distance result - Athens.pdf', 5, 5)
plot(NULL, xlab = '', ylab = '',
     xlim = c(0, 1) , ylim = c(0, 4), main = 'Athens', cex = 2, cex.axis = 1.25, cex.main = 1.5)
mtext('normalised distance', 1, 3, cex = 1)
mtext('covariance', 2, 3, cex = 1)
x_seq <- seq(from = 0, to = 1, length.out = 1000)
for(i in 1:20){
  curve( post$etasq[i]*exp(-post$rhosq[i]*x^2) , add = TRUE ,
         col = alpha('black', 0.4), lwd = 4)
}
dev.off()


