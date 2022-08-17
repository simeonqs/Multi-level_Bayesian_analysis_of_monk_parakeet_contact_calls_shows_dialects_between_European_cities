// Three-level (city, park, ind). Partly centered version.
// This version includes the distance between parks. 
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
  int N_city; 
  int N_park;
  int N_ind;
  int N_obs;
  vector[N_obs] PC1; 
  int city[N_obs];
  int park[N_obs];
  int ind[N_obs];
  matrix[N_park,N_park] d_mat;
}
parameters{
  real<lower=0> sigma_obs;
  
  real z_city[N_city];
  real<lower=0> sigma_city;
  real mu_city;
  
  vector[N_park] a_park;

  real a_ind[N_ind];
  real<lower=0> sigma_ind;
  
  real<lower=0> etasq;
  real<lower=0> rhosq;
}
model{
  vector[N_obs] mu_obs;
  matrix[N_park,N_park] SIGMA;

  sigma_ind ~ exponential(1);
  a_ind ~ normal(0, sigma_ind);
  
  rhosq ~ exponential( 5 );
  etasq ~ exponential( 10 );
  SIGMA = cov_GPL2(d_mat, etasq, rhosq, 0.01);
  
  a_park ~ multi_normal(rep_vector(0, N_park), SIGMA);
  
  mu_city ~ normal(0, 1);
  sigma_city ~ exponential(1);
  z_city ~ normal(0, 1);
  
  for(i in 1:N_obs)
    mu_obs[i] = mu_city + 
    z_city[city[i]] * sigma_city + 
    a_park[park[i]] + 
    a_ind[ind[i]];
  sigma_obs ~ exponential(2);
  PC1 ~ normal(mu_obs, sigma_obs);
}
