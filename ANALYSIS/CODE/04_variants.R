# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 03-02-2022
# Date last modified: 13-09-2023
# Author: Simeon Q. Smeele
# Description: Plotting examples of typical call per city. Plotting overview of repertoire distribution. 
# This version renames the 'normal' contact call to 'typical'.
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

library(tidyverse)
library(lava)
library(warbleR)

path_base_data = 'ANALYSIS/RESULTS'

base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

dat = base_data
dat$key = NULL
dat = as.data.frame(dat)

# List all counts per city - and plot ----
colfunc = colorRampPalette(c('#0072b2', '#cc79a7', '#d55e00'))
pdf('ANALYSIS/RESULTS/figures/variant_plot.pdf', 7, 7)
cities = sort(unique(dat$cities), decreasing = T)
types = sort(unique(dat$type))
par(mar = c(8, 5, 1, 5))
plot(NULL, xlim = c(0.5, length(types) + 0.5), ylim = c(0.5, length(cities) + 0.5), 
     xaxt = 'n', yaxt = 'n', xlab = '', ylab = '')
for(city in cities){
  t = nrow(dat[dat$cities == city,])
  for(type in types){
    n = nrow(dat[dat$cities == city & dat$type == type,])
    col = colfunc(10)[ceiling(10*(n/t)+1e-6)]
    points(which(types == type), which(cities == city), pch = 15, cex = 6,
           col = alpha(col, 0.8))
    text(which(types == type), which(cities == city), n)
  }
}
names_types = str_remove(types, 'contact - ')
names_types[1] = 'typical'
axis(1, 1:length(types), names_types, las = 2)
axis(2, 1:length(cities), cities, las = 2)
colorbar(clut = colfunc(6),
         x.range = c(7.2, 7.5),
         y.range = c(1, 4),
         values = seq(0, 10, 2) * 10,
         srt = 0,
         direction = 'vertical')
dev.off()

# Plot examples of spectrograms ----
path_audio = '/Users/ssmeele/Desktop/ALL_AUDIO_2019'
path_selection_tables = 'ANALYSIS/DATA/selection tables'
selection_tables = load.selection.tables(path_selection_tables, split_anno = T)
rownames(selection_tables) = selection_tables$fs
audio_files = list.files(path_audio,  '*wav', full.names = T)
path_functions = 'ANALYSIS/CODE/functions'
.functions = sapply(list.files(path_functions, pattern = '*R', full.names = T), source)
files = c(typical = '2019_11_15_082342-9', 
          four_triangles = '2019_11_30_103252-48',
          ladder_start = '2019_11_15_171944-60', 
          ladder_middle = '2019_11_10_150310-51',
          ladder_multiple = '2019_11_30_135428-24',
          mix_alarm = '2019_11_13_155630-40')
pdf('~/Desktop/spectrograms.pdf', 10, 7)
par(mfrow = c(2, 3), oma = c(2, 2, 2, 2))
for(i in 1:6){
  split = files[i] %>% str_split('-')
  wave = readWave(audio_files[audio_files %>% str_detect(split[[1]][1])],
                  from = selection_tables[files[i],]$Begin.Time..s.,
                  to = selection_tables[files[i],]$End.Time..s., 
                  units = 'seconds')
  wave = ffilter(wave, from = 200, output = 'Wave')
  better.spectro(wave, xlim = c(0, 0.25))
  text(0.02, 20000, c('a)', 'b)', 'c)', 'd)', 'e)', 'f)')[i], font = 2)
}
dev.off()



