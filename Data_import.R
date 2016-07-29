## Loading vector data

# vector data are represented by the sp package with three classes:
# SpatialPoints / SpatialPolygons / SpatialLines

# input of vector data with rgdal::readOGR()

library(rgdal)
library(sp)
library(maps)
library(mapdata)
library(plyr)
library(dplyr)
library(RgoogleMaps)
library(raster)  # raster data
library(rgdal)  # input/output, projections
library(rgeos)  # geometry ops

germany <- readOGR("C:/Users/Nadja/8-Freising/03_BioHolz/03_Datasets/DEU_adm_shp","DEU_adm0")

csv_file <- read.csv("Data/Marburg_data.csv",sep=";")

csv_file.df <- as.data.frame(csv_file)
head(csv_file.df)

bbox(csv_file.spdf)

which(as.numeric(csv_file.df$latitude_new)/1000000<50)

csv_file.df[-which(as.numeric(csv_file.df$longitude_new)/1000000<8),] -> csv_clean.df

csv_clean.df$latitude_new <- as.numeric(csv_clean.df$latitude_new)/1000000
csv_clean.df$longitude_new <- as.numeric(csv_clean.df$longitude_new)/1000000

csv_clean.spdf <- SpatialPointsDataFrame(csv_clean.df[,c("longitude_new","latitude_new")], 
                                        data = csv_clean.df[c(5:12)])
bbox(csv_clean.spdf)

GetMap.bbox(c(8.6,8.9),c(50.7,50.9)) -> marburg_region # Google Maps

#  left, bottom, right, and top coordinates
bbox_osm <- corner_bbox(8.6893,50.7700,8.8145,50.8437) # OpenStreetMap
marburg_region_OSM <- get_osm(bbox_osm, source = osmsource_api()) # --> too large

# manually downloaded a map of Hesse from http://download.geofabrik.de/europe/germany/hessen.html
# and add to a new folder "VizAward_Data" which is on the same level as the current directory

Hesse_roads <- readOGR("../VizAward_Data/hessen-latest.shp","roads")

marburg_area = extent(raster(xmn = 8.6893, xmx = 8.8145, ymn = 50.7700, ymx = 50.8437))
Hesse_roads_sel = crop(Hesse_roads, marburg_area)

plot(Hesse_roads_sel)
points(csv_clean.spdf, col = "red")


# Export of bus route information from OpenStreetMap at http://overpass-turbo.eu/

# Instructions: go to the linked url -> copy-paste the code below into the white box on the left (or via Wizard)
# -> run the query -> export in GPX format

# <osm-script output="json" timeout="25">
#   <union>
#   <query type="relation">
#   <has-kv k="route" v="bus"/>
#   <bbox-query e="8.895492553710938" n="50.85288349328369" s="50.75568091033749" w="8.636970520019531"/>
#   </query>
#   <recurse type="relation-way"/>
#   <recurse type="way-node"/>
#   </union>
#   <print mode="body"/>
#   <print mode="skeleton" order="quadtile"/>
#   </osm-script>

busroutes_shp <- readOGR(dsn = "../VizAward_Data/export.gpx", layer = "tracks")
plot(busroutes_shp)

busstops_shp <- readOGR(dsn = "../VizAward_Data/export.gpx", layer = "waypoints")
points(busstops_shp,col="red")
