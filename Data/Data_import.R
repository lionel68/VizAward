########################################################################################
#                                    # # #                                             #
#This file is used to import the raw data on localities and the geographic information #
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 30.08.2016
########################################################################################

## Loading vector data

# vector data are represented by the sp package with three classes:
# SpatialPoints / SpatialPolygons / SpatialLines

# input of vector data with rgdal::readOGR()

library(plyr) # data handling
library(dplyr) # more data handling, piping (%>%)

library(sp)   # spatial objects
library(maps) # free maps of the world
library(mapdata) # world maps
library(RgoogleMaps) # get google maps
library(raster)  # raster data
library(rgdal)  # input/output, projections
library(rgeos)  # geometry operations

# Import data on localities in Marburg
csv_file <- read.csv("Data/Marburg_data.csv",sep=";")
csv_file.df <- as.data.frame(csv_file)
head(csv_file.df)
summary(csv_file.df) 

# Create a spatial object from the csv data
csv.spdf <- SpatialPointsDataFrame(csv_file.df[,c("longitude","latitude")],data = csv_file.df)

# What is the extend of the data points?
bbox(csv.spdf)
# min      max
# longitude  8.68925  8.81454
# latitude  50.77004 50.84380

# Create a raster file which marks the area of interest and is used to crop the other spatial data
marburg_area = extent(raster(xmn = 8.6893, xmx = 8.8145, ymn = 50.7700, ymx = 50.8437))

# GetMap.bbox(c(8.6,8.9),c(50.7,50.9)) -> marburg_region # Google Maps

# manually download a map of Hesse from http://download.geofabrik.de/europe/germany/hessen.html
# hessen-latest-shp.zip -> unzip to:
# folder "VizAward_Data" which has to be on the same level as the current directory

Hesse_roads <- readOGR("../VizAward_Data/hessen-latest.shp","roads") # this takes some time

# only select roads in the Marburg area
Hesse_roads_sel = crop(Hesse_roads, marburg_area)

rm(Hesse_roads) # make space in the environment

# Download bus route information from OpenStreetMap at http://overpass-turbo.eu/
# Go to the above url -> copy-paste the code below into the white box on the left (show via Wizard)
# -> run the query -> export in GPX format into the "VizAward_Data" folder

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

# Import the data on bus routes and stops
busroutes_shp <- readOGR(dsn = "../VizAward_Data/export.gpx", layer = "tracks")
busstops_shp <- readOGR(dsn = "../VizAward_Data/export.gpx", layer = "waypoints")

# Select only bus routes and bus stops within the area of interest
busroutes_sel <- crop(busroutes_shp, marburg_area)
busstops_sel <- crop(busstops_shp, marburg_area)

rm(busroutes_shp) # make space in the environment
rm(busstops_shp) # make space in the environment

# We can also import only one bus route at a time by indicating the number in k="ref" v="  "

# Information on single bus routes
# <osm-script output="json" timeout="25">
#   <union>
#   <query type="relation">
#   <has-kv k="ref" v="2"/>
#   <bbox-query e="8.895492553710938" n="50.85288349328369" s="50.75568091033749" w="8.636970520019531"/>
#   </query>
#   <recurse type="relation-way"/>
#   <recurse type="way-node"/>
#   </union>
#   <print mode="body"/>
#   <print mode="skeleton" order="quadtile"/>
#   </osm-script>

busroute_1_shp <- readOGR(dsn = "../VizAward_Data/export_Linie1.gpx", layer = "tracks")
busroute_2_shp <- readOGR(dsn = "../VizAward_Data/export_Linie2.gpx", layer = "tracks")
busroute_3_shp <- readOGR(dsn = "../VizAward_Data/export_Linie3.gpx", layer = "tracks")
busroute_4_shp <- readOGR(dsn = "../VizAward_Data/export_Linie4.gpx", layer = "tracks")
busroute_5_shp <- readOGR(dsn = "../VizAward_Data/export_Linie5.gpx", layer = "tracks")
busroute_6_shp <- readOGR(dsn = "../VizAward_Data/export_Linie6.gpx", layer = "tracks")
busroute_7_shp <- readOGR(dsn = "../VizAward_Data/export_Linie7.gpx", layer = "tracks")
busroute_8_shp <- readOGR(dsn = "../VizAward_Data/export_Linie8.gpx", layer = "tracks")
busroute_9_shp <- readOGR(dsn = "../VizAward_Data/export_Linie9.gpx", layer = "tracks")
busroute_10_shp <- readOGR(dsn = "../VizAward_Data/export_Linie10.gpx", layer = "tracks")

# combine the bus lines into a list
bus_line_list <- list(busroute_1_shp,busroute_2_shp,busroute_3_shp,busroute_4_shp,busroute_5_shp,
                      busroute_6_shp,busroute_7_shp,busroute_8_shp,busroute_9_shp,busroute_10_shp)


# Create plot to check if all spatial data overlap
plot(Hesse_roads_sel, lwd = 2, col = "lightgrey")
plot(busroutes_sel, col = "blue", add = T)
points(busstops_sel,col="darkblue", cex = 0.5, pch = 16)
points(csv.spdf, col = "red", cex = 0.5, pch = 16)
# This looks very good!