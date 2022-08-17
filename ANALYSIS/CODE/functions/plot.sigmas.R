plot.sigmas = function(path_1, path_2, path_pdf){
  
  pdf(path_pdf, 5, 5)
  plot(NULL, xlim = c(-0.5, 3), ylim = c(0, 1), xaxt = 'n', xlab = '', ylab = 'sigma')
  axis(1, c(0.25, 2.25), c('DIM 1', 'DIM 2'))
  ii = 0
  for(path in c(path_1, path_2)){
    load(path)
    points(ii + 0, 
           mean(post$sigma_park), 
           pch = 16, col = alpha(2, 0.8))
    lines(rep(ii + 0, 2), 
          PI(post$sigma_park), 
          lwd = 3, col = alpha(2, 0.8))
    points(ii + 00.5, 
           mean(post$sigma_city), 
           pch = 16, col = alpha(3, 0.8))
    lines(rep(ii + 00.5, 2), 
          PI(post$sigma_city), 
          lwd = 3, col = alpha(3, 0.8))
    ii = 2
  }
  legend('topleft', legend = c('park', 'city'), pch = 16, lty = 1, 
         col = alpha(2:3, 0.8))
  
  dev.off()
  
}