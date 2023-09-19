# Testing if distance between cities has an effect on acoustic similarity
library(geosphere)
library(tidyverse)

city_data <- data.frame(city = c("Barcelona", "Madrid", "Brussels", "Athens", "Pavia", "Legnago","Verona", "Bergamo"),
                        lat = c(41.3851, 40.4168, 50.8371, 37.9838, 45.1948, 45.2667, 45.44 ,45.6947),
                        lon = c(2.1734, -3.7038, 4.3676, 23.7275, 9.7205, 11.2333,10.99 ,9.6797))

coords <- city_data[,c("lon", "lat")]
dist_spatial <- distm(coords, fun=distHaversine) / 1000 # convert to km

load('ANALYSIS/RESULTS/luscinia/dtw/models/pco1 results.RData')
city_posts = lapply(1:length(which(str_detect(names(post), 'z_city'))), function(city)
  sapply(1:nrow(post), function(i) 
    post$mu_city[i] + post[[sprintf('z_city[%s]', city)]][i] * post$sigma_city[i]))
pco_1 = sapply(city_posts, mean)

load('ANALYSIS/RESULTS/luscinia/dtw/models/pco2 results.RData')
city_posts = lapply(1:length(which(str_detect(names(post), 'z_city'))), function(city)
  sapply(1:nrow(post), function(i) 
    post$mu_city[i] + post[[sprintf('z_city[%s]', city)]][i] * post$sigma_city[i]))
pco_2 = sapply(city_posts, mean)

load('ANALYSIS/RESULTS/base_data_2022_08_17_10_00_03.RData')
cities = base_data$cities
unique_cities = sort(unique(cities))
trans_cities = 1:length(unique_cities)
names(trans_cities) = unique_cities

dist_acoustic = dist(data.frame(pco_1 = pco_1, pco_2 = pco_2))

plot(dist_spatial[lower.tri(dist_spatial)], dist_acoustic)
model = lm(dist_acoustic ~ dist_spatial[lower.tri(dist_spatial)])
summary(model)
