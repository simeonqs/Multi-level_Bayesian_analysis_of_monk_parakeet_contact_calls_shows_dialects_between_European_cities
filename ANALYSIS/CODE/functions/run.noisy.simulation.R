# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Project: dialect paper
# Date started: 04-08-2021
# Date last modified: 11-02-2022
# Author: Simeon Q. Smeele
# Description: Runs the noisy simulation where individuals can be observed multiple time with different 
# labels and multiple individuals can get the same label. 
# This version is rewritten and not based on the function from chapter I. 
# This version uses cmdstanr. 
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

require(stringr)
require(cmdstanr)

run.noisy.simulation = function(
  base_data,
  path_model,
  sd_city = 1,
  sd_park = 0.5,
  sd_ind = 0.3,
  sd_obs = 0.1,
  lambda_ind_per_rec = 1.5, # average number of inds per chunk
  lambda_rerec = 1.5, # average number of time ind is recorded across recordings
  p_next_chunk = 0.5, # probability of recording same in in next chunk
  path_out = NULL
){
  
  # Get lambda's
  ## Function to get zero-truncated lambda with same mean
  find.l = function(lambda){
    ii = 0
    cont = T
    while(cont){
      ii = ii + 1
      f = function(x) x/(1 - exp(-x))
      x = seq(0.01, 10, length.out = 1e4)
      y = f(x)
      d = abs(y-lambda)
      l = x[d == min(d)]
        s1 = rpois(1e6, l)
      s1 = s1[s1 != 0]
      if(round(mean(s1), 2) == lambda) cont = F
      if(ii > 10) stop('Lambda cannot be found.')
    }
    return(l)
  }
  l1 = find.l(lambda_ind_per_rec)
  l2 = find.l(lambda_rerec)
  # Function to draw single zero truncated sample
  zpois = function(lambda){
    cont = T
    while(cont){
      r = rpois(1, lambda)
      if(r != 0) cont = F
    }
    return(r)
  } 
  
  # Get simulation ids
  base_data$underlying_id = base_data$id
  ## Also recorded in next chunk
  o1 = length(unique(base_data$underlying_id))
  ui = unique(base_data$underlying_id)
  ui = ui[!str_detect(ui, 'sqs|SQS|sat|SAT|NA')] # don't do it for annotations as these are the same ind 
  files = base_data$underlying_id %>% str_split('_') %>% lapply(`[`, 1:4) %>% sapply(paste, collapse = '_')
  chunks = base_data$underlying_id %>% str_split('_') %>% sapply(`[`, 5)
  for(rec in sort(ui)){
    file = rec %>% str_split('_') %>% sapply(`[`, 1:4) %>% paste(collapse = '_')
    chunk = rec %>% str_split('_') %>% sapply(`[`, 5) %>% as.numeric
    if(sample(c(T, F), 1, prob = c(1-p_next_chunk, p_next_chunk))) next # skip if not in next chunk
    next_rec = which(files == file & chunks == chunk + 1)
    if(length(next_rec) != 0) base_data$underlying_id[next_rec] = rec
  }
  o2 = length(unique(base_data$underlying_id))
  if(o1 < o2) stop('Problem with first step.')
  ## Get multiple inds per rec
  ui = unique(base_data$underlying_id)
  ui = ui[!str_detect(ui, 'sqs|SQS|sat|SAT')] # don't do it for annotations as these are the same ind
  for(x in ui){
    o = base_data$underlying_id[base_data$id == x] # old id
    n = zpois(l1) # how many inds to split between
    e = sample(1:n, length(o), replace = T) # find which bird vocalises
    base_data$underlying_id[base_data$id == x] = paste(o, e, sep = '_') # create new labels
  }
  o3 = length(unique(base_data$underlying_id))
  if(o2 > o3) stop('Problem with second step.')
  ## Also recorded other recording
  for(id in unique(base_data$underlying_id)){
    n = zpois(l2) # how many times recorded this ind across recordings
    park = base_data$parks[base_data$underlying_id == id][1]
    n = min(n, length(unique(base_data$underlying_id[base_data$parks == park])))
    if(n == 1) next
    for(ni in 1:n){
      r = sample(base_data$underlying_id[base_data$parks == park & base_data$underlying_id != id], 1)
      base_data$underlying_id[base_data$underlying_id == r] = id
      if(length(unique(base_data$underlying_id[base_data$parks == park])) == 1) break
    }
  }
  o4 = length(unique(base_data$underlying_id))
  if(o3 < o4) stop('Problem with third step.')

  # Simulate
  dat = data.frame()
  for(city in unique(base_data$cities)){
    mean_city = rnorm(1, 0, sd_city)
    parks = unique(base_data$parks[base_data$cities == city])
    for(park in parks){
      mean_park = rnorm(1, mean_city, sd_park)
      inds = unique(base_data$underlying_id[base_data$parks == park])
      for(ind in inds){
        mean_ind = rnorm(1, mean_park, sd_ind)
        N_obs = length(which(base_data$underlying_id == ind))
        dat = rbind(dat,
                    data.frame(
                      city = city,
                      park = park,
                      ind = base_data$id[base_data$underlying_id == ind],
                      PC1 = rnorm(N_obs, mean_ind, sd_obs)
                    ))
      }
    }
  }
  
  # Rescale PC1
  dat$PC1 = as.numeric(scale(dat$PC1))
  
  # Add other info
  dat$city = as.integer(as.factor(dat$city))
  dat$park = as.integer(as.factor(dat$park))
  dat$ind = as.integer(as.factor(dat$ind))
  dat = as.list(dat)
  dat$N_city = max(dat$city)
  dat$N_park = max(dat$park)
  dat$N_ind = max(dat$ind)
  dat$N_obs = length(dat$PC1)
  
  # Run some checks
  if(length(unique(dat$ind)) != length(unique(base_data$id))) stop('Number inds do not match!')
  if(all(sort(as.numeric(table(dat$park))) != sort(as.numeric(table(base_data$park))))) 
    stop('Parks do not match!')
  
  # Print size dataset and parameters
  parameters = c(sd_city = sd_city,
                 sd_park = sd_park,
                 sd_ind = sd_ind,
                 sd_obs = sd_obs,
                 lambda_ind_per_rec = lambda_ind_per_rec,
                 lambda_rerec = lambda_rerec,
                 p_next_chunk = p_next_chunk)
  message('\n=================================================================================\n')
  message('Starting model with ', dat$N_obs, ' observations.')
  message('Running with these paramters:')
  print(parameters)
  
  # Run model
  model = cmdstan_model(path_model)
  fit = model$sample(data = dat, 
                     seed = 1, 
                     chains = 4, 
                     parallel_chains = 4,
                     refresh = 500,
                     adapt_delta = 0.95)
  post = fit$draws(format = "df") %>% as.data.frame
  
  # Save
  file = sprintf('%sresults_noisy_%s_%s_%s_%s_%s_%s_%s.RData', 
                 path_out, sd_city, sd_park, sd_ind, sd_obs, lambda_ind_per_rec, lambda_rerec, p_next_chunk)
  save(list = c('parameters', 'post', 'dat'), file = file)
  message('Done. Saved parameters, post and dat.')
  
} # end function