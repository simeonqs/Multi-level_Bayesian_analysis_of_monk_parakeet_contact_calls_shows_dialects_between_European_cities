# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 04-08-2021
# Date last modified: 04-08-2021
# Author: Simeon Q. Smeele
# Description: Plots the output and underlying data.  
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

plot.data.and.est = function(path_file,
                             real = F # set to true if real data
                             ){
  
  load(path_file)
  
  main = ''
  if(!real) main = sprintf('sd_city: %s, sd_park: %s, sd_ind: %s, sd_obs: %s', 
                           parameters[1], parameters[2], parameters[3], parameters[4])
  plot(dat$PC1, pch = 16, col = alpha(1+dat$city, 0.1),
       xlab = 'ID', ylab = 'scaled variable',
       main = main)
  post = extract.samples(model)
  m_mean_per_city = sapply(1:ncol(post$z_city), function(i) 
    mean(sapply(1:nrow(post$z_city), function(j) post$mu_city[j] + post$z_city[j,i] * post$sigma_city[j])))
  city_per_park = sapply(unique(dat$park), function(x) unique(dat$city[dat$park == x]))
  m_mean_per_park = sapply(1:ncol(post$z_park), function(i) 
    mean(sapply(1:nrow(post$z_park), function(j) 
      post$mu_city[j] + 
        post$z_city[j,city_per_park[i]] * post$sigma_city[j] + 
        post$z_park[j,i] * post$sigma_park[j])))
  points(sapply(unique(dat$park), function(x) mean(which(dat$park == x))),
         m_mean_per_park, 
         col = alpha(1+city_per_park, 0.5), 
         pch = 16, cex = 2)
  points(sapply(unique(dat$city), function(x) mean(which(dat$city == x))),
         m_mean_per_city, col = alpha(1+unique(dat$city), 0.8), pch = 16, cex = 4)
  
} # End plot.par.and.est