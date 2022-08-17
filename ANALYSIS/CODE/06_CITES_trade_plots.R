# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: monk parakeet dialects
# Date started: 20-12-2019
# Date last modified: 12-08-2022
# Author: Simeon Q. Smeele
# Description: Overview of trade of parrots to our cities
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# DATA ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Loading libraries
libraries = c('data.table', 'tidyverse')
for(lib in libraries){
  if(! lib %in% installed.packages()) lapply(lib, install.packages)
  lapply(libraries, require, character.only = TRUE)
}

# Clean R
rm(list=ls()) 

# Load data
dat = read.csv2('ANALYSIS/DATA/trade CITES/comptab_2019-12-11 10_48_semicolon_separated.csv', 
                na.strings = c('', ' ', 'NA'), stringsAsFactors = F)

# Translation table country codes
country.codes = read.csv2('ANALYSIS/DATA/trade CITES/country_codes.csv', 
                          na.strings = c('', ' ', 'NA'), stringsAsFactors = F)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# ANALYSIS ----
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Include only live animals
dat = filter(dat, Term == 'live')

# Which countries to include
countries = c('Spain', 'Greece', 'Belgium', 'Italy')

# Mean of the trade
dat$mean.trade = sapply(1:nrow(dat), function(x){
  mean(c(dat$Importer.reported.quantity[x], dat$Exporter.reported.quantity[x]) %>% as.numeric, na.rm = T)
})

# Translate names
dat$Exporter = sapply(dat$Exporter, function(x){
  y = country.codes$Country_Name[which(country.codes$Two_Letter_Country_Code == x)]
  if(length(y) != 1) return(NA) else return(y)
}) %>% strsplit(',') %>% sapply(`[`, 1)
dat$Importer = sapply(dat$Importer, function(x){
  y = country.codes$Country_Name[which(country.codes$Two_Letter_Country_Code == x)]
  if(length(y) != 1) return(NA) else return(y)
}) %>% strsplit(',') %>% sapply(`[`, 1)


# Loop through countries and plot the exporters
pdf('ANALYSIS/RESULTS/CITES trade/trade graphs.pdf', 7, 5)
sub.dat = filter(dat, Importer %in% countries)
print( 
  ggplot(sub.dat) +
    geom_line(aes(Year, log10(mean.trade), colour = Exporter)) +
    facet_wrap(~ Importer) + 
    labs(title = '', y = 'Trade log10(# individuals)') + 
    theme_light() 
)
dev.off()







