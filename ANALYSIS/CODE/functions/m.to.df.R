# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: social networks
# Date started: 24-08-2021
# Date last modified: 07-09-2021
# Author: Simeon Q. Smeele
# Description: Taking matrix with distances and making it into a dataframe that can be analysed with stan 
# model. 
# This version was adapted for the dialect paper. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

m.to.df = function(m, 
                   cities,
                   parks,
                   inds,
                   progress_bar = T){
  
  d = data.frame()
  
  if(progress_bar) pb = txtProgressBar(min = 0, max = nrow(m), initial = 0, style = 3)
  for(i in 1:nrow(m)){
    if(progress_bar) setTxtProgressBar(pb,i)
    if(i == ncol(m)) break
    for(j in (i+1):ncol(m)){
      new = data.frame(
        d = m[i,j],
        call_i = i,
        call_j = j,
        ind_i = inds[i],
        ind_j = inds[j],
        ind_pair = paste(inds[i], inds[j], sep = '-'),
        park_i = parks[i],
        park_j = parks[j],
        park_pair = paste(parks[i], parks[j], sep = '-'),
        city_i = cities[i],
        city_j = cities[j],
        city_pair = paste(cities[i], cities[j], sep = '-')
      )
      d = rbind(d, new)
    }
  }
  d$city_pair = as.integer(as.factor(d$city_pair))
  d$park_pair = as.integer(as.factor(d$park_pair))
  d$ind_pair = as.integer(as.factor(d$ind_pair))
  if(progress_bar) close(pb)
  
  return(d)
  
}