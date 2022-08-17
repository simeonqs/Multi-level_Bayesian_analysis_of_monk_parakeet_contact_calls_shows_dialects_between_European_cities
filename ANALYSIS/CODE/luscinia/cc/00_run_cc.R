# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 08-09-2021
# Date last modified: 18-11-2021
# Author: Simeon Q. Smeele
# Description: Runs simple cross correlation on the traces. 
# source('ANALYSIS/CODE/luscinia/cc/00_run_cc.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('data.table', 'tidyverse', 'ape', 'parallel', 'umap')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Settings
n_cores = 4

# Paths
path_base_data = 'ANALYSIS/RESULTS'
path_traces = 'ANALYSIS/RESULTS/luscinia/traces.RData'
path_out = 'ANALYSIS/RESULTS/luscinia/cc/'
path_log = 'ANALYSIS/RESULTS/luscinia/cc/cc_results.txt'
path_cc = paste0(path_out, 'cc_results.RData')
path_pco = paste0(path_out, 'pco_results.RData')
path_pca = paste0(path_out, 'pca_results.RData')
path_umap = paste0(path_out, 'umap_results.RData')
path_functions = 'ANALYSIS/CODE/functions'
path_pdf_pca = paste0(path_out, 'PCA cities.pdf')
path_pdf_pco = paste0(path_out, 'PCO cities.pdf')
path_pdf_umap = paste0(path_out, 'UMAP cities.pdf')

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
load(path_traces)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Length of the original data
l = length(traces)

# Combinations
c = combn(1:l, 2)

# Running through the combinations -  DTW
message(sprintf('Starting CC for %s traces...', l))
out = mclapply(1:ncol(c), function(x) {
  i = c[1,x]
  j = c[2,x]
  cc_out = simple.cc(traces[[i]], traces[[j]], norm = T)
  return( cc_out )
}, mc.cores = n_cores) %>% unlist # end running through the combinations
out_CC = list(o = out,
              calls = names(traces),
              key = base_data$key)
write.table(sprintf('CC is for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
save(out_CC, file = path_cc) # save output
message('Done.')

# Report
message('Starting conversion to matrix... ')

# Transform to similarity matrix
o = out_CC$o/max(out_CC$o)
m = o.to.m(o, out_CC$calls)

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

# Plot PCO and colour by city
colours_cities = c('#CB4335', '#884EA0', '#2471A3', '#17A589', '#F1C40F', '#E67E22', '#34495E', '#E91E63')
city_codes = base_data$cities %>% as.factor %>% as.numeric
city_colours = colours_cities[city_codes]
pdf(path_pdf_pco, 7, 5)
plot(pco_out$vectors[,1], pco_out$vectors[,2], pch = 16, col = alpha(city_colours, 0.7), cex = 1,
     xlab = 'PC1', ylab = 'PC2', xlim = c(-0.6, 0.4), ylim = c(-0.3, 0.3))
legend('topleft', unique(base_data$cities), col = unique(city_colours), pch = 16, bty = 'n', pt.cex = 1)
dev.off()

# Plot PCA and colour by city
pdf(path_pdf_pca, 7, 5)
plot(pca_out$loadings[,1], pca_out$loadings[,2], pch = 16, col = alpha(city_colours, 0.7), cex = 1,
     xlab = 'PC1', ylab = 'PC2')
legend('bottomleft', unique(base_data$cities), col = unique(city_colours), pch = 16, bty = 'n', pt.cex = 1)
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
legend('topright', unique(base_data$cities), col = unique(city_colours), pch = 16, bty = 'n', pt.cex = 1)
dev.off()
# umap_out_1D = umap(m, n_components = 1, n_neighbors = 10, spread = 1, min_dist = 0.1)
save(umap_out_2D, file = path_umap)

# Report
message('Done.')
message(sprintf('Saved data for %s recordings.', nrow(m)))