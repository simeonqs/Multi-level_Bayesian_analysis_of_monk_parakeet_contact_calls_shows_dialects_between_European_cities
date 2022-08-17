# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 30-08-2021
# Date last modified: 17-08-2022
# Author: Simeon Q. Smeele
# Description: Listing all the contact calls that are not found in the Luscinia data base. These files are 
# saved in RESULTS/luscinia/missing_files.csv the key of the data base version is saved in a log file as well.
# This version removes old bad files from the missing files list. 
# source('ANALYSIS/CODE/luscinia/02_list_missing_files.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Start-up
suppressMessages(library(readxl))
suppressMessages(library(tidyverse))
suppressMessages(library(data.table))
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_traces = 'ANALYSIS/DATA/18_11_traces_luscinia.csv'
path_out = 'ANALYSIS/RESULTS/luscinia/missing_files.csv'
path_log = 'ANALYSIS/RESULTS/luscinia/missing_files_log.txt'
path_sort = 'ANALYSIS/RESULT/sorting spectrograms/SIMEON'
path_base_data = 'ANALYSIS/RESULTS'
path_bad_file_overview = 'ANALYSIS/DATA/Bad_Files_17_11.xlsx'
path_old_bad_files = 'ANALYSIS/DATA/Bad_Files_version_old_before_adjusted.xlsx'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
dat = read.csv(path_traces, na.strings = c('', ' ', 'NA'), stringsAsFactors = F)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# List file_sels by translating the weird Luscinia names
poor_names = unique(dat$Song)
file_sels = poor_names 
for(i in 1:length(file_sels)){
  if(str_detect(file_sels[i], '-')){
    split = strsplit(file_sels[i], '-')[[1]]
    file = split[1]
    selection = strsplit(split[2], '_')[[1]][1] %>% as.numeric %>% as.character
    file_sels[i] = paste0(file, '-', selection)
  } else {
    split = strsplit(file_sels[i], '_')[[1]]
    file = paste0(split[1], '_', split[2], '_', split[3], '_', split[4], '.wav')
    selection = strsplit(split[5], '\\.')[[1]][1] %>% as.numeric %>% as.character
    file_sels[i] = paste0(file, '-', selection)
  }
}
file_sels = file_sels %>% str_remove('.wav')

# List what is sorted as contact
sorted_files_full = path_sort %>% list.files(recursive = T, pattern = '.pdf')
sorted_files_split = sorted_files_full %>% str_split('/')
sorted_file_sels = sapply(sorted_files_split, function(split) 
  split[length(split)] %>% str_remove('.pdf'))
sorted_types = sapply(sorted_files_split, function(split) split[length(split)-1])
contact_file_sels = sorted_file_sels[sorted_types %in% c(
  'contact - ladder middle', 'contact - ladder multiple', 'contact - ladder start', 'contact - long start', 
  'contact - mix alarm', 'contact - split', 'contact')] %>% str_remove('.wav')

# Get missing files and exclude previous bad files
old_bad = read_xlsx(path_old_bad_files)
new_bad = read_xlsx(path_bad_file_overview)
bad = bind_rows(old_bad, new_bad)
fsb = unique(bad$`Bad Files`)
for(i in 1:length(fsb)){
  if(str_detect(fsb[i], '-')){
    split = strsplit(fsb[i], '-')[[1]]
    file = split[1]
    selection = strsplit(split[2], '_')[[1]][1] %>% as.numeric %>% as.character
    fsb[i] = paste0(file, '-', selection)
  } else {
    split = strsplit(fsb[i], '_')[[1]]
    file = paste0(split[1], '_', split[2], '_', split[3], '_', split[4], '.wav')
    selection = strsplit(split[5], '\\.')[[1]][1] %>% as.numeric %>% as.character
    fsb[i] = paste0(file, '-', selection)
  }
}
fsb = fsb %>% str_remove('.wav')
missing = contact_file_sels[!contact_file_sels %in% file_sels]
missing = missing[!missing %in% fsb]
if(length(missing) > 0) {
  message(sprintf('Found %s files that are not in the data base.', 
                  length(missing)))
} else message('No missing files.')

# Save
write.csv2(missing, path_out, row.names = F)
write.table(sprintf('Missing files listed for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message('Done.\n')