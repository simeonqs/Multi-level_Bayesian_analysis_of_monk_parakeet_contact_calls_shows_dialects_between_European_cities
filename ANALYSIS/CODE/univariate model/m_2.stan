// Two-level (city, park). Centered version. 
data{
  int N_city; 
  int N_park;
  int N_obs;
  real PC1[N_obs]; 
  int city[N_obs];
  int park[N_obs];
}
parameters{
  real<lower=0> sigma_obs;
  
  real a_city[N_city];
  real<lower=0> sigma_city;
  real mu_city;
  
  real a_park[N_park];
  real<lower=0> sigma_park;
}
model{
  real mu_obs[N_obs];
  
  sigma_park ~ exponential(1);
  a_park ~ normal(0, sigma_park);
  
  mu_city ~ normal(0, 1);
  sigma_city ~ exponential(1);
  a_city ~ normal(mu_city, sigma_city);
  
  for(i in 1:N_obs)
    mu_obs[i] = a_city[city[i]] + a_park[park[i]];
  sigma_obs ~ exponential(1);
  PC1 ~ normal(mu_obs, sigma_obs);
}
