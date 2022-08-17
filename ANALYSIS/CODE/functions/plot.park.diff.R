# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 06-08-2021
# Date last modified: 25-08-2021
# Author: Simeon Q. Smeele
# Description: Plots the park differences per city.  
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

plot.park.diff = function(path_file,
                          real = F # set to true if real data
){
  
  # Extract post
  load(file)
  post = extract.samples(model)
  
  # Calculate differences
  city_per_park = sapply(unique(dat$park), function(x) unique(dat$city[dat$park == x]))
  diff_parks_per_city = lapply(1:ncol(post$z_city), function(city_i){
    parks = which(city_per_park == city_i)
    if(length(parks) != 1) 
      sapply(2:length(parks), function(park_i) 
        post$z_park[,parks[park_i]] - post$z_park[,parks[1]]) else NULL
  })
  
  # Plot
  main = ''
  if(!real) main = sprintf('sd_city: %s, sd_park: %s, sd_ind: %s, sd_obs: %s', 
                           parameters[1], parameters[2], parameters[3], parameters[4])
  n_diff = sum(unlist(sapply(diff_parks_per_city, ncol)))
  plot(NULL, xlim = c(-3, 3), xlab = 'difference park means', ylim = c(1, n_diff), ylab = 'park', main = main)
  ii = 0
  for(city_i in 1:length(diff_parks_per_city)){
    diff_parks = diff_parks_per_city[[city_i]]
    if(length(diff_parks) == 0) next
    points(apply(diff_parks, 2, mean), (ii+1):(ii+ncol(diff_parks)), 
           pch = 16, cex = 2, col = alpha(city_i+1, 0.8))
    for(i in 1:ncol(diff_parks)) lines(PI(diff_parks[,i]), rep(ii+i, 2), 
                                       col = alpha(city_i+1, 0.8), lwd = 3)
    ii = ii + ncol(diff_parks)
  }
  abline(v = 0, lwd = 3, lty = 2, col = alpha(1, 0.5))
  
} # End plot.city.diff