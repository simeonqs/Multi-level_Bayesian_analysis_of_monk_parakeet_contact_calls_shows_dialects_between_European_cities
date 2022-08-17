# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 17-02-2022
# Date last modified: 15-02-2022
# Author: Simeon Q. Smeele
# Description: Going over diagnostics for all models. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries 
libraries = c('rethinking', 'tidyverse', 'cmdstanr')
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
path_results = 'ANALYSIS/RESULTS'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# List all models
model_files = path_results %>% list.files('*RData', full.names = T, recursive = T)
model_files = model_files[str_detect(model_files, 'models/')]

# Get diagnostics for each file
diags = lapply(model_files, function(model_file){
  load(model_file)
  if('diag' %in% ls()){
    if(diag$status != 0) stop(sprinft('Status %s not 0.', model_file))
    diag$stdout
    return(diag$stdout)
  } else {
    return(NA)
  }
})
rhats = sapply(diags, str_detect, 'Split R-hat values satisfactory all parameters')
if(all(rhats)) message('All rhats are fine.') else message('Some rhats are not fine.')
