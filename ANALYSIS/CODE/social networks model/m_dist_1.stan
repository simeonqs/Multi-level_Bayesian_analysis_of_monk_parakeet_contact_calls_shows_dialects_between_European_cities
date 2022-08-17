// Project: chapter II
// Date started: 04-10-2021
// Date last modified: 04-10-2021
// Author: Simeon Q. Smeele
// Description: Multi-level model for distances between parks vs accoustical similarity. 
data{
    int N_obs; // number of rows (one row per call pair)
    int N_park_pair; 
    real d[N_obs]; // the accoustical distance between two calls (i and j)
    real dist[N_obs]; // physical distance between parks
    int park_pair[N_obs];
}
parameters{
    real<lower=0> sigma;
    real<lower=0> sigma_z;
    real<lower=0> sigma_b;
    real a;
    vector[N_park_pair] z_pair;
    real b;
    vector[N_park_pair] b_pair;
}
model{
    vector[N_obs] mu;
    sigma ~ exponential( 1 );
    sigma_z ~ exponential( 1 );
    sigma_b ~ exponential(1);
    a ~ normal(0, 0.5);
    z_pair ~ normal(0, 1);
    b ~ normal(0, 1);
    b_pair ~ normal(0, 1);
    for( n in 1:N_obs ) {
        mu[n] = a + z_pair[park_pair[n]] * sigma_z + (b + b_pair[park_pair[n]] * sigma_b) * dist[n];
    }
    d ~ normal(mu, sigma);
}
