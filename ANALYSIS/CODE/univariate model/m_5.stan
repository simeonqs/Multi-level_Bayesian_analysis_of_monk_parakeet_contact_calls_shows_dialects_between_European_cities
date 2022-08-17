// Three-level (city, park, ind). Partly centered version.
data{
  int N_city; 
  int N_park;
  int N_ind;
  int N_obs;
  real PC1[N_obs]; 
  int city[N_obs];
  int park[N_obs];
  int ind[N_obs];
}
parameters{
  real<lower=0> sigma_obs;
  
  real z_city[N_city];
  real<lower=0> sigma_city;
  real mu_city;
  
  real z_park[N_park];
  real<lower=0> sigma_park;
  
  real a_ind[N_ind];
  real<lower=0> sigma_ind;
}
model{
  real mu_obs[N_obs];
  
  sigma_ind ~ exponential(1);
  a_ind ~ normal(0, sigma_ind);
  
  sigma_park ~ exponential(1);
  z_park ~ normal(0, 1);
  
  mu_city ~ normal(0, 1);
  sigma_city ~ exponential(1);
  z_city ~ normal(0, 1);
  
  for(i in 1:N_obs)
    mu_obs[i] = mu_city + 
    z_city[city[i]] * sigma_city + 
    z_park[park[i]] * sigma_park + 
    a_ind[ind[i]];
  sigma_obs ~ exponential(2);
  PC1 ~ normal(mu_obs, sigma_obs);
}
