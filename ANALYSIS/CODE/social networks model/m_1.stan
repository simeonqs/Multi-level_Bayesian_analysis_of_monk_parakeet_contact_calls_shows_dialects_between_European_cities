// Project: chapter II
// Date started: 07-09-2021
// Date last modified: 07-09-2021
// Author: Simeon Q. Smeele
// Description: Multi-level model with based on social networks model. Includes varying effects for:
// city, park and ind, including the pairs of these.
// This version was based on m_1.stan from the sn model for the voice paper. 
data{
    int N_obs; // number of rows (one row per call pair)
    int N_call; // number of calls
    int N_ind; 
    int N_park; 
    int N_city; 
    int N_ind_pair; // number of pairs of individuals (either from same or two different)
    int N_park_pair; 
    int N_city_pair;
    real d[N_obs]; // the accoustical distance between two calls (i and j)
    int call_i[N_obs]; // index for call i
    int call_j[N_obs]; 
    int ind_i[N_obs]; 
    int ind_j[N_obs];
    int park_i[N_obs];
    int park_j[N_obs];
    int city_i[N_obs];
    int city_j[N_obs];
    int ind_pair[N_obs];
    int park_pair[N_obs];
    int city_pair[N_obs];
    int same_ind[N_ind_pair]; // whether or not indpair is the same of different ind
    int same_park[N_park_pair];
    int same_city[N_city_pair];
}
parameters{
    real a;
    real b_ind_pair[N_ind_pair];
    real b_ind_bar;
    real b_park_pair[N_park_pair];
    real b_park_bar;
    real b_city_pair[N_city_pair];
    real b_city_bar;
    vector[N_call] z_call;
    vector[N_ind] z_ind;
    vector[N_park] z_park;
    vector[N_city] z_city;
    real<lower=0> sigma;
    real<lower=0> sigma_call;
    real<lower=0> sigma_ind;
    real<lower=0> sigma_park;
    real<lower=0> sigma_city;
    real<lower=0> sigma_b_ind;
    real<lower=0> sigma_b_park;
    real<lower=0> sigma_b_city;
}
model{
    vector[N_obs] mu;
    sigma ~ exponential( 1 );
    sigma_call ~ exponential( 2 );
    sigma_ind ~ exponential( 2 );
    sigma_park ~ exponential( 2 );
    sigma_city ~ exponential( 2 );
    sigma_b_ind ~ exponential(1);
    sigma_b_park ~ exponential(1);
    sigma_b_city ~ exponential(1);
    a ~ normal( 0 , 0.5 );
    z_call ~ normal( 0 , 0.5 );
    z_ind ~ normal( 0 , 0.5 );
    z_park ~ normal(0 , 0.5 );
    z_city ~ normal(0 , 0.5 );
    b_ind_pair ~ normal(0, 1 );
    b_ind_bar ~ normal(0, 1);
    b_park_pair ~ normal(0, 1);
    b_park_bar ~ normal(0, 1);
    b_city_pair ~ normal(0, 1);
    b_city_bar ~ normal(0, 1);
    for( n in 1:N_obs ) {
        mu[n] =
        a +
        z_call[call_i[n]] * sigma_call + z_call[call_j[n]] * sigma_call +
        z_ind[ind_i[n]] * sigma_ind + z_ind[ind_j[n]] * sigma_ind +
        z_park[park_i[n]] * sigma_park + z_park[park_j[n]] * sigma_park +
        z_city[city_i[n]] * sigma_city + z_city[city_j[n]] * sigma_city +
        -(b_ind_bar + b_ind_pair[ind_pair[n]] * sigma_b_ind) * same_ind[ind_pair[n]] +
        -(b_park_bar + b_park_pair[park_pair[n]] * sigma_b_park) * same_park[park_pair[n]] +
        -(b_city_bar + b_city_pair[city_pair[n]] * sigma_b_city) * same_city[city_pair[n]];
    }
    d ~ normal(mu, sigma);
}
