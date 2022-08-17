# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 30-08-2021
# Date last modified: 17-08-2022
# Author: Simeon Q. Smeele
# Description: Listing all good file_sels from Luscinia. Adding city, park, file and ID-control. Saving
# output as list with data-time to keep track in pipeline. 
# This version has fixed the problem of 5 seconds instead of 5 minutes. 
# This version also makes new id for cases with character(NA).
# This version also stores the manual sorted type. 
# This version merges some call types. 
# This version only includes repo paths. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Start-up
suppressMessages(library(readxl))
suppressMessages(library(tidyverse))
suppressMessages(library(data.table))
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_traces = 'ANALYSIS/DATA/18_11_traces_luscinia.csv'
path_bad_file_overview = 'ANALYSIS/DATA/Bad_Files_17_11.xlsx'
path_overview_recordings = 'ANALYSIS/DATA/overview recordings'
path_overview_parks = 'ANALYSIS/DATA/overview parks'
path_out = 'ANALYSIS/RESULTS'
path_sort = 'ANALYSIS/RESULTS/sorting spectrograms/SIMEON'
path_selection_tables = 'ANALYSIS/DATA/selection tables'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# List files
files_overview_recordings = list.files(path_overview_recordings, '*csv', full.names = T)
files_overview_parks = list.files(path_overview_parks, '*csv', full.names = T)

# Load data
dat = read.csv(path_traces, na.strings = c('', ' ', 'NA'), stringsAsFactors = F)
overview_recordings = 
  lapply(files_overview_recordings, read.csv2, 
         na.strings = c('', ' ', 'NA'), stringsAsFactors = F) %>% bind_rows
overview_parks = 
  lapply(files_overview_parks, read.csv2, 
         na.strings = c('', ' ', 'NA'), stringsAsFactors = F) %>% bind_rows
selection_tables = load.selection.tables(path_selection_tables, split_anno = T)

# Remove bad traces
bad = read_xlsx(path_bad_file_overview)
dat = dat[! dat$Song %in% bad$`Bad Files`,]

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

# Remove short contact etc.
sorted_files_full = path_sort %>% list.files(recursive = T, pattern = '.pdf')
sorted_files_split = sorted_files_full %>% str_split('/')
sorted_file_sels = sapply(sorted_files_split, function(split) 
  split[length(split)] %>% str_remove('.pdf'))
sorted_types = sapply(sorted_files_split, function(split) split[length(split)-1])
contact_file_sels = sorted_file_sels[sorted_types %in% c(
  'contact - ladder middle', 'contact - ladder multiple', 'contact - ladder start', 'contact - long start', 
  'contact - mix alarm', 'contact - split', 'contact', 'contact - four triangles',
  'contact - split')] %>% str_remove('.wav')
message(sprintf('Removed %s traces as non-contact calls.', 
                length(file_sels[!file_sels %in% contact_file_sels])))
dat = dat[dat$Song %in% poor_names[file_sels %in% contact_file_sels],]
poor_names = poor_names[file_sels %in% contact_file_sels]
file_sels = file_sels[file_sels %in% contact_file_sels]
if(! length(unique(file_sels)) == length(unique(dat$Song))) stop('Mismatch between file_sels and dat$Song!')

# Find type per call
cst = str_remove(sorted_file_sels, '.wav')
types = sapply(file_sels, function(file_sel) sorted_types[cst == file_sel]) %>% as.character

# Translate rare types
types[types == 'contact - long start'] = 'contact'
types[types == 'contact - split'] = 'contact'

# Find other info
files = file_sels |> strsplit('-') |> sapply(`[`, 1)
sels = file_sels |> strsplit('-') |> sapply(`[`, 2)
parks = sapply(file_sels, function(x){
  recording = strsplit(x, '-')[[1]][1]
  return(overview_recordings$park[overview_recordings$file == recording])
}) %>% as.character
cities = sapply(parks, function(x) overview_parks$city[which(overview_parks$park == x)]) %>% as.character

# Get ID or 5 min control
id = sapply(file_sels, function(fs){
  file = fs |> strsplit('-') |> sapply(`[`, 1)
  id = selection_tables$individual[selection_tables$fs == fs]
  if(is.na(id)) id = ceiling(selection_tables$Begin.Time..s.[selection_tables$fs == fs]/300)
  if(id == 'NA') id = ceiling(selection_tables$Begin.Time..s.[selection_tables$fs == fs]/300)
  return(paste(file, id, sep = '_'))
}) %>% as.character

# Combine and save with key
key = Sys.time() %>% 
  str_replace_all('-', '_') %>% 
  str_replace_all(':', '_') %>% 
  str_replace_all(' ', '_')
base_data = list(file_sel = file_sels, 
                 luscinia_name = poor_names, 
                 file = files, 
                 selection = sels,
                 parks = parks, 
                 cities = cities,
                 id = id,
                 type = types, 
                 key = key)
save(base_data, file = sprintf('%s/base_data_%s.RData', path_out, key))

# Report
message(sprintf('Saved %s file_sels under key %s.', length(file_sels), key))