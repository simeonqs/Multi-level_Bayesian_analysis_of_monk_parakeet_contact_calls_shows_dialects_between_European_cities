# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 01-09-2021
# Date last modified: 11-02-2022
# Author: Simeon Q. Smeele
# Description: Plots the means per city and park.  
# Adding option for other axis name. 
# This version was adapted for the new data with more parks. 
# This version works with the cmdstan output. 
# This version includes other colours. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

require(rethinking)

plot.park.and.city.means = function(path_file, 
                                    lab = '',
                                    flip = F){
  
  # Extract post
  load(path_file)

  # Calculate posteriors
  city_posts = lapply(1:length(which(str_detect(names(post), 'z_city'))), function(city)
    sapply(1:nrow(post), function(i) 
      post$mu_city[i] + post[[sprintf('z_city[%s]', city)]][i] * post$sigma_city[i]))
  
  # Calculate posteriors
  city_per_park = sapply(1:max(dat$park), function(x) unique(dat$city[dat$park == x]))
  park_posts = lapply(1:max(dat$park), function(park_i)
    sapply(1:nrow(post), function(i) 
      post$mu_city[i] + 
        post[[sprintf('z_city[%s]', city_per_park[park_i])]][i] * post$sigma_city[i] +
        post[[sprintf('z_park[%s]', park_i)]][i] * post$sigma_park[i]))
  
  # Plot
  if(!flip){
    
    plot(NULL, xlim = c(-1.5, 1.5), ylim = c(36, 1), xlab = lab, ylab = '', main = '', yaxt = 'n')
    
    # Run through cities
    ii = 0
    for(city_index in 1:dat$N_city){
      
      ii = ii + 1
      
      # Plot city
      lines(PI(city_posts[[city_index]], 0.95), rep(ii, 2), lwd = 3, col = alpha(colours[city_index], 0.7))
      lines(PI(city_posts[[city_index]], 0.9), rep(ii, 2), lwd = 5, col = alpha(colours[city_index], 0.7))
      lines(PI(city_posts[[city_index]], 0.5), rep(ii, 2), lwd = 8, col = alpha(colours[city_index], 0.7))
      points(mean(city_posts[[city_index]]), ii, 
             pch = 16, col = colours[city_index], cex = 2)
      
      # Find parks in city
      parks_in_city = which(city_per_park == city_index)
      for(park_index in parks_in_city){
        ii = ii + 1
        lines(PI(park_posts[[park_index]], 0.95), rep(ii, 2), lwd = 1, col = alpha(colours[city_index], 0.7))
        lines(PI(park_posts[[park_index]], 0.9), rep(ii, 2), lwd = 2, col = alpha(colours[city_index], 0.7))
        lines(PI(park_posts[[park_index]], 0.5), rep(ii, 2), lwd = 3, col = alpha(colours[city_index], 0.7))
        points(mean(park_posts[[park_index]]), ii, 
               pch = 16, col = colours[city_index], cex = 1)
      }
      
      
    } # end city index
    
    
  } else {
    
    plot(NULL, ylim = c(-1.5, 1.5), xlim = c(36, 1), xlab = '', ylab = lab, main = '', xaxt = 'n')
    
    # Run through cities
    ii = 0
    for(city_index in 1:dat$N_city){
      
      ii = ii + 1
      
      # Plot city
      lines(y = PI(city_posts[[city_index]], 0.95), x = rep(ii, 2), 
            lwd = 3, col = alpha(colours[city_index], 0.7))
      lines(y = PI(city_posts[[city_index]], 0.9), x = rep(ii, 2), 
            lwd = 5, col = alpha(colours[city_index], 0.7))
      lines(y = PI(city_posts[[city_index]], 0.5), x = rep(ii, 2), 
            lwd = 8, col = alpha(colours[city_index], 0.7))
      points(y = mean(city_posts[[city_index]]), x = ii, 
             pch = 16, col = colours[city_index], cex = 2)
      
      # Find parks in city
      parks_in_city = which(city_per_park == city_index)
      for(park_index in parks_in_city){
        ii = ii + 1
        lines(y = PI(park_posts[[park_index]], 0.95), x = rep(ii, 2), 
              lwd = 1, col = alpha(colours[city_index], 0.7))
        lines(y = PI(park_posts[[park_index]], 0.9), x = rep(ii, 2), 
              lwd = 2, col = alpha(colours[city_index], 0.7))
        lines(y = PI(park_posts[[park_index]], 0.5), x = rep(ii, 2), 
              lwd = 3, col = alpha(colours[city_index], 0.7))
        points(y = mean(park_posts[[park_index]]), x = ii, 
               pch = 16, col = colours[city_index], cex = 1)
      }
      
    } # end city_index
    
  } # end else

} # end function