# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: dialect paper
# Date started: 07-09-2020
# Date last modified: 30-08-2021
# Author: Simeon Q. Smeele
# Description: Working on pixel comparison of contact calls across cities. 
# NOTE: Runs for a long time. Better to run on HPC and set n_cores to multi-thread. 
# Updates:
# This version uses sum to one. 
# This version was moved from chapter II to chapter I, where it belongs. Still uses functions from chapter II.
# This version was moved to the new paper repo. 
# This version has the key. 
# Source with:
# source('ANALYSIS/CODE/spcc/01_run_spcc.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Library
library(tidyverse)
library(parallel)

# Clean R
rm(list=ls()) 

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_spec_objects = 'ANALYSIS/RESULTS/spcc/spec_objects - contact 2019.RData'
path_o = 'ANALYSIS/RESULTS/spcc/o - contact 2019.RData'
path_base_data = 'ANALYSIS/RESULTS'
path_log = 'ANALYSIS/RESULTS/spcc/o - contact 2019_log.txt'

# Settings
n_cores = 40

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
load(path_spec_objects)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Get combinations and run function
message(sprintf('Starting with %s spec_objects... ', length(spec_objects)))
c = combn(1:length(spec_objects), 2)
o = mclapply(1:ncol(c), function(i) sliding.pixel.comparison(spec_objects[[c[1,i]]], spec_objects[[c[2,i]]]),
             mc.cores = n_cores) %>% unlist
o = o/max(o)
o_with_names = list(o = o, names = names(spec_objects))
save(o_with_names, file = path_o)
write.table(sprintf('spec_objects are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Done.')