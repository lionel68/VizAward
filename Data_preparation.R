########################################################################################
#                                    # # #                                             #
#This file is used to prepare the final data used in the shiny application             #
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 17.08.2016
########################################################################################


library(plyr)
library(dplyr)
library(tidyr) # more data management
library(sp)
library(rgeos)

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

### I. Prepare the store data
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

#rename some categories
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

# Repeat selection of spatialPointsDataframe
csv.spdf[validUTF8(as.character(csv.spdf$name)),] -> stores.sp
stores.sp[validUTF8(as.character(stores.sp$name)),] -> stores.sp

#remove category other essentials
stores.sp<-subset(stores.sp,stores.sp$category!="other_essentials")
#remove duplicated points
stores.sp<-stores.sp[-which(duplicated(stores.sp@coords[,c("longitude","latitude")])),]

###--------------------------------------------------------------------------------------
### II. Prepare the bus stop data

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

# Convert bus stop names to character for corrections
busstops_subset.df$BusStopName <- as.character(busstops_subset.df$BusStopName)

str(busstops_subset.df)

###-------------------------------------------------------------------------------------
### III. Find busstops near the stores and subset dataset to those

# set the projection of the stores to projection of bus-stops
proj4string(stores.sp) <- proj4string(busstops_subset)

# get the nearest neighbour for each store among the bus stops
snap <- apply(spDists(stores.sp, busstops_subset), 1, which.min)
# returns a vector of indices with length = number of stores

# get only those bus-stops which are nearest to any of the stores
busstops_nearest <- busstops_subset.df[unique(snap),]
busstops_nearest.sp <-busstops_subset[unique(snap),]

#correct bus stop name "Marburg"
busstops_nearest[6,"BusStopName"]<-"Pommernweg"
busstops_nearest[42,"BusStopName"]<-"Elisabethenhof"
busstops_nearest[74,"BusStopName"]<-"Ginseldorfer Weg"
busstops_nearest[33,"BusStopName"]<-"Afföllerstraße"
busstops_nearest[13,"BusStopName"]<-"Am Kaufmarkt"
busstops_nearest<-busstops_nearest[-which(busstops_nearest$BusStopName=="Marburg"),]

#average coords for bus stops with multiple lines (like Hauptbahnof, A1)

busstops_nearest$Name2<-sapply(strsplit(busstops_nearest$BusStopName,split = ","),function(x) x[1])
busstops_nearest[busstops_nearest$Name2=="Marburg","Name2"]<-"Marburg, Fernbusstation"

###-------------------------------------------------------------------------------------
### IV. Find buslines at the selected bus stops

# Add column to identify the buslines for each stop

busstops_nearest <- cbind(busstops_nearest, NbBusLine = 0, BusLine = "L",stringsAsFactors=FALSE)
# make sure that BusLine is not a factor but a character
str(busstops_nearest)

# # for each bus line, search for those bus stops in the selection which are part of their route
# for (i in 1:length(bus_line_list)){
#   stops <- which(busstops_nearest.sp$name%in%bus_line_list[[i]]@data$name)
#   busstops_nearest[stops,"NbBusLine"] <- busstops_nearest[stops,"NbBusLine"]+1
#   busstops_nearest[stops,"BusLine"] <- paste(busstops_nearest[stops,"BusLine"],as.character(i),sep = "-")
# }
### This does not work once the names of bus stops are corrected!

###################
#Alternative way
#########
#using gIntersection
#find which bus stops intersect with which lines
bus_sp<-busstops_nearest
coordinates(bus_sp)<-bus_sp[,c("Longitude","Latitude")]
proj4string(bus_sp)<-proj4string(bus_line_list[[1]])

busstops_nearest$Lines<-"L"
for(i in 1:10){
  tmp<-gIntersection(bus_line_list[[i]],bus_sp)
  busstops_nearest[busstops_nearest$Longitude%in%coordinates(tmp)[,1],"Lines"]<-paste(busstops_nearest[busstops_nearest$Longitude%in%coordinates(tmp)[,1],"Lines"],i,sep="-")
}

# Remove bus stops which do not belong to a bus line
busstops_nearest %>% filter(Lines !="L") -> busstops_nearest

str(busstops_nearest)

###-------------------------------------------------------------------------------------
### V. Prepare final dataset

# Calculate the average coordinates for bus stations with different platforms
busstops_nearest%>%
  group_by(Name2)%>%
  summarise(Longitude=mean(Longitude),Latitude=mean(Latitude),Lines=toString(Lines))->busstop_new

head(busstop_new)

# Recalculate the nearest neighbour for each store among the new bus stops
class(busstop_new) <- "data.frame"
busstop_new.sp <- SpatialPointsDataFrame(busstop_new[,c("Longitude","Latitude")], 
                                   data = busstop_new)
proj4string(busstop_new.sp) <- proj4string(stores.sp)

snap_new <- apply(spDists(stores.sp, busstop_new.sp), 1, which.min)

# attach BusStopID of the nearest bus stop to the stores data
stores <- cbind(stores,busstop_new[snap_new,"Name2"])
names(stores) <- c("StoreID", "Longitude", "Latitude", "Group","Labels","Name2")
head(stores)

busstop_new$BusStopID<-paste("Stop",1:nrow(busstop_new))

#add link to HTML page
pages<-readLines("Data/bus_pages.txt") #this is just a file with the bus stops where extra infos is available
busstop_new$Tag<-busstop_new$Name2

for(i in which(busstop_new$Tag%in%pages)){
  busstop_new$Tag[i]<-paste0("<b><a href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/haltest/",busstop_new[i,"Tag"],".pdf'>",busstop_new[i,"Tag"],"</a></b>")
}

busstop_new$Tag[busstop_new$Name2=="Botanischer Garten"]<-"<b><a href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/haltest/Botanischer_Garten.pdf'>Botanischer Garten</a></b>"
busstop_new$Tag[busstop_new$Name2=="Marburg-BahnhofstraÃŸe"]<-"<b><a href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/haltest/Bahnhofstraße.pdf'>Bahnhofstraße</a></b>"
busstop_new$Tag[busstop_new$Name2=="Rudolphsplatz"]<-"<b><a href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/haltest/Rudolphsplatz_Stadthalle.pdf'>Rudolphplatz</a></b>"

bus_sp<-as.data.frame(busstop_new)
coordinates(bus_sp)<-bus_sp[,c("Longitude","Latitude")]
proj4string(bus_sp)<-proj4string(bus_line_list[[1]])


###-------------------------------------------------------------------------------------
### VI. First look at the results

busline_colors <- c("#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c",
                    "#fdbf6f","#ff7f00","#cab2d6","#6a3d9a")
# those colors were selected from http://colorbrewer2.org/
  
plot(Hesse_roads_sel, lwd = 2, col = "lightgrey")
for (i in 1: 10){
  plot(bus_line_list[[i]], col = busline_colors[i], add = T)
}

###-------------------------------------------------------------------------------------
### VI. Export the data

# Export selected bus-stops
write.table(x = busstops_nearest, file = "Data/busstops_near.csv",sep = ",", dec = ".",row.names = F)

# Export store data with BusStopID
write.table(x = stores, file = "Data/stores_busstops.csv",sep = ",", dec = ".",row.names = F)

# Export the spatial objects of the bus lines
save(bus_line_list, file ="Data/bus_line_list.RData")

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
