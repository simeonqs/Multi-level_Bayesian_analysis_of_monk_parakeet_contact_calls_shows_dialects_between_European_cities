# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 01-09-2021
# Date last modified: 18-02-2022
# Author: Simeon Q. Smeele
# Description: This script plots the final figures for the paper.
# This version was adapted for the new results with more parks. 
# This version also has code for the trace measurements. 
# This version used the cmdstan output. 
# This version includes other colours. 
# This version plots all results and moves plotting to a function. 
# source('ANALYSIS/CODE/02_plot_final_figures.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries 
libraries = c('rethinking', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, function(lib) 
    suppressMessages(require(lib, character.only = TRUE, quietly = TRUE)))
}
library(cmdstanr)

# Clear R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_base_data = 'ANALYSIS/RESULTS'
path_pco = 'ANALYSIS/RESULTS/luscinia/dtw/pco_results.RData'
path_pco_1 = 'ANALYSIS/RESULTS/luscinia/dtw/models/pco1 results.RData'
path_pco_2 = 'ANALYSIS/RESULTS/luscinia/dtw/models/pco2 results.RData'
path_mes = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results'
path_mes_data = 'ANALYSIS/RESULTS/luscinia/trace measurements/trace_measurements.RData'
path_log = 'ANALYSIS/RESULTS/figures/figures_log.txt'
path_results = 'ANALYSIS/RESULTS'
path_pdf = 'ANALYSIS/RESULTS/figures'
path_pco_figure = 'ANALYSIS/RESULTS/figures/fig_pco_paper.pdf'
path_measurements_figure = 'ANALYSIS/RESULTS/figures/Luscinia - measurements.pdf'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Colours
colours = c("#88CCEE", "#CC6677", "#DDCC77", "#117733", "#332288", 
            "#44AA99", "#882255", "#661100", "#888888")
colours = palette.colors(n = 9, palette = "Classic Tableau")

# Plot all results
for(method in c('luscinia/cc', 'luscinia/dtw', 'spcc')){
  for(dim_method in c('pco', 'pca', 'umap')){
    full_path_pdf = sprintf('%s/composite figure %s - %s.pdf', 
                            path_pdf, str_replace(method, '/', ' - '), dim_method)
    path_data = sprintf('%s/%s/%s_results.RData', path_results, method, dim_method)
    path_model_1 = sprintf('%s/%s/models/%s1 results.RData', path_results, method, dim_method)
    path_model_2 = sprintf('%s/%s/models/%s2 results.RData', path_results, method, dim_method)
    plot.composite.figure(path_data, path_model_1, path_model_2, full_path_pdf, dim_method)
    full_path_pdf_sigmas = sprintf('%s/sigmas %s - %s.pdf', 
                                   path_pdf, str_replace(method, '/', ' - '), dim_method)
    plot.sigmas(path_model_1, path_model_2, full_path_pdf_sigmas)
  }
}

# Plot results Luscinia - DTW - PCO for paper
{
  load(path_pco)
  pdf(path_pco_figure, 10, 10)
  par(cex.axis = 1.25, cex.lab = 1.25)
  par(mfrow = c(2, 2), mar = c(5.1, 4.1, 2.1, 2.1))
  plot.park.and.city.means(path_pco_2, flip = T, lab = 'PC 2')
  text(35, 1.4, 'a)', font = 2, cex = 1.5)
  load(path_pco_1)
  s = sample(1:length(base_data$cities))
  plot(apply(pco_out$vectors[s,1:2], 2, scale), 
       col = alpha(colours[trans_cities[base_data$cities][s]], 0.8), pch = 16,
       xlab = 'PC 1', ylab = 'PC 2')
  text(-2.35, 2.33, 'b)', font = 2, cex = 1.5)
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
  plot.park.and.city.means(path_pco_1, flip = F, lab = 'PC 1')
  text(-1.4, 2.5, 'c)', font = 2, cex = 1.5)
  dev.off()
}

# Plot results measurements
{
  pdf(path_measurements_figure, 5, 5)
  files = list.files(path_mes, '*RData', full.names = T)
  par(las = 2)
  par(mar=c(8,5,1,1))
  plot(NULL, xlim = c(1, 6.5), ylim = c(0, 1), xaxt = 'n', xlab = '', ylab = 'sigma')
  ms = files %>% 
    str_remove('ANALYSIS/RESULTS/luscinia/trace measurements/model results/') %>%
    str_remove(' results.RData')
  axis(1, seq_along(ms), ms, )
  for(i in seq_along(files)){
    load(files[i])
    points(i, 
           mean(post$sigma_city), 
           pch = 16, col = alpha(2, 0.8))
    lines(rep(i, 2), 
          PI(post$sigma_city), 
          lwd = 3, col = alpha(2, 0.8))
    points(i + 0.2, 
           mean(post$sigma_park), 
           pch = 16, col = alpha(3, 0.8))
    lines(rep(i + 0.2, 2), 
          PI(post$sigma_park), 
          lwd = 3, col = alpha(3, 0.8))
  }
  legend('topright', c('sigma city', 'sigma_park'), text.col = c(2, 3))
  dev.off()
}

# Plot composit figures for the measurements
load(path_mes_data)
{
  full_path_pdf = sprintf('%s/composite figure %s - %s.pdf', 
                          path_pdf, 'luscinia', 'mean frequency + number peaks')
  path_model_1 = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results/mean frequcency results.RData'
  path_model_1 = 'ANALYSIS/RESULTS/luscinia/trace measurements/model results/number peaks results.RData'
  pdf(full_path_pdf, 10, 10)
  par(cex.axis = 1.25, cex.lab = 1.25)
  par(mfrow = c(2, 2), mar = c(5.1, 4.1, 2.1, 2.1))
  plot.park.and.city.means(path_model_2, flip = T, lab = 'DIM 2')
  load(path_model_1)
  s = sample(1:length(base_data$cities))
  plot_dat = brm_dat[,c('y1', 'y3')]
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

# Report
write.table(sprintf('Figures are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('\nSuccesfully plotted the final figures!\n')