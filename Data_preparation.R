########################################################################################
#                                    # # #                                             #
#This file is used to prepare the final data used in the shiny application             #
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 28.07.2016
########################################################################################


library(plyr)
library(dplyr)
library(tidyr) # more data management

# Import the templates

busstop_tmp <- read.csv("Data/template_busstop.csv", sep = ",")
stores_tmp <- read.csv("Data/template_stores.csv", sep = ",")

# look at the templates
str(busstop_tmp)
# $ BusStopID  : int  1 2 3 4
# $ Longitude  : int  11 11 10 10
# $ Latitude   : int  1 2 1 2
# $ BusStopName: Factor w/ 4 levels "Hbf","Markplatz",..: 2 1 3 4
# $ NbBusLine  : int  2 5 1 1
# $ BusLine    : Factor w/ 4 levels "1-2","1-2-3-4-5",..: 1 2 3 4
str(stores_tmp)
# $ StoreID  : int  1 2 3 4
# $ Longitude: int  11 11 10 10
# $ Latitude : int  1 2 1 2
# $ Group    : Factor w/ 4 levels "A","B","C","D": 1 2 3 4
# $ Labels   : Factor w/ 4 levels "Am Adler","Mensa",..: 2 1 3 4
# $ BusStopID: int  1 1 1 1

# look at the data we already have
str(csv_file.df)
# $ latitude       : num  50.8 50.8 50.8 50.8 50.8 ...
# $ longitude      : num  8.77 8.77 8.76 8.79 8.77 ...
# $ elevation_m_asl: int  212 183 192 270 185 184 186 185 187 190 ...
# $ name           : Factor w/ 334 levels "5 Jahreszeiten",..: 6 11 13 13 13 13 21 58 74 76 ...
# $ street         : Factor w/ 110 levels "Affoellerstr.",..: 76 88 10 40 58 85 5 42 20 24 ...
# $ street_no      : Factor w/ 106 levels "","01. Jun","05. Jul",..: 9 65 1 102 63 80 5 11 97 12 ...
# $ zip_code       : int  35037 35037 35037 35039 35039 35037 35041 35037 35037 35037 ...
# $ city           : Factor w/ 4 levels "Marburg","Marburg-Cappel",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ tel            : Factor w/ 16 levels "","06421-144 44",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ category       : Factor w/ 11 levels "accomodation",..: 7 7 7 7 7 7 7 7 7 7 ...

# Some columns are already as we need them, some are unnecessary
# Clean up the data using the tbl class used by dplyr and tidyr
csv_file.tbl <- tbl_df(csv_file.df)
csv_file.tbl %>% mutate(StoreID = paste("Store",row.names(csv_file.df),sep = "_")) %>%
  mutate(Longitude = longitude) %>% mutate(Latitude = latitude) %>% mutate(Group = category) %>%
  mutate(Labels = name) %>%
  dplyr::select(one_of(c("StoreID","Longitude", "Latitude", "Group","Labels"))) -> stores

#rename some category
stores$Group<-as.character(stores$Group)
stores$Group[stores$Group=="food"]<-"supermarket"
stores$Labels<-as.character(stores$Labels)
#remove bad names
stores<-stores[validUTF8(stores$Labels),]
stores<-stores[validEnc(stores$Labels),]

#remove category other essentials
stores<-subset(stores,Group!="other_essentials")
#remove duplicated points
stores<-stores[-which(duplicated(stores[,c("Longitude","Latitude")])),]

# TO DO:
csv.spdf[validUTF8(as.character(csv.spdf$name)),] -> stores.sp
stores.sp[validUTF8(as.character(stores.sp$name)),] -> stores.sp
#remove category other essentials
stores.sp<-subset(stores.sp,Group!="other_essentials")
#remove duplicated points
stores.sp<-stores.sp[-which(duplicated(stores.sp[,c("Longitude","Latitude")])),]


# Look at the busstop data
str(busstops_sel)
head(busstops_sel@coords)
dim(busstops_sel@coords)

# Remove busstops without proper names
busstops_sel[substr(busstops_sel$name,1,4)!="node",] -> busstops_subset
dim(busstops_subset@coords)

# convert into data.frame
busstops_subset.df <- as.data.frame(busstops_subset)
str(busstops_subset.df)

# Clean up the data using the tbl class used by dplyr and tidyr
busstops_subset.df %>% mutate(BusStopID = paste("Stop",row.names(busstops_subset.df),sep = "_")) %>%
  mutate(Longitude = coords.x1) %>% mutate(Latitude = coords.x2 ) %>%
  mutate(BusStopName = name) %>%
  dplyr::select(one_of(c("BusStopID","Longitude", "Latitude", "BusStopName"))) -> busstops_subset.df

busstops_subset.df$BusStopName <- factor(busstops_subset.df$BusStopName)
str(busstops_subset.df)

## Find busstops near the stores and subset dataset to those

# set the projection of the stores to projection of bus-stops
proj4string(stores.sp) <- proj4string(busstops_subset)

# get the nearest neighbour for each store among the bus stops
snap <- apply(spDists(stores.sp, busstops_subset), 1, which.min)
# returns a vector of indices with length = number of stores

# get only those bus-stops which are nearest to any of the stores
busstops_nearest <- busstops_subset.df[unique(snap),]
busstops_nearest.sp <-busstops_subset[unique(snap),]

# attach BusStopID of the nearest bus stop to the stores data
stores <- cbind(stores,busstops_subset.df[snap,"BusStopID"])
names(stores) <- c("StoreID", "Longitude", "Latitude", "Group","Labels","BusStopID")
head(stores)

## Find buslines at the selected bus stops

# 1. rasterize the vector data
Linie_2 <- c("Hauptbahnhof, A1","BahnhofstraÃŸe, A1","Elisabethkirche, A1", "Volkshochschule", "Erwin-Piscator-Haus",
             "Rudolphsplatz, A1","GutenbergstraÃŸe, A3","Philippshaus","Wilhelmsplatz, A5","RadestraÃŸe",
             "Frankfurter StraÃŸe A1", "Konrad-Adenauer-Brücke", "SÃ¼dbahnhof, A7", "SÃ¼dbahnhof, B4","Rollwiesenweg",
             "StadtbÃ¼ro, A3")
which(busstops_subset$name%in%Linie_2)

busstops_nearest.sp[busstops_nearest.sp$name%in%Linie_2,] -> Linie_2_stops

busroutes_sel[apply(rgeos::gIntersects(Linie_2_stops,busroutes_sel, byid = T),1,any),] -> Linie_2_route
class(Linie_2_route)

plot(Hesse_roads_sel, lwd = 2, col = "lightgrey")
plot(busroutes_sel, col = "blue", add = T)
plot(Linie_2_route, col = "red", add = T)

raster::extract(busroutes_sel, y = busstops_nearest.sp)

## Export the data

# Export selected bus-stops
write.table(x = busstops_nearest, file = "Data/busstops_near.csv",sep = ",", dec = ".",row.names = F)

# Export store data with BusStopID
write.table(x = stores, file = "Data/stores_busstops.csv",sep = ",", dec = ".",row.names = F)

# Export the spatial objects of the bus lines

save(busroute_1_shp, file = "Data/busroute_1_shp.RData")
save(busroute_2_shp, file = "Data/busroute_2_shp.RData")
save(busroute_3_shp, file = "Data/busroute_3_shp.RData")
save(busroute_4_shp, file = "Data/busroute_4_shp.RData")
save(busroute_5_shp, file = "Data/busroute_5_shp.RData")
save(busroute_6_shp, file = "Data/busroute_6_shp.RData")
save(busroute_7_shp, file = "Data/busroute_7_shp.RData")
save(busroute_8_shp, file = "Data/busroute_8_shp.RData")
save(busroute_9_shp, file = "Data/busroute_9_shp.RData")
save(busroute_10_shp, file = "Data/busroute_10_shp.RData")
