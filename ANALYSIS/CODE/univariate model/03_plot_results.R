# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter II
# Date started: 09-09-2021
# Date last modified: 18-02-2022
# Author: Simeon Q. Smeele
# Description: Plotting the output of the different models. 
# This version has been rewritten to plot the sensitivity analysis. 
# This version used cmdstanr. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries 
libraries = c('rethinking')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_models = 'ANALYSIS/RESULTS/univariate model'
path_pdf_city = 'ANALYSIS/RESULTS/univariate model/results sensitivity analysis city.pdf'
path_pdf_park = 'ANALYSIS/RESULTS/univariate model/results sensitivity analysis park.pdf'
path_example = 'ANALYSIS/RESULTS/univariate model/results_noisy_0.001_0.001_1_1_1.5_1.5_0.4.RData'
path_example_figure = 'ANALYSIS/RESULTS/figures/sensitivity analysis figure.pdf'
path_pco_1 = 'ANALYSIS/RESULTS/luscinia/dtw/models/pco1 results.RData'
path_pco_2 = 'ANALYSIS/RESULTS/luscinia/dtw/models/pco2 results.RData'
path_actual_sigmas = 'ANALYSIS/RESULTS/univariate model/sigmas real data.pdf'

# Load functions
.functions = sapply(list.files(path_functions, 
                               pattern = '*R', full.names = T), source)

# Plot results clean
{
  pdf(path_pdf_city, 12, 5)
  files = list.files(path_models, '*RData', full.names = T)
  noisy_no_signal_files = files[str_detect(files, 'noisy_0.001_0.001')]
  settings = noisy_no_signal_files %>% str_split('_')
  lambda_ind_per_rec = settings %>% sapply(`[`, 7) %>% as.numeric
  lambda_rerec = settings %>% sapply(`[`, 8) %>% as.numeric
  p_next_chunk = settings %>% sapply(`[`, 9) %>% str_remove('.RData') %>% as.numeric
  ls = unique(lambda_rerec)
  ps = unique(p_next_chunk)
  ## Sigma city
  plot(NULL, xlim = c(0, 0.9), ylim = c(0, 1), xaxt = 'n', xlab = 'p next chunk', ylab = 'sigma city')
  axis(1, ps + 1.5/40, ps)
  load(files[str_detect(files, 'clean')])
  lr = 0
  points(0 + lr/80, 
         mean(post$sigma_city), 
         pch = 16, col = alpha(lr+1, 0.8))
  lines(rep(0 + lr/80, 2), 
        PI(post$sigma_city), 
        lwd = 3, col = alpha(lr+1, 0.8))
  for(i in seq_along(noisy_no_signal_files)){
    load(noisy_no_signal_files[i])
    lr = as.integer(as.factor(lambda_rerec))[i]
    points(p_next_chunk[i] + lr/80, 
           mean(post$sigma_city), 
           pch = 16, col = alpha(lr+1, 0.8))
    lines(rep(p_next_chunk[i] + lr/80, 2), 
          PI(post$sigma_city), 
          lwd = 3, col = alpha(lr+1, 0.8))
  }
  legend('topright', c('clean', paste0('lambda rerec = ', ls)), 
         text.col = 1:(length(ls)+1))
  dev.off()
}

## Sigma park
{
  pdf(path_pdf_park, 12, 5)
  plot(NULL, xlim = c(0, 0.9), ylim = c(0, 1), xaxt = 'n', xlab = 'p next chunk', ylab = 'sigma park')
  axis(1, ps + 1.5/40, ps)
  load(files[str_detect(files, 'clean')])
  lr = 0
  points(0 + lr/80, 
         mean(post$sigma_park), 
         pch = 16, col = alpha(lr+1, 0.8))
  lines(rep(0 + lr/80, 2), 
        PI(post$sigma_park), 
        lwd = 3, col = alpha(lr+1, 0.8))
  for(i in seq_along(noisy_no_signal_files)){
    load(noisy_no_signal_files[i])
    lr = as.integer(as.factor(lambda_rerec))[i]
    points(p_next_chunk[i] + lr/80, 
           mean(post$sigma_park), 
           pch = 16, col = alpha(lr+1, 0.8))
    lines(rep(p_next_chunk[i] + lr/80, 2), 
          PI(post$sigma_park), 
          lwd = 3, col = alpha(lr+1, 0.8))
  }
  ll = levels(as.factor(lambda_rerec))
  legend('topright', c('clean', paste0('lambda rerec = ', ls)), 
         text.col = 1:(length(ls)+1))
  dev.off()
}

# Plot example data
load(path_example)
colours = palette.colors(n = 9, palette = "Classic Tableau")
pdf(path_example_figure, 10, 5)
{
  par(cex.axis = 1.25, cex.lab = 1.25)
  par(mfrow = c(1, 2), mar = c(5.1, 4.1, 2.1, 2.1))
  plot.park.and.city.means(path_example, flip = T, lab = 'PC 1')
  text(34, 1.1, 'a)', font = 2, cex = 1.5)
  s = sample(1:length(dat$PC1))
  plot(dat$PC1[s], 
       col = alpha(colours[dat$city[s]], 0.8), pch = 16,
       xlab = 'sample index', ylab = 'PC 1')
  text(100, 2.5, 'b)', font = 2, cex = 1.5)
  dev.off()
}

# Plot actual model results
{
  pdf(path_actual_sigmas, 5, 5)
  plot(NULL, xlim = c(-0.5, 3), ylim = c(0, 1), xaxt = 'n', xlab = '', ylab = 'sigma')
  axis(1, c(0.25, 2.25), c('PC 1', 'PC 2'))
  ii = 0
  for(path in c(path_pco_1, path_pco_2)){
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
    message(sprintf('Mean sigma cities %s: %s, PI: %s-%s. Mean sigma parks: %s, PI: %s-%s.',
                    path,
                    mean(post$sigma_city), PI(post$sigma_city)[1], PI(post$sigma_city)[2],
                    mean(post$sigma_par), PI(post$sigma_park)[1], PI(post$sigma_park)[2]))
  }
  legend('topleft', legend = c('park', 'city'), pch = 16, lty = 1, 
         col = alpha(2:3, 0.8))
  
  dev.off()
}


# Report
message('Succesfully plotted the results!')