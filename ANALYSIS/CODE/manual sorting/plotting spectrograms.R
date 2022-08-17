# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 22-06-2021
# Date last modified: 25-08-2021
# Author: Simeon Q. Smeele
# Description: Plot all spectrograms in folder per city to sort. 
# This version has a separate section for contact calls only. 
# This version starts on entropy per city.
# This version was moved to the new repo and renamed. Only used for plotting. 
# This version also includes code to not replot already sorted spectrograms, but it fails to include 
# spectrograms that are not at the right level of the folder structure. It plot's an NA-NA.pdf for cities 
# with no unsorted calls. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('data.table', 'tidyverse', 'warbleR', 'parallel', 'oce', 'signal')
for(i in libraries){
  if(! i %in% installed.packages()) lapply(i, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list=ls()) 
dev.off()
cat('\014')  

# File paths
path_audio = '/Users/ssmeele/Desktop/ALL_AUDIO_2019'
path_selection_tables = 'ANALYSIS/DATA/selection tables'
path_spectrograms = '/Users/ssmeele/ownCloud/monk_parakeet_dialect/ANALYSIS/RESULT/sorting spectrograms'
path_overview_recordings = 'ANALYSIS/DATA/overview recordings'
path_overview_parks = 'ANALYSIS/DATA/overview parks'
path_functions = 'ANALYSIS/CODE/functions'
path_good_quality = 'ANALYSIS/RESULTS/quality control/all good.csv'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Import selection tables
selection_tables = load.selection.tables(path_selection_tables)

# Subset for good files
good = read.csv2(path_good_quality, header = F)
good$V1 = good$V1 %>% str_remove('.wav')
selection_tables$file_selec = paste(selection_tables$file, selection_tables$Selection, sep = '-')
selection_tables = selection_tables[selection_tables$file_selec %in% good$V1,]

# Find files
files_overview_recordings = list.files(path_overview_recordings, "*csv", full.names = T)
files_overview_parks = list.files(path_overview_parks, "*csv", full.names = T)

# Load data
overview_recordings = 
  lapply(files_overview_recordings, read.csv2, 
         na.strings = c("", " ", "NA"), stringsAsFactors = F) %>% bind_rows
overview_parks = 
  lapply(files_overview_parks, read.csv2, 
         na.strings = c("", " ", "NA"), stringsAsFactors = F) %>% bind_rows

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS: plotting calls ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Remove the already plotted spectrogram from the selection table
spectrograms_full = list.files(path_spectrograms, recursive = T, full.names = T) %>% 
  strsplit('/') 
spectrograms = sapply(spectrograms_full, function(x) x[length(x)]) %>% 
  str_remove('.pdf') %>% 
  str_remove('.wav')
pasted = paste0(selection_tables$file, '-', selection_tables$Selection)
selection_tables = selection_tables[! pasted %in% spectrograms,]

# Find cities
parks = sapply(selection_tables$file, function(x){
  recording = strsplit(x, '.wav')[[1]][1]
  return(overview_recordings$park[overview_recordings$file == recording])
}) %>% as.character
cities = sapply(parks, function(x) overview_parks$city[which(overview_parks$park == x)]) %>% as.character

# Plot all the spectrograms
city_folders = list.files(path_spectrograms)
for(city in city_folders){
  sub = selection_tables[which(cities == city),]
  if(nrow(sub) == 0){
    message(sprintf('Skipping %s.', city))
    next
  }
  mclapply(1:nrow(sub), function(i){
    file_name = sub$file[i]
    selec = sub$Selection[i]
    pdf(paste0(path_spectrograms, '/', city, '/', file_name, '-', selec, '.pdf'))
    wave = readWave(paste0(path_audio, '/', sub$file[i], '.wav'), 
                    from = sub$Begin.Time..s.[i], 
                    to = sub$End.Time..s.[i], 
                    units = 'seconds')
    wave = ffilter(wave, from = 300, bandpass = TRUE, output = 'Wave') 
    better.spectro(wave, main = ' ', wl = 512, ovl = 450, xlim = c(0, 0.35))
    dev.off()
  })
}

