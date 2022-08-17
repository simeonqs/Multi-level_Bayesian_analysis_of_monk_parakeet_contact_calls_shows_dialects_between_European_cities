plot.composite.figure = function(path_data, path_model_1, path_model_2, full_path_pdf, name){
  
  load(path_data)
  pdf(full_path_pdf, 10, 10)
  par(cex.axis = 1.25, cex.lab = 1.25)
  par(mfrow = c(2, 2), mar = c(5.1, 4.1, 2.1, 2.1))
  plot.park.and.city.means(path_model_2, flip = T, lab = 'DIM 2')
  load(path_model_1)
  s = sample(1:length(base_data$cities))
  if(name == 'pco') plot_dat = pco_out$vectors[s,1:2]
  if(name == 'pca') plot_dat = pca_out$scores[s,1:2]
  if(name == 'umap') plot_dat = umap_out_2D$layout[s,]
  plot(apply(plot_dat, 2, scale), 
       col = alpha(colours[trans_cities[base_data$cities][s]], 0.8), pch = 16,
       xlab = 'DIM 1', ylab = 'DIM 2')
  par(mar = c(0, 0, 0, 0))
  plot(NULL, xlim = c(-0.1, 1.1), ylim = c(0, 19), xaxt = 'n', yaxt = 'n',
       xlab = '', ylab = '', bty ='n')
  labels = c()
  cc = c()
  city_per_park = sapply(1:max(dat$park), function(x) unique(dat$city[dat$park == x]))
  for(i in trans_cities){
    cc = c(cc, i)
    labels = c(labels, sprintf('%s. %s', i, names(trans_cities)[i]))
    for(j in which(city_per_park == i)){
      cc = c(cc, i)
      labels = c(labels, sprintf('  %s', names(trans_parks)[j]))
    }
  }
  labels = c(labels, rep('', 3))
  text(rep(c(0, 0.6), each = 18), rep(seq(18, 1, -1), 2), 
       labels, 
       col = alpha(colours[trans_cities[cc]], 0.9),
       adj = 0, cex = 0.9)
  par(mar = c(5.1, 4.1, 2.1, 2.1))
  plot.park.and.city.means(path_model_1, flip = F, lab = 'DIM 1')
  dev.off()
  
}