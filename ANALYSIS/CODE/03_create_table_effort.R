# Creating table with sample effort

library(tidyverse)

path_base_data = 'ANALYSIS/RESULTS'

base_files = list.files(path_base_data, 'base_data*', full.names = T)
load(base_files[length(base_files)])

dat = base_data
dat$key = NULL
dat = as.data.frame(dat)

out = data.frame(park = unique(dat$parks))
out$city = sapply(out$park, function(p) dat$cities[dat$parks == p][1])
out = out[,c(2,1)]
out$n_days = sapply(out$park, function(p){
  sub = dat[dat$parks == p,]
  dates = sub$file %>% str_sub(1, 10)
  return(length(unique(dates)))
})
out$n_calls = sapply(out$park, function(p){
  sub = dat[dat$parks == p,]
  return(nrow(sub))
})
out = out[order(out$city),]
names(out) = c('city', 'park', 'number of days', 'number of calls')

write.csv(out, '~/Desktop/table_effort.csv', quote = FALSE, row.names = F)
