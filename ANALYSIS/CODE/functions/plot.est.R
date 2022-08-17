# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 04-08-2021
# Date last modified: 20-11-2021
# Author: Simeon Q. Smeele
# Description: Plots the output and input sigma.  
# This function works with cmdstan output instad of rstan. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

plot.est = function(file, main = ''){
  
  load(file)
  
  post = fit$draws(format = "df") %>% as.data.frame
  
  parameters = c('sigma_city', 'sigma_park', 'sigma_ind', 'sigma_obs')
  
  plot(NULL, pch = 16, cex = 2, col = alpha(1, 0.8), 
       xlim = c(1, 4), ylim = c(-0.5, 2), xaxt = 'n', xlab = '', ylab= '', main = main)
  axis(1, at = 1:length(parameters), labels = parameters)
  ii = 0
  for(x in parameters){
    ii = ii+1
    points(ii, mean(post[[x]]), pch = 16, cex = 1.5, col = alpha(4, 0.8))
    lines(rep(ii, 2), PI(post[[x]]), lwd = 5, col = alpha(4, 0.8))
  }
  abline(h = 0, lty = 2, lwd = 3, col = alpha(1, 0.5))
  
} # End plot.par.and.est