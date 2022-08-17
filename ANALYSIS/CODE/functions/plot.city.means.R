# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 01-09-2021
# Date last modified: 20-11-2021
# Author: Simeon Q. Smeele
# Description: Plots the means per city.  
# This version works with the cmdstan output. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

require(rethinking)

plot.park.and.city = function(path_file, flip = F){
  
  # Extract post
  load(path_file)
  post = fit$draws(format = "df") %>% as.data.frame
  
  # Calculate posteriors
  city_posts = lapply(1:length(which(str_detect(names(post), 'z_city'))), function(city)
    sapply(1:nrow(post), function(i) 
      post$mu_city[i] + post[[sprintf('z_city[%s]', city)]][i] * post$sigma_city[i]))
  
  # Plot
  if(!flip){
    city_indexes = 1:length(city_posts)
    plot(NULL, xlim = c(-1.2, 1.2), ylim = c(1, length(city_posts)), xlab = '', ylab = '', main = '',
         yaxt = 'n')
    for(i in city_indexes){
      lines(PI(city_posts[[i]], 0.95), rep(i, 2), lwd = 3, col = alpha(i, 0.7))
      lines(PI(city_posts[[i]], 0.9), rep(i, 2), lwd = 5, col = alpha(i, 0.7))
      lines(PI(city_posts[[i]], 0.5), rep(i, 2), lwd = 8, col = alpha(i, 0.7))
    }
    points(sapply(city_posts, mean), city_indexes, 
           pch = 16, col = city_indexes, cex = 3)
  } else {
    city_indexes = 1:length(city_posts)
    plot(NULL, ylim = c(-1.2, 1.2), xlim = c(1, length(city_posts)), xlab = '', ylab = '', main = '')
    for(i in city_indexes){
      lines(rep(i, 2), PI(city_posts[[i]], 0.95), lwd = 3, col = alpha(i, 0.7))
      lines(rep(i, 2), PI(city_posts[[i]], 0.9), lwd = 5, col = alpha(i, 0.7))
      lines(rep(i, 2), PI(city_posts[[i]], 0.5), lwd = 8, col = alpha(i, 0.7))
    }
    points(city_indexes, sapply(city_posts, mean), 
           pch = 16, col = city_indexes, cex = 3)
  }

} 