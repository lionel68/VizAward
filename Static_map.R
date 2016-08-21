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

## We want to save the map as png
 # Solution from StackOverflow: http://stackoverflow.com/questions/31336898/how-to-save-leaflet-in-rstudio-map-as-png-or-jpg-file
 # Note: PhantomJS needs to be downloaded from http://phantomjs.org/ to c:/Users/AppData/Roaming/PhantomJS

## install 'webshot' package
install_github("wch/webshot")

## load packages
library(htmlwidgets)
library(webshot)
# install the downloaded PhantomJS
webshot::install_phantomjs()

## Making the map
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

circle_color <- colorFactor(palette = "Set3", domain = stores$Group,n = length(unique(stores$Group)))

# Create labels and colors for legend
stores %>% mutate(legend_labels = Group) %>% 
  mutate(legend_labels = ifelse(legend_labels %in% "bar_pub_bistro","bar/pub/bistro",legend_labels)) -> stores

legend_color <- colorFactor(palette = "Set3",domain = stores$legend_labels,
                            n = length(unique(stores$legend_labels)))

# create a dataframe for the lines connecting store markers and bus stops
stores_lines <- stores

for (i in 1: nrow(stores)) {
stores_lines$Longitude[i] <- busstop_new[busstop_new$Name2 == as.character(stores_lines$Name2)[i],"Longitude"]
stores_lines$Latitude[i] <- busstop_new[busstop_new$Name2 == as.character(stores_lines$Name2)[i],"Latitude"]
}

stores_lines <- rbind(stores_lines,stores)

# create the static map

leaflet() %>%
  addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw") %>%
  setView(lng=8.773500, lat=50.810600,zoom = 15) %>%
  addAwesomeMarkers(data=busstop_new,lng=~Longitude,lat=~Latitude,label=~Name2,icon=icon_bus)%>%
  
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

# Adding a legend
static_map <- static_map %>% addLegend("bottomright", pal = legend_color, values = stores$legend_labels,
                                   title = "Stores and other amenities",
                                   opacity = 1)
# Adding a legend for the bus icon
html_legend <- "<span>
  <i class='fa fa-bus icon-white'></i>
</span></i>nearest bus stop" 


static_map <- static_map %>% addControl(html = html_legend, position = "topright")

# Saving the static map as png

saveWidget(static_map, "static_map_temp.html", selfcontained = FALSE)
webshot("static_map_temp.html", file = "static_map.png",
        cliprect = "viewport")
