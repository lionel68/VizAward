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

GetMap.bbox(c(8.6,8.9),c(50.7,50.9)) -> marburg_region


PlotOnStaticMap(marburg_region,lat=LatLon2XY(csv_clean.spdf@coords[,2],csv_clean.spdf@coords[,1],zoom=2)$Coords[,1],lon=LatLon2XY(csv_clean.spdf@coords[,2],csv_clean.spdf@coords[,1],zoom=2)$Coords[,2])
points()
