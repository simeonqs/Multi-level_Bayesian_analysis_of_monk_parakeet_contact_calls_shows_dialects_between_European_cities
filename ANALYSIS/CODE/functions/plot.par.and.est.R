# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 04-08-2021
# Date last modified: 04-08-2021
# Author: Simeon Q. Smeele
# Description: Plots the output and input sigma.  
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

plot.par.and.est = function(file){
  
  load(file)
  
  post = extract.samples(model)
  
  plot(parameters, pch = 16, cex = 2, col = alpha(1, 0.8), 
       xlim = c(1, 4.5), ylim = c(-0.5, 2), xaxt = 'n', xlab = '', main = dat$N_obs)
  axis(1, at = 1:length(parameters), labels = names(parameters))
  ii = 0
  for(x in c('sigma_city', 'sigma_park', 'sigma_ind', 'sigma_obs')){
    ii = ii+1
    points(ii+0.2, mean(post[x][[1]]), pch = 16, cex = 1.5, col = alpha(4, 0.8))
    lines(rep(ii+0.2, 2), PI(post[x][[1]]), lwd = 5, col = alpha(4, 0.8))
  }
  
} # End plot.par.and.est