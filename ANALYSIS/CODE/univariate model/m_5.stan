// Project: monk parakeet dialects
// Date started: 17-02-2023
// Date last modified: 17-02-2023
// Author: Simeon Q. Smeele
// Description: Multilevel Bayesian model of city dialects. Takes principle coordinate as response variable.
// This version has three levels (city, park, ind). Un-centered version. Also has slightly tighter priors.
// This version includes distance and runs within a city. 
// Note that the individual level is based on imperfect labeling of individuals for the real data.
functions{


    matrix cov_GPL2(matrix x, real sq_alpha, real sq_rho, real delta) {
        int N = dims(x)[1];
        matrix[N, N] K;
        for (i in 1:(N-1)) {
          K[i, i] = sq_alpha + delta;
          for (j in (i + 1):N) {
            K[i, j] = sq_alpha * exp(-sq_rho * square(x[i,j]) );
            K[j, i] = K[i, j];
          }
        }
        K[N, N] = sq_alpha + delta;
        return K;
    }
}
data{
  int N_park; // number of unique parks (integer)
  int N_ind; // number of unique individuals (integer)
  int N_obs; // number of observations = calls
  vector[N_obs] PC; 
  int park[N_obs]; // park index (integer)
  int ind[N_obs]; // individual index (integer)
  matrix[N_obs,N_obs] dmat;
}
parameters{
  real mu_pop; // average across population
  
  real z_park[N_park]; // z-score for each park
  real<lower=0> sigma_park; // standard deviation between parks
  
  real z_ind[N_ind]; // z-score for each individual
  real<lower=0> sigma_ind; // standard deviation between individuals
  
  real<lower=0> etasq;
  real<lower=0> rhosq;
}
model{
  vector[N_obs] mu_obs; // declaring variable that is modeled
  matrix[N_obs,N_obs] SIGMA;
    
  // priors, see parameter block for explenation
  sigma_ind ~ exponential(2);
  z_ind ~ normal(0, 1);
  
  sigma_park ~ exponential(2);
  z_park ~ normal(0, 1);
  
  mu_pop ~ normal(0, 1);

  rhosq ~ exponential( 0.1 );
  etasq ~ exponential( 1 );
  SIGMA = cov_GPL2(dmat, etasq, rhosq, 0.01);

  // main model - read from bottom to top
  for(i in 1:N_obs) // explain each observation as function of covariates
    mu_obs[i] = mu_pop + // the mean for observation i is a function of the population average, plus
    z_park[park[i]] * sigma_park + // the park-level off-set, plus
    z_ind[ind[i]] * sigma_ind; // the ind-level off-set
  PC ~ multi_normal(mu_obs, SIGMA); // PC1 is normally distributed, mu_obs is modeled above
  
}
