# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: sn model
# Date started: 07-09-2021
# Date last modified: 08-09-2021
# Author: Simeon Q. Smeele
# Description: This function runs the simulation for the data that can be analysed with a social networks
# model. 
# This version is fixed for the fact that park and ind did not increase across cities. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

sim.sn.data = function(settings = list(N_city = 3,
                                        N_park = 3, 
                                        N_ind = 5,
                                        N_var = 5,
                                        lambda_obs = 3,
                                        sigma_city = 1, 
                                        sigma_park = 1,
                                        sigma_ind = 1,
                                        sigma_obs = 0.1),
                        plot_it = F
){
  
  # Simulate
  parks = c()
  cities = c()
  inds = c()
  dat = data.frame()
  pi = 0
  ii = 0
  for(city in 1:settings$N_city){
    means_city = rnorm(settings$N_var, 0, settings$sigma_city)
    for(park in 1:settings$N_park){
      pi = pi + 1
      means_park = rnorm(settings$N_var, means_city, settings$sigma_park)
      for(ind in 1:settings$N_ind){
        ii = ii + 1
        means_ind = rnorm(settings$N_var, means_park, settings$sigma_ind)
        N_obs = rpois(1, settings$lambda_obs)
        if(N_obs == 0) next
        for(obs in 1:N_obs){
          cities = c(cities, city)
          parks = c(parks, pi)
          inds = c(inds, ii)
          dat = rbind(dat, rnorm(settings$N_var, means_ind, settings$sigma_obs))
        }
      }
    }
  }
  parks = as.integer(as.factor(parks))
  inds = as.integer(as.factor(inds))

  # Plot first two variables
  if(plot_it) plot(dat[,1], dat[,2], col = cities, pch = parks)
  
  # Make into distance matrix
  names(dat) = paste0('x', 1:ncol(dat))
  m = as.matrix(dist(dat))
  d = m.to.df(m, cities, parks, inds)
  
  # List data
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
  clean_dat$settings = settings
  
  # Return
  return(clean_dat)
  
} # end function