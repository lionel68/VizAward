########################################################################################
#                                    # # #                                             #
#This file is used to create a static visualization of the data for presentation       #
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 17.08.2016
########################################################################################

# Installing the development version of the leaflet package from github
library(devtools)
install_github("rstudio/leaflet")
####

library(leaflet)
library(plyr)
library(dplyr)
library(viridis) # to make color palette

#color palette for the bus line or use busline_colors
col_line <- colorFactor(viridis(length(bus_line_list)),as.character(1:length(bus_line_list)))
opacity_bus_lines <- 0.3

names(bus_line_list) <- c(1:length(bus_line_list))

# create icons with the leaflet package
icon_uni<-makeAwesomeIcon(icon="university",library="fa",markerColor="red",iconColor="white")
icon_bus<-makeAwesomeIcon(icon="bus",library = "fa",markerColor="darkblue",iconColor="white")
icons<-awesomeIconList(
  bar_pub_bistro=makeAwesomeIcon(icon = "beer",library = "fa",markerColor = "orange",iconColor = "green"),
  restaurant=makeAwesomeIcon(icon = "cutlery",library = "fa",markerColor = "white",iconColor = "darkred"),
  supermarket=makeAwesomeIcon(icon="shopping-cart",library = "glyphicon",markerColor = "cadetblue",iconColor = "#c3f971"),
  pharmacy=makeAwesomeIcon(icon="medkit",library="fa",markerColor = "white",iconColor="red"),
  accomodation=makeAwesomeIcon(icon="building-o",library="fa",markerColor = "white",iconColor = "yellow"),
  bakery=makeAwesomeIcon(icon="grain",library="glyphicon",markerColor = "white",iconColor="orange"),
  cafe=makeAwesomeIcon(icon="coffee",library="fa",markerColor = "cadetblue",iconColor="orange"),
  imbiss=makeAwesomeIcon(icon="pizza",library="ion",markerColor = "white",iconColor="pink"),
  taxi=makeAwesomeIcon(icon="taxi",library="fa",markerColor = "darkblue")
)

circle_color <- colorFactor(c("#8dd3c7","#ffffb3","#bebada","#fb8072","#80b1d3","#fdb462","#b3de69","#fccde5","#d9d9d9"), 
                            domain = c("bar_pub_bistro", "restaurant","supermarket","pharmacy","accomodation","bakery",
                                       "cafe","imbiss","taxi"))

# create a dataframe for the lines connecting store markers and bus stops
stores_lines <- stores

for (i in 1: nrow(stores)) {
stores_lines$Longitude[i] <- busstop_new[busstop_new$Name2 == as.character(stores_lines$Name2)[i],"Longitude"]
stores_lines$Latitude[i] <- busstop_new[busstop_new$Name2 == as.character(stores_lines$Name2)[i],"Latitude"]
}

stores_lines <- rbind(stores_lines,stores)

# create the static map

leaflet() %>%
  setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
  addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",
          option=tileOptions(minZoom=13,maxZoom=18)) %>%
  # addAwesomeMarkers(data=busstop_new,lng=~Longitude,lat=~Latitude,popup=~Tag)%>%
  addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
  addAwesomeMarkers(data=busstop_new,lng=~Longitude,lat=~Latitude,label=~Name2,icon=icon_bus)%>%
  # addAwesomeMarkers(data=stores,lng=~Longitude,lat=~Latitude,icon=~icons[Group],label = ~Labels,labelOptions = list(opacity=5)) %>% 
  
  addPolylines(data=bus_line_list[[1]],stroke=TRUE,color=col_line(1),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[2]],stroke=TRUE,color=col_line(2),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[3]],stroke=TRUE,color=col_line(3),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[4]],stroke=TRUE,color=col_line(4),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[5]],stroke=TRUE,color=col_line(5),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[6]],stroke=TRUE,color=col_line(6),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[7]],stroke=TRUE,color=col_line(7),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[8]],stroke=TRUE,color=col_line(8),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[9]],stroke=TRUE,color=col_line(9),noClip=FALSE,opacity = opacity_bus_lines)%>%
  addPolylines(data=bus_line_list[[10]],stroke=TRUE,color=col_line(10),noClip=FALSE,opacity = opacity_bus_lines) %>%
  addCircleMarkers(data=stores,radius =10,color = ~circle_color(Group),stroke = FALSE, fillOpacity = 0.9) -> static_map

# Add lines between points and stops
  for(i in 1:length(unique(stores_lines$StoreID))){
    store_name <- unique(stores_lines$StoreID)[i]
    static_map <- addPolylines(static_map, 
                          lat = c(as.numeric(stores_lines[stores_lines$StoreID==store_name, "Latitude"])), 
                          lng = c(as.numeric(stores_lines[stores_lines$StoreID==store_name, "Longitude"])),
                          color = "grey", fillColor = "grey", fillOpacity = 0.9, weight = 2)
  }
static_map
  

# addPolylines(data = stores_lines, lng = ~Longitude, lat = ~Latitude, group = ~StoreID,color = "#03F", weight = 5, opacity = 0.5)
  

# neither a loop nor l_ply worked as a more elegant solution to plotting the bus lines
  # l_ply(bus_line_list,function(x) addPolylines(data=x,stroke=TRUE,color=col_line(as.numeric(names(x))),noClip=FALSE))
  
# TO DO:

# Select a part of the map as an example area
# Show connecting lines between bus stops and stores
# Check if there are also round markers, or use color-coded points for stores
# Alternative: make the markers much smaller

## Idea for upgrade:
# Use clusterOptions = markerClusterOptions() for the stores in the interactive map and when option is "show all"