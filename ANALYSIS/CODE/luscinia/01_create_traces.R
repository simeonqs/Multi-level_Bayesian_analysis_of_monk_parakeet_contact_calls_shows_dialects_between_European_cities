# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 30-08-2021
# Date last modified: 17-08-2022
# Author: Simeon Q. Smeele
# Description: Loads the raw traces and removes the bad files. Creates the smoothened traces and saves 
# them as a names list in a .RData file. 
# This version also plot the spectrograms and the traces. 
# This version adds a spectrogram without trace to the plot. 
# NOTE: This script requires the raw audio data which is not available. This is only used to plot the 
# spectrograms that are shared. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

library(readxl)
library(data.table)
library(parallel)
library(tidyverse)
library(warbleR)
rm(list = ls())

# Paths
path_traces = 'ANALYSIS/DATA/18_11_traces_luscinia.csv'
path_bad_file_overview = 'ANALYSIS/DATA/Bad_Files_17_11.xlsx'
path_functions = 'ANALYSIS/CODE/functions'
path_base_data = 'ANALYSIS/RESULTS'
path_out = 'ANALYSIS/RESULTS/luscinia/traces.RData'
path_log = 'ANALYSIS/RESULTS/luscinia/traces_log.txt'
path_pdf = 'ANALYSIS/RESULTS/traces on spectrogram/results.pdf'
path_audio = '/Volumes/Elements 4/ALL_AUDIO_2019'
path_selection_tables = 'ANALYSIS/DATA/selection tables'
path_functions = 'ANALYSIS/CODE/functions'

# Import functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Audio files 
audio_files = list.files(path_audio,  '*wav', full.names = T)

# Import selection tables
selection_tables = load.selection.tables(path_selection_tables, split_anno = T)

# Load data
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])
dat = fread(path_traces)

# Subset for files we want to run
dat = dat[dat$Song %in% base_data$luscinia_name,]
if(length(unique(dat$Song)) != length(base_data$file_sel)) stop('Mismatch size Luscinia and base data!')

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Function to fill the gaps
## fills gap with straight line between points
gap.filler = function(time, trace){
  new_time = seq(min(time), max(time), 0.7)
  new_trace = sapply(new_time, function(x){
    y = trace[time == x]
    ifelse(length(y) == 0, NA, y)
  })
  while(any(is.na(new_trace))){
    nas =  which(is.na(new_trace))
    start = nas[1]
    end = nas[which(diff(nas) > 1)[1]]
    if(length(end) == 0) end = start
    if(is.na(end)) end = nas[length(nas)]
    start_value = new_trace[start-1]
    end_value = new_trace[end+1]
    if(is.na(start_value)) start_value = end_value
    if(is.na(end_value)) end_value = start_value
    new_trace[start:end] = seq(start_value, end_value, length.out = 1+end-start)
  }
  return(new_trace)
}

# Extract traces, smoothen and padd
message(sprintf('Starting the smoothening of %s traces...', length(unique(dat$Song))))
calls = unique(dat$Song)
traces = mclapply(calls, function(call){
  trace = dat$Fundamental_frequency[dat$Song == call]
  time = dat$Time[dat$Song == call]
  fit = gap.filler(time, trace)
  new_trace = smooth.spline(fit, spar = 0.4) %>% fitted
  return(new_trace)
}, mc.cores = 4)
names(traces) = base_data$file_sel
save(traces, file = path_out)
message('Done.')

# Plot to pdf
message(sprintf('Plotting %s traces...', length(unique(dat$Song))))
pdf(path_pdf)
par(mfrow = c(2, 1))
for(i in 1:length(traces)){
  trace = dat$Fundamental_frequency[dat$Song == calls[i]]
  time = dat$Time[dat$Song == calls[i]]
  new_trace = traces[[i]]
  rst = which(selection_tables$fs == base_data$file_sel[i])
  file = selection_tables$file[rst]
  wave = readWave(audio_files[audio_files %>% str_detect(file)],
                  from = selection_tables$Begin.Time..s.[rst],
                  to = selection_tables$End.Time..s.[rst], 
                  units = 'seconds')
  wave = ffilter(wave, from = 500, output = 'Wave')
  better.spectro(wave, ylim = c(300, 4000), main = selection_tables$fs[rst])
  points(time/1000, trace, pch = 16, col = alpha(1, 0.5))
  time_new_trace = seq(min(time), max(time), length.out = length(new_trace))/1000
  lines(time_new_trace, 
        new_trace, 
        lwd = 3, col = alpha(3, 0.5))
  td = diff(time)
  test = mapply(td, 0.7, FUN = all.equal) == 'TRUE'
  if(!all(test)){
    tp = time_new_trace[!test]
    fp = new_trace[!test]
    points(tp, fp, col = alpha(4, 0.5), pch = 16, cex = 2)
  }
  better.spectro(wave, ylim = c(300, 4000), main = selection_tables$fs[rst])
}
dev.off()
message('Done.')

# Save
write.table(sprintf('Traces are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)
message(sprintf('Saved %s traces.', length(traces)))