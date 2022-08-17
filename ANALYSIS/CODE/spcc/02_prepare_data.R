# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: chapter I 
# Date started: 07-09-2020
# Date last modified: 01-09-2021
# Author: Simeon Q. Smeele
# Description: Preparing the spcc data for the model. Runs PCA, PCO and UMAP. Plots variables. 
# This version is using the key and preprocessed data. 
# source('ANALYSIS/CODE/spcc/02_prepare_data.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('tidyverse', 'ape', 'umap')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list=ls()) 

# Paths
path_base_data = 'ANALYSIS/RESULTS'
path_functions = 'ANALYSIS/CODE/functions'
path_o = 'ANALYSIS/RESULTS/spcc/o - contact 2019.RData'
path_pco = 'ANALYSIS/RESULTS/spcc/pco_results.RData'
path_pca = 'ANALYSIS/RESULTS/spcc/pca_results.RData'
path_umap = 'ANALYSIS/RESULTS/spcc/umap_results.RData'
path_pdf_pco = 'ANALYSIS/RESULTS/spcc/PCO cities.pdf'
path_pdf_pca = 'ANALYSIS/RESULTS/spcc/PCA cities.pdf'
path_pdf_umap = 'ANALYSIS/RESULTS/spcc/UMAP cities.pdf'
path_log = 'ANALYSIS/RESULTS/spcc/results_log.txt'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load previous result
load(path_o)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Check match
if(!all(base_data$file_sel == o_with_names$names)) stop('Mismatch in names!')

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Report
message('Starting conversion to matrix... ')

# Make matrix
n = o_with_names$names
files = n %>% str_split('-') %>% sapply(`[`, 1)
m = o.to.m(o_with_names$o, n)

# Report
message('Done.\nStarting PCO... ')

# PCO
pco_out = pcoa(m)
save(pco_out, file = path_pco)

# Report
message('Done.\nStarting PCA... ')

# PCA
pca_out = princomp(as.dist(m))
save(pca_out, file = path_pca)

# Report
message('Done.')

# Find parks
parks = base_data$parks

# Find cities
cities = base_data$cities

# Plot PCO and colour by city
colours_cities = c('#CB4335', '#884EA0', '#2471A3', '#17A589', '#F1C40F', '#E67E22', '#34495E', '#E91E63')
city_codes = cities %>% as.factor %>% as.numeric
city_colours = colours_cities[city_codes]
pdf(path_pdf_pco, 7, 5)
plot(pco_out$vectors[,1], pco_out$vectors[,2], pch = 16, col = alpha(city_colours, 0.7), cex = 1,
     xlab = 'PC1', ylab = 'PC2', xlim = c(-0.6, 0.4), ylim = c(-0.3, 0.3))
legend('topleft', unique(cities), col = unique(city_colours), pch = 16, bty = 'n', pt.cex = 1)
dev.off()

# Plot PCA and colour by city
pdf(path_pdf_pca, 7, 5)
plot(pca_out$scores[,1], pca_out$scores[,2], pch = 16, col = alpha(city_colours, 0.7), cex = 1,
     xlab = 'PC1', ylab = 'PC2')
legend('bottomright', unique(cities), col = unique(city_colours), pch = 16, bty = 'n', pt.cex = 1)
plot(pca_out)
dev.off()

# Report
message('Starting UMAP... ')

# UMAP
set.seed(1)
umap_out_2D = umap(m, input = 'dist', n_neighbors = 10, spread = 1, min_dist = 0.1)
pdf(path_pdf_umap, 7, 5)
plot(umap_out_2D$layout[,1], umap_out_2D$layout[,2], pch = 16, col = alpha(city_colours, 0.7),
     xlab = 'UMAP DIM 1', ylab = 'UMAP DIM 2')
legend('bottomleft', unique(cities), col = unique(city_colours), pch = 16, bty = 'n', pt.cex = 1)
dev.off()
save(umap_out_2D, file = path_umap)

# Report
message('Done.')

# Report
write.table(sprintf('UMAP, PCO and PCA are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message(sprintf('Saved data for %s recordings.', length(parks)))