# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 04-08-2021
# Date last modified: 10-02-2022
# Author: Simeon Q. Smeele
# Description: Runs the clean simulation for the dialect model. 
# This version takes the base data for number of entries per level.
# This version adds the distance matrix to test the new model. 
# This version uses cmdstanr. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

require(cmdstanr)

run.clean.simulation = function(
  base_data,
  path_model,
  m_dist_parks,
  sd_city = 1,
  sd_park = 0.5,
  sd_ind = 0.3,
  sd_obs = 0.1,
  path_out = NULL
){
  
  # Simulate
  dat = data.frame()
  for(city in unique(base_data$cities)){
    mean_city = rnorm(1, 0, sd_city)
    parks = unique(base_data$parks[base_data$cities == city])
    for(park in parks){
      mean_park = rnorm(1, mean_city, sd_park)
      inds = unique(base_data$id[base_data$parks == park])
      for(ind in inds){
        mean_ind = rnorm(1, mean_park, sd_ind)
        N_obs = length(which(base_data$id == ind))
        dat = rbind(dat,
                    data.frame(
                      city = city,
                      park = park,
                      ind = ind,
                      PC1 = rnorm(N_obs, mean_ind, sd_obs)
                    ))
      }
    }
  }
  
  # Rescale PC1
  dat$PC1 = as.numeric(scale(dat$PC1))
  
  # Translate park such that dmat fits
  trans_park = seq_along(unique(dat$park))
  names(trans_park) = unique(dat$park)
  
  # Add other info
  dat$city = as.integer(as.factor(dat$city))
  dat$park = trans_park[dat$park]
  dat$ind = as.integer(as.factor(dat$ind))
  dat = as.list(dat)
  dat$d_mat = m_dist_parks[names(trans_park), names(trans_park)]/10000 # distance in 10KM
  colnames(dat$d_mat) = rownames(dat$d_mat) = NULL
  dat$N_city = max(dat$city)
  dat$N_park = max(dat$park)
  dat$N_ind = max(dat$ind)
  dat$N_obs = length(dat$PC1)
  
  # Run some checks
  if(length(unique(dat$ind)) != length(unique(base_data$id))) stop('Number inds do not match!')
  if(all(sort(table(dat$park)) != sort(table(base_data$park)))) stop('Parks do not match!')
  
  # Print size dataset and parameters
  parameters = c(sd_city = sd_city,
                 sd_park = sd_park,
                 sd_ind = sd_ind,
                 sd_obs = sd_obs)
  message('\n=================================================================================\n')
  message('Starting model with ', dat$N_obs, ' observations.')
  message('Running with these parameters:')
  print(parameters)
  
  # Run model
  model = cmdstan_model(path_model)
  fit = model$sample(data = dat, 
                     seed = 1, 
                     chains = 4, 
                     parallel_chains = 4,
                     refresh = 500,
                     adapt_delta = 0.95)
  post = fit$draws(format = "df") %>% as.data.frame
  
  # Save
  file = sprintf('%sresults_clean_%s_%s_%s_%s.RData', path_out, sd_city, sd_park, sd_ind, sd_obs)
  save(list = c('parameters', 'post', 'dat'), file = file)
  message('Done. Saved parameters, post and dat.')

} # end function