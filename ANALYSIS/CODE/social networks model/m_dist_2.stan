// Project: chapter II
// Date started: 04-10-2021
// Date last modified: 04-10-2021
// Author: Simeon Q. Smeele
// Description: Multi-level model for distances between parks vs accoustical similarity. 
// This version has a city level to slope and intercept.
data{
    int N_obs; // number of rows (one row per call pair)
    int N_park_pair; 
    int N_city;
    real d[N_obs]; // the accoustical distance between two calls (i and j)
    real dist[N_obs]; // physical distance between parks
    int park_pair[N_obs];
    int city[N_obs];
}
parameters{
    real<lower=0> sigma;
    real<lower=0> sigma_z_pair;
    real<lower=0> sigma_b_pair;
    real<lower=0> sigma_z_city;
    real<lower=0> sigma_b_city;
    real a;
    vector[N_park_pair] z_pair;
    vector[N_park_pair] z_city;
    real b;
    vector[N_park_pair] b_pair;
    vector[N_park_pair] b_city;
}
model{
    vector[N_obs] mu;
    sigma ~ exponential( 1 );
    sigma_z_pair ~ exponential( 1 );
    sigma_b_pair ~ exponential(1);
    sigma_z_city ~ exponential( 1 );
    sigma_b_city ~ exponential(1);
    a ~ normal(0, 0.5);
    z_pair ~ normal(0, 1);
    z_city ~ normal(0, 1);
    b ~ normal(0, 1);
    b_pair ~ normal(0, 1);
    b_city ~ normal(0, 1);
    for( n in 1:N_obs ) {
        mu[n] = a + 
        z_pair[park_pair[n]] * sigma_z_pair + z_city[city[n]] * sigma_z_city + 
        (b + b_pair[park_pair[n]] * sigma_b_pair + b_city[city[n]] * sigma_b_city) * dist[n];
    }
    d ~ normal(mu, sigma);
}
