# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: dialect paper
# Date started: 07-09-2020
# Date last modified: 16-02-2022
# Author: Simeon Q. Smeele
# Description: Creating the spec objects the be run on cluster. 
# This version works with the preprocessed data. 
# source('ANALYSIS/CODE/spcc/00_create_spec_objects.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('data.table', 'tidyverse', 'signal', 'parallel', 'oce', 'warbleR')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list=ls()) 

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_audio = '/Volumes/Elements 4/ALL_AUDIO_2019'
path_spec_objects = 'ANALYSIS/RESULTS/spcc/spec_objects - contact 2019.RData'
path_selection_tables = 'ANALYSIS/DATA/selection tables'
path_base_data = 'ANALYSIS/RESULTS'
path_log = 'ANALYSIS/RESULTS/spcc/spec_objects_log.txt'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Audio files 
audio_files = list.files(path_audio,  '*wav', full.names = T)

# Import selection tables
selection_tables = load.selection.tables(path_selection_tables, split_anno = T)
selection_tables = selection_tables[selection_tables$fs %in% base_data$file_sel,]
rownames(selection_tables) = selection_tables$fs
selection_tables = selection_tables[base_data$file_sel,]
if(nrow(selection_tables) != length(base_data$file_sel) |
   any(selection_tables$fs != base_data$file_sel)) stop('Mismatch selection_tables and base_data!')

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Report
message('Starting... ')

# Generate spec_ojects
spec_objects = sapply(1:nrow(selection_tables), function(i){
  file = selection_tables$file[i]
  wave = readWave(audio_files[audio_files %>% str_detect(file)],
                  from = selection_tables$Begin.Time..s.[i],
                  to = selection_tables$End.Time..s.[i], 
                  units = 'seconds')
  wave = ffilter(wave, from = 500, output = 'Wave')
  spec_object = cutted.spectro(wave, freq_range = c(1000, 6000), plot_it = F, 
                              thr_low = 1.3, thr_high = 1.8,
                              wl = 512, ovl = 450, 
                              method = 'sd',
                              sum_one = T)
  return(spec_object)
})
names(spec_objects) = selection_tables$fs

# Test example
image(t(spec_objects[[4]]), col = hcl.colors(12, 'Blue-Yellow', rev = T)) 

# Save spec_objects for cluster
save(spec_objects, file = path_spec_objects)

# Report
write.table(sprintf('spec_objects are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message(sprintf('Created %s spec_objects.', length(spec_objects)))