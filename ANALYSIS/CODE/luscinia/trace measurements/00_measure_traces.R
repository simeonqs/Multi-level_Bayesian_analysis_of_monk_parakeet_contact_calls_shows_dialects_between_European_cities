# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 16-08-2021
# Date last modified: 03-09-2021
# Author: Simeon Q. Smeele
# Description: Analysing the Luscinia traces for six spectral measurements and preparing it for statistical
# analysis in later steps. 
# This version was moved to the new repo. 
# This version is running on the preprocessed data. 
# This version plots a fraction of the data and measurements. 
# source('ANALYSIS/CODE/luscinia/trace measurements/00_measure_traces.R')
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('pracma', 'rethinking', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list = ls())

# Paths
path_functions = 'ANALYSIS/CODE/functions'
path_base_data = 'ANALYSIS/RESULTS'
path_traces = 'ANALYSIS/RESULTS/luscinia/traces.RData'
path_log = 'ANALYSIS/RESULTS/luscinia/trace measurements/trace_measurements_log.txt'
path_results = 'ANALYSIS/RESULTS/luscinia/trace measurements/trace_measurements.RData'
path_measures_pdf = 'ANALYSIS/RESULTS/luscinia/trace measurements/measurements on trace.pdf'

# Load functions
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)

# Load data
load(path_traces)
base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

# Test if data matches
if(!all(base_data$file_sel == names(traces))) stop('Mismatch in names!')

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Take measurements
set.seed(1)
measure.spec = function(i, plot_fraq = 1/100){
  if(runif(1, 0, 1) < plot_fraq){
    plot(traces[[i]], main = names(traces)[i], xlab = 'sample', ylab = 'frequency = [Hz]')
    abline(h = mean(traces[[i]]), col = alpha(2, 0.6), lwd = 5, lty = 2)
    abline(h = c(mean(traces[[i]]) - sd(traces[[i]]),
                 mean(traces[[i]]) + sd(traces[[i]])), 
                 col = alpha(2, 0.6), lwd = 3, lty = 2)
    peaks = findpeaks(traces[[i]], nups = 8)
    points(peaks[,2], peaks[,1], col = alpha(3, 0.6), pch = 16, cex = 3)
    text(100, min(traces[[i]]) + 10, sprintf('mean_abs_slope_log: %s', 
                                             round(mean(abs(diff(traces[[i]]))), 3)))
    text(100, min(traces[[i]]) + 200, sprintf('sd_slope_log: %s', 
                                              round(mean(sd(diff(log(traces[[i]])))), 3)))
  }
  return(
    data.frame(
      file = base_data$file[i],
      sel = base_data$selection[i],
      file_sel = base_data$file_sel[i],
      mean_freq_hz = mean(traces[[i]]),
      sd_freq_hz = sd(traces[[i]]),
      n_peaks = length(findpeaks(traces[[i]], nups = 8)),
      duration_samples = max(traces[[i]]) - min(traces[[i]]),
      mean_abs_slope = mean(abs(diff(traces[[i]]))),
      sd_slope_log = sd(diff(log(traces[[i]])))
    )
  )
}
l = length(traces)
message(sprintf('Measuring %s traces...', l))
pdf(path_measures_pdf)
spec_measures = bind_rows(lapply(1:l, measure.spec))
dev.off()
message('Done.')

# Find cities
cities = base_data$cities
if(length(cities) != nrow(spec_measures)) stop('Mismatch in size cities and spec_measurements!')

# Plot
# plot(spec_measures[4:ncol(spec_measures)], pch = 16, col = alpha(city_as_int, 0.5))

# Clean up and save
brm_dat = data.frame(city = cities,
                     park = base_data$parks,
                     ind = base_data$id,
                     y1 = scale(spec_measures$mean_freq_hz),
                     y2 = scale(spec_measures$sd_freq_hz), 
                     y3 = scale(spec_measures$n_peaks),
                     y4 = scale(spec_measures$duration_samples),
                     y5 = scale(spec_measures$mean_abs_slope),
                     y6 = scale(spec_measures$sd_slope_log))

# Save
save(brm_dat, spec_measures, file = path_results)
write.table(sprintf('brm_dat and spec_measures are for dataset with key %s.', base_data$key), path_log,
            row.names = F, col.names = F)

# Report
message(sprintf('Saved measurements for %s traces.', l))
