########################################################################################
#                                    # # #                                             #
#This is the server part of the Shiny App for the Visualization awards GfOe 2016
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 10.08.2016
########################################################################################

#Next steps:
#Add templates for bus stop infos (DONE)
#Find markers for the different group of stores (DONE)
#Make appearance of stores reactive to the click on a nearby bus stop (DONE)
#Add lines for bus connection (DONE)
#Allow the user to select only specific bus line (DONE)
#Add store informations (ie website) in popup window (TODO)
#Issue with name encoding ... (TODO)
#Correct bug when clicking stores l156

#to load the App use: shinyAppDir("~/Documents/PhD/Presentation/GfÖ_2016/Visualization/VizAward_shiny/")

#load the libraries
library(shiny)
library(leaflet) #github version
library(sp)
library(plyr)
library(RCurl) #to load data directly from github
library(viridis)

#Define the server
shinyServer(function(input, output) {
  
  ################
  #simulation part
  #set.seed(20160826)
  #simulate some data for the stores
  #stores<-data.frame(infos=paste("Point",1:30),longitude=8.774149+rnorm(30,0,0.01),latitude=50.810685+rnorm(30,0,0.01),Group=gl(n = 6,k=5,length = 30,labels = c("Restaurant","Bar","Club","Market","Bank","Hospital")))
  
  #simulate some data for the bus stop
  #bus<-data.frame(BusStopID=1:5,BusStopName=letters[1:5],latitude=c(50.818,50.809,50.814,50.804,50.805),longitude=c(8.773,8.774,8.769,8.759,8.781),labels=c("<b>Hauptbahnof</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Uni</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Marienplatz</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Marktstrasse</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Weihenstephan</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>"))
  
  #link every store to the nearest bus stop (could change this to a specific distance radius in the future)
  #when the data are ready this will be set in the store dataframe
  #snap <- apply(spDists(as.matrix(stores[,c("longitude","latitude")]), as.matrix(bus[,c("longitude","latitude")])), 1, which.min)
  #stores$BusStopID<-snap
  
  #end of simulation part
  #will be replaced by data loading in the future
  ##################################################

  #load the actual store data from GitHub
  #stores<-read.table(text=getURL("https://raw.githubusercontent.com/Lionel68/VizAward/master/Data/stores_busstops.csv"),head=TRUE,sep=",",stringsAsFactors = FALSE)
  stores<-read.table("/home/lionel/Documents/PhD/Presentation/GfÖ_2016/Visualization/Data/store_data.csv",sep=" ",head=TRUE)
  #load bus stop
  #bus<-read.table(text=getURL("https://raw.githubusercontent.com/Lionel68/VizAward/master/Data/busstops_near.csv"),head=TRUE,sep=",",stringsAsFactors = FALSE)
  bus<-read.table("/home/lionel/Documents/PhD/Presentation/GfÖ_2016/Visualization/Data/bus_data.csv",sep=" ",head=TRUE)
  #load bus line
  load("~/Documents/PhD/Presentation/GfÖ_2016/Visualization/Data/bus_line_list.RData",envir=.GlobalEnv)
  names(bus_line_list)<-as.character(1:10)
  
  #create the icons for the stores and the conference center
  icon_uni<-makeAwesomeIcon(icon="university",library="fa",markerColor="red",iconColor="white")
 
  icon_bus<-makeAwesomeIcon(icon="bus",library = "fa",markerColor="darkblue",iconColor="white")
  #have a look here for icons: http://fontawesome.io/icons/, http://getbootstrap.com/components/
  #and for making colors for the icons: http://www.hexcolortool.com/
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
  
  #color palette for the bus line
  col_line <- colorFactor(viridis(10),as.character(1:10))
  
  #the map
  output$mymap <- renderLeaflet({
    
    #create the base map
    leaflet() %>%
      setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
      addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",option=tileOptions(minZoom=13,maxZoom=18))%>%
      addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)
  })
    
  #if the user set a specific group
  subStores<-reactive({
    if(input$group!="All"){
      subset(stores,Group==input$group)
    }
    else{
      stores
    }
  })
  
  
  #if the user select certain bus line
  subLines<-reactive({
    bus_line_list[input$lines][[1]]
  })
  
  subBus<-reactive({
    bus[grep(input$lines,bus$Lines),]
  })
  
  line_popup<-reactive({
    paste0("<b><a href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/Fahrplan_2016/ab_11.04.16/Linie_",input$lines,".pdf'>Linie ",input$lines,"</a></b>")
  })
  
  observe({
    leafletProxy("mymap")%>%
      clearGroup("Line")%>%
      addPolylines(data=subLines(),color = ~col_line(input$lines),label = paste("Line",input$lines),group = "Line",popup = line_popup())%>%
      showGroup("Line")%>%
      addAwesomeMarkers(data=subBus(),lng=~Longitude,lat=~Latitude,icon=icon_bus,layerId=~BusStopID,popup=~Tag,group="Stop")
  })
  
  
  #the function to show the stores
  showStores<-function(ID){
    if(!is.null(ID)){
      selectStores <- subset(subStores(),BusStopID==ID)
      if(dim(selectStores)[1]>0){
        leafletProxy("mymap")%>%
          showGroup("Stores")%>%
          addAwesomeMarkers(data=selectStores,lng=~Longitude,lat=~Latitude,icon=~icons[Group],label=~Labels,popup=~Labels,layerId=~StoreID,group="Stores")
      }
    }
  }
  
  #set the different events that may happen based on users click on the map
  events <- reactiveValues(mouse_marker=NULL,mouse_out=NULL,click_marker=NULL,click_map=NULL)
  #if the mouse hover a bus stop show the nearby stores
  observeEvent(input$mymap_marker_mouseover,{
    events$mouse_out <- NULL
    if(is.null(events$click_marker)){
      events$mouse_marker <- input$mymap_marker_mouseover
      showStores(events$mouse_marker$id)
    }
  })
  #if the mouse leaves a bus stop clear the markers
  observeEvent(input$mymap_marker_mouseout,{
    events$mouse_marker <- NULL
    leafletProxy("mymap")%>%
      clearGroup("Stores")
    if(!is.null(events$click_marker)){
      showStores(events$click_marker$id)
    }
  })
  #if the user click on a bus stop show the nearby stores
  observeEvent(input$mymap_marker_click,{
   events$click_map <- NULL
   events$click_marker <- input$mymap_marker_click
   if(!is.null(events$click_marker$id)){
     if(grep("Stop",events$click_marker$id))
       showStores(events$click_marker$id)
   }
 })
 #if the user click on the map remove the markers
 observeEvent(input$mymap_click,{
   events$click_marker <-NULL
   leafletProxy("mymap")%>%
     clearGroup("Stores")
  })

})

#for testing purposes
#leaflet() %>%
#  setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
#  addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",option=tileOptions(minZoom=13,maxZoom=18))%>%
#  addAwesomeMarkers(data=busstop_new,lng=~Longitude,lat=~Latitude,popup=~Tag)
#  addPolylines(data=bus_line_list[[1]],stroke=TRUE,color="green",noClip = FALSE)%>%
#  addPolylines(data=bus_line_list[[2]],stroke=TRUE,color="red",noClip = FALSE)%>%
#  %>%
#  addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
#  addAwesomeMarkers(data=bus,lng=~Longitude,lat=~Latitude,label=~BusStopName,icon=icon_bus)%>%
#  addAwesomeMarkers(data=stores,lng=~Longitude,lat=~Latitude,icon=~icons[Group],label = ~Labels,labelOptions = list(opacity=5))
  


#busL<-NULL  
#f#or(i in 1:10){
  
#}
#coords<-ldply(tmp@lines,function(x) x@Lines[[1]]@coords)
#coords<-coords[-duplicated(coords),]
#bus1<-SpatialLinesDataFrame(SpatialLines(list(Lines(list(Line()),ID="1"))),data.frame(LineNb="Line 1"))#

#pts<-SpatialPoints(ldply(tmp@lines,function(x) x@Lines[[1]]@coords))#
