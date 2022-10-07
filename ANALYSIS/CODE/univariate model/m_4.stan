// Project: monk parakeet dialects
// Date started: 04-08-2021
// Date last modified: 04-10-2022
// Author: Simeon Q. Smeele
// Description: Multilevel Bayesian model of city dialects. Takes principle coordinate as response variable.
// This version has three levels (city, park, ind). Un-centered version. Also has slightly tighter priors. 
// Note that the individual level is based on imperfect labeling of individuals for the real data.
data{
  int N_city; // number of unique cities (integer)
  int N_park; // number of unique parks (integer)
  int N_ind; // number of unique individuals (integer)
  int N_obs; // number of observations = calls
  real PC1[N_obs]; // principle component (real number, standardised), model also works for PC2, as long as it
                   // is renamed to PC1
  int city[N_obs]; // city index (integer)
  int park[N_obs]; // park index (integer)
  int ind[N_obs]; // individual index (integer)
}
parameters{
  real<lower=0> sigma_obs; // standard deviation between observations
  
  real z_city[N_city]; // z-score for each city
  real<lower=0> sigma_city; // standard deviation between cities
  real mu_city; // average across cities (e.g., population average)
  
  real z_park[N_park]; // z-score for each park
  real<lower=0> sigma_park; // standard deviation between parks
  
  real z_ind[N_ind]; // z-score for each individual
  real<lower=0> sigma_ind; // standard deviation between individuals
}
model{
  real mu_obs[N_obs]; // declaring variable that is modeled
  
  // priors, see parameter block for explenation
  sigma_ind ~ exponential(2);
  z_ind ~ normal(0, 1);
  
  sigma_park ~ exponential(2);
  z_park ~ normal(0, 1);
  
  mu_city ~ normal(0, 1);
  sigma_city ~ exponential(2);
  z_city ~ normal(0, 1);
  
  sigma_obs ~ exponential(2); 
  
  // main model - read from bottom to top
  for(i in 1:N_obs) // explain each observation as function of covariates
    mu_obs[i] = mu_city + // the mean for observation i is a function of the population average, plus
    z_city[city[i]] * sigma_city + // the city-level off-set, plus
    z_park[park[i]] * sigma_park + // the park-level off-set, plus
    z_ind[ind[i]] * sigma_ind; // the ind-level off-set
  PC1 ~ normal(mu_obs, sigma_obs); // PC1 is normally distributed, mu_obs is modeled above
}
