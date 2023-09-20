library(ggplot2)
library(ggrepel)
library(ggmap)
library(ggsn)
################################Europe map for paper################
map <- get_stamenmap(bbox = c(left = -10, bottom = 35, right = 26, top = 53),
                     maptype = "terrain-background",color = "color",
                     zoom = 6)
# Create a data frame with the city names and coordinates
city_data <- data.frame(city = c("Barcelona, ES", "Madrid, ES", "Brussels, BE", "Athens, GR", "Pavia, IT", "Legnago, IT","Verona, IT", "Bergamo, IT"),
                        lat = c(41.3851, 40.4168, 50.8371, 37.9838, 45.1948, 45.2667, 45.44 ,45.6947),
                        lon = c(2.1734, -3.7038, 4.3676, 23.7275, 9.7205, 11.2333,10.99 ,9.6797))
city_data$color <- palette.colors(n = 8, palette = "Classic Tableau")
full_map <- ggmap(map) +
  geom_point(data = city_data, aes(x = lon, y = lat, color = city), size = 5) +
  scale_color_manual(values = city_data$color) +
  geom_text_repel(data = city_data, aes(label = ""), size = 3) +
  labs(x = NULL, y = NULL, title = "", color = "") + theme_light()+
  scalebar(x.min = 20, x.max = 25.1,transform = T,dist_unit = "km",
           y.min = 36,  y.max = 39,height = 0.03,st.dist = 0.15,st.size = 2,
           dist = 200, model = 'WGS84',box.color = c("white","black"),
           box.fill = c("white", "black"), st.color = "black")

#ggsave(filename="full_map.pdf", device = "pdf",  width = 7, height = 4.5,units = c("in"))
#ggsave(filename="full_map.tiff", device = "tiff", width = 7, height = 4.5,units = c("in"))
ggsave(filename = "full_map.eps",device = cairo_ps,width = 7, height = 4.5,units = c("in"))
###########################Barcelona map###############
map_barcelona <- get_stamenmap(bbox = c(left = 2.12, bottom = 41.38, right = 2.225, top = 41.423),
                               maptype = "terrain", color = "color",
                               zoom = 13)
park_data_barcelona <- data.frame(parks = c("Parc de la Ciutadella", "Jardins del Turo del Putxet",
                                            "Jardins de Ghandi", "Jardins de Josep Trueta",
                                            "Parc Grande de Sant Marti", "Jardin de la Maternitat"),
                                  lat = c(41.3881, 41.409123475569906, 41.4041, 41.4041, 41.41951863544851, 41.3833),
                                  lon = c(2.1860, 2.142798695502499, 2.2074, 2.2052, 2.198200579081006, 2.1248))
park_data_barcelona$colour <- palette.colors(n = 6, palette = "Classic Tableau")
parks_map_barcelona <- ggmap(map_barcelona) +
  geom_point(data = park_data_barcelona, aes(x = lon, y = lat, color = parks), size = 3) +
  scale_color_manual(values = park_data_barcelona$colour) +
  geom_text_repel(data = park_data_barcelona, aes(label = ""), size = 3) +
  labs(x = NULL, y = NULL, title = "", color = "") + theme_light()+
  scalebar(x.min = 2.11, x.max = 2.222,transform = T,dist_unit = "km",
           y.min = 41.384,  y.max = 41.42,height = 0.02,st.dist = 0.05,st.size = 3,
           dist = 1, model = 'WGS84',box.color = c("white","black"),
           box.fill = c("white", "black"), st.color = "black")+
  theme(axis.text.y=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.ticks.y=element_blank())
#ggsave(filename="parks_map_barcelona.pdf",  device = "pdf",  width = 7, height = 4.5,units = c("in"))
ggsave(filename = "parks_map_barcelona.eps",device = cairo_ps,width = 7, height = 4.5,units = c("in"))

###########################Brussels map###########################
map_brussels <- get_stamenmap(bbox = c(left = 4.33, bottom = 50.80, right = 4.4305, top = 50.825),
                              maptype = "terrain", color = "color", zoom = 13)
park_data_brussels <- data.frame(parks = c("Parc de Forest", "Ten Reuken",
                                           "Avenue Louise", "Tenenbosch Park",
                                           "Place Guy D'Arezzo"),
                                 lat = c(50.8230, 50.8066, 50.82124, 50.81998, 50.81569),
                                 lon = c(4.3383, 4.4280, 4.37035, 4.36479, 4.36061))
park_data_brussels$colour <- palette.colors(n = 5, palette = "Classic Tableau")
parks_map_brussles <- ggmap(map_brussels) +
  geom_point(data = park_data_brussels, aes(x = lon, y = lat, color = parks), size = 3) +
  scale_color_manual(values = park_data_brussels$colour) +
  geom_text_repel(data = park_data_brussels, aes(label = ""), size = 3) +
  labs(x = NULL, y = NULL, title = "", color = "") + theme_light()+
  scalebar(x.min = 4.3, x.max = 4.428,transform = T,dist_unit = "km",
           y.min = 50.802,  y.max = 50.81,height = 0.05,st.dist = 0.15,st.size = 3,
           dist = 1, model = 'WGS84',box.color = c("white","black"),
           box.fill = c("white", "black"), st.color = "black")+
  theme(axis.text.y=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.ticks.y=element_blank())
#ggsave(filename="parks_map_brussles.pdf",  device = "pdf",  width = 7, height = 4.5,units = c("in"))
ggsave(filename = "parks_map_brussles.eps",device = cairo_ps,width = 7, height = 4.5,units = c("in"))

###########################Athens map###########################
map_athens <- get_stamenmap(bbox = c(left = 23.71, bottom = 37.96, right = 23.78, top = 38),
                            maptype = "terrain", color = "color", zoom = 13)
park_data_athens <- data.frame(parks = c("Alsos Ilision", "Gendarmerie School Park",
                                         "National Garden","Oulof Palme Playground",
                                         "Thissio Park"),
                               lat = c(37.9759, 37.9892, 37.9726, 37.9747, 37.9758),
                               lon = c(23.7559, 23.7711, 23.7374, 23.7603, 23.7204))
park_data_athens$colour <- palette.colors(n = 5, palette = "Classic Tableau")
parks_map_athens <- ggmap(map_athens) +
  geom_point(data = park_data_athens, aes(x = lon, y = lat, color = parks), size = 3) +
  scale_color_manual(values = park_data_athens$colour) +
  geom_text_repel(data = park_data_athens, aes(label = ""), size = 2) +
  labs(x = NULL, y = NULL, title = "", color = "")+ theme_light()+
  scalebar(x.min = 23.7, x.max = 23.778,transform = T,dist_unit = "km",
           y.min = 37.9615,  y.max = 37.99,height = 0.02,st.dist = 0.03,st.size = 2,
           dist = 0.5, model = 'WGS84',box.color = c("white","black"),
           box.fill = c("white", "black"), st.color = "black")+
  theme(axis.text.y=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.ticks.y=element_blank())
#ggsave(filename="parks_map_athens.pdf",  device = "pdf",  width = 7, height = 4.5,units = c("in"))
ggsave(filename = "parks_map_athens.eps",device = cairo_ps,width = 7, height = 4.5,units = c("in"))

####################################Madrid map#############################
map_madrid <- get_stamenmap(bbox = c(left = -3.75, bottom = 40.37, right = -3.60, top = 40.48),
                            maptype = "terrain", color = "color", zoom = 13)
park_data_madrid <- data.frame(parks = c("Parque de el Retiro", "Parque de Berlin",
                                         "Lago Casa del Campo", "Parque Azorín",
                                         "Parque Emperatriz Maria de Austria",
                                         "Parque Infantil Portalegre","Parque de la Quinta de los Molinos",
                                         "Parque Alfredo Kraus"),
                               lat = c(40.4153, 40.4504, 40.4189, 40.3902, 40.3778, 40.3893, 40.4439, 40.4708),
                               lon = c(-3.6845, -3.6758, -3.7327, -3.6549, -3.7234, -3.7251, -3.6275, -3.6403))
park_data_madrid$colour <- palette.colors(n = 8, palette = "Classic Tableau")
parks_map_madrid <- ggmap(map_madrid) +
  geom_point(data = park_data_madrid, aes(x = lon, y = lat, color = parks), size = 3) +
  scale_color_manual(values = park_data_madrid$colour) +
  geom_text_repel(data = park_data_madrid, aes(label = ""), size = 2) +
  labs(x = NULL, y = NULL, title = "", color = "") + theme_light()+
  scalebar(x.min = -3.63, x.max = -3.605,transform = T,dist_unit = "km",
           y.min = 40.373,  y.max = 40.4,height = 0.03,st.dist = 0.06,st.size = 2,
           dist = 1, model = 'WGS84',box.color = c("white","black"),
           box.fill = c("white", "black"), st.color = "black")+
  theme(axis.text.y=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.ticks.y=element_blank())
#ggsave(filename="parks_map_madrid.pdf",  device = "pdf",  width = 7, height = 4.5,units = c("in"))
ggsave(filename = "parks_map_madrid.eps",device = cairo_ps,width = 7, height = 4.5,units = c("in"))

####Italy map
map_northern_italy <- get_stamenmap(bbox = c(left = 9, bottom = 45, right = 11.54, top = 45.92),
                                    maptype = "terrain", color = "color", zoom = 9)
park_data_italy <- data.frame(parks = c("Parco Natura Viva", "Oasi di Sant' Alessio", "Faunistic Park Le Cornelle","Legnago"),
                              lat = c(45.48070831236619, 45.23075132114686, 45.72821848228451,45.19257),
                              lon = c(10.799985279828975, 9.223922680196612, 9.615045092434414,11.30997))

park_data_italy$colour <- palette.colors(n = 4, palette = "Classic Tableau")
parks_map_italy <- ggmap(map_northern_italy) +
  geom_point(data = park_data_italy, aes(x = lon, y = lat, color = parks), size = 3) +
  scale_color_manual(values = park_data_italy$colour) +
  geom_text_repel(data = park_data_italy, aes(label = ""), size = 2) +
  labs(x = NULL, y = NULL, title = "", color = "")+ theme_light()+
  scalebar(x.min = 11, x.max = 11.49,transform = T,dist_unit = "km",
           y.min = 45.03,  y.max = 45.06,height = 0.04,st.dist = 0.5,st.size = 2,
           dist = 10, model = 'WGS84',box.color = c("white","black"),
           box.fill = c("white", "black"), st.color = "black")+
  theme(axis.text.y=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.ticks.y=element_blank())
#ggsave(filename="parks_map_italy.pdf",  device = "pdf",  width = 7, height = 4,units = c("in"))
ggsave(filename = "parks_map_italy.eps",device = cairo_ps,width = 7, height = 4.5,units = c("in"))
