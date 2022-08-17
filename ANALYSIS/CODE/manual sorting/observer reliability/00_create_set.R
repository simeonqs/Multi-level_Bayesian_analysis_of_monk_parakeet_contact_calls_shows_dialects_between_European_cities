# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 19-09-2021
# Date last modified: 23-02-2022
# Author: Simeon Q. Smeele
# Description: This code lists the contact call variants as Simeon sorted them. Then it randomises the list
# and uses the first 1000 to create a set for verification and the last 1000 as examples for other obervers. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Start-up
suppressMessages(library(readxl))
suppressMessages(library(tidyverse))
suppressMessages(library(data.table))
suppressMessages(library(warbleR))
rm(list = ls())

# Paths
path_out = '~/ownCloud/monk_parakeet_dialect/ANALYSIS/RESULTS/sorting spectrograms/observer reliability'
path_sorting_files = sprintf('%s/master files', path_out)
path_example_files = sprintf('%s/example files', path_out)
path_base_data = 'ANALYSIS/RESULTS'
path_audio = '/Volumes/Elements 4/ALL_AUDIO_2019'
path_selection_tables = 'ANALYSIS/DATA/selection tables'
path_functions = 'ANALYSIS/CODE/functions'
path_good_quality = 'ANALYSIS/RESULTS/quality control/all good.csv'
path_sort = '~/ownCloud/monk_parakeet_dialect/ANALYSIS/RESULTS/sorting spectrograms/SIMEON'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
selection_tables = load.selection.tables(path_selection_tables)

# Subset for good files
good = read.csv2(path_good_quality, header = F)
good$V1 = good$V1 %>% str_remove('.wav')
selection_tables$file_selec = paste(selection_tables$file, selection_tables$Selection, sep = '-')
selection_tables = selection_tables[selection_tables$file_selec %in% good$V1,]

# Get sorted files
sorted_files_full = path_sort %>% list.files(recursive = T, pattern = '.pdf')
sorted_files_split = sorted_files_full %>% str_split('/')
sorted_file_sels = sapply(sorted_files_split, function(split) 
  split[length(split)] %>% str_remove('.pdf')) %>% str_remove('.wav')
sorted_types = sapply(sorted_files_split, function(split) split[length(split)-1]) 

# Randomise
set.seed(1)
key = Sys.time() %>% 
  str_replace_all('-', '_') %>% 
  str_replace_all(':', '_') %>% 
  str_replace_all(' ', '_')
random_index = sample(seq_along(selection_tables$fs))
random_dat = list(random_index = random_index,
                  file_sel = selection_tables$fs[random_index],
                  file = selection_tables$file[random_index],
                  sel = selection_tables$Selection[random_index],
                  base_data_key = base_data$key,
                  random_list_key = key)
random_dat$type = sapply(random_dat$file_sel, function(fs){
  y = sorted_types[sorted_file_sels == fs]
  return(ifelse(length(y) == 0, 'NaN', y))
})

# Save 
save(random_dat, file = sprintf('%s/random_data_%s.RData', path_out, key))

# Save files
path_sorting_files_key = sprintf('%s %s', path_sorting_files, key)
dir.create(path_sorting_files_key)
for(i in 1:1000){
  pdf(paste0(path_sorting_files_key, '/', i, '.pdf'))
  sub = selection_tables[selection_tables$fs == random_dat$file_sel[i],]
  wave = readWave(paste0(path_audio, '/', sub$file, '.wav'), 
                  from = sub$Begin.Time..s., 
                  to = sub$End.Time..s., 
                  units = 'seconds')
  wave = ffilter(wave, from = 300, bandpass = TRUE, output = 'Wave') 
  better.spectro(wave, main = ' ', wl = 512, ovl = 450, xlim = c(0, 0.35))
  dev.off()
}
## Create empty folders
for(type in unique(random_dat$type)) dir.create(sprintf('%s/%s', path_sorting_files_key, type))

# Save examples
l = length(random_dat$random_index)
path_example_files_key = sprintf('%s %s', path_example_files, key)
dir.create(path_example_files_key)
for(type in unique(random_dat$type)) dir.create(sprintf('%s/%s', path_example_files_key, type))
for(i in (l-999):l){
  pdf(paste0(path_example_files_key, '/', random_dat$type[i], '/', i, '.pdf'))
  sub = selection_tables[selection_tables$fs == random_dat$file_sel[i],]
  wave = readWave(paste0(path_audio, '/', sub$file, '.wav'), 
                  from = sub$Begin.Time..s., 
                  to = sub$End.Time..s., 
                  units = 'seconds')
  wave = ffilter(wave, from = 300, bandpass = TRUE, output = 'Wave') 
  better.spectro(wave, main = ' ', wl = 512, ovl = 450, xlim = c(0, 0.35))
  dev.off()
}

