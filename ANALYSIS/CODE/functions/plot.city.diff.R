# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 04-08-2021
# Date last modified: 18-08-2022
# Author: Simeon Q. Smeele
# Description: Plots the city differences.  
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

plot.city.diff = function(file,
                          real = F # set to true if real data
                          ){
  
  # Extract post
  load(file)

  # Calculate differences
  diff_cities = lapply(2:length(unique(base_data$cities)), function(i) 
    sapply(1:length(post$sigma_obs), function(j) post[[sprintf('z_city[%s]', i)]][j] - 
             post[[sprintf('z_city[%s]', 1)]][j]))
  
  # Plot
  if(real) main = 'relative to Athens'
  if(!real) main = sprintf('sd_city: %s, sd_park: %s, sd_ind: %s, sd_obs: %s', 
                           parameters[1], parameters[2], parameters[3], parameters[4])
  plot(sapply(diff_cities, mean), 1:length(diff_cities), pch = 16, 
       cex = 2, col = alpha(2+(1:length(diff_cities)), 0.8), 
       xlim = c(-3, 3), xlab = 'difference city means', 
       ylim = c(1, length(diff_cities)+0.5), ylab = 'city', 
       main = main)
  if(real) text(x = rep(3, length(diff_cities)), y = (1:length(diff_cities))+0.25, 
                labels = names(trans_cities)[-1],
                col = alpha(2+(1:length(diff_cities)), 0.8), adj = 1)
  abline(v = 0, lwd = 3, lty = 2, col = alpha(1, 0.5))
  for(i in 1:length(diff_cities)) 
    lines(PI(diff_cities[[i]]), rep(i, 2), col = alpha(2+i, 0.8), lwd = 3)

} # End plot.city.diff