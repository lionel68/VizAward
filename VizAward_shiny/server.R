########################################################################################
#                                    # # #                                             #
#This is the server part of the Shiny App for the Visualization awards GfOe 2016
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 28.07.2016
########################################################################################

#Next steps:
#Add templates for bus stop infos (DONE)
#Find markers for the different group of stores (partly done)
#Make appearance of stores reactive to the click on a nearby bus stop (DONE)
#Add lines for bus connection (TO DO)

#to load the App use: shinyAppDir("~/Documents/PhD/Presentation/GfÖ_2016/Visualization/VizAward_shiny/")

#load the libraries
library(shiny)
library(leaflet)
library(sp)
library(plyr)
#Define the server
shinyServer(function(input, output) {
  
  ################
  #simulation part
  set.seed(20160826)
  #simulate some data for the stores
  stores<-data.frame(infos=paste("Point",1:30),longitude=8.774149+rnorm(30,0,0.01),latitude=50.810685+rnorm(30,0,0.01),Group=gl(3,10,length = 30,labels = c("Restaurant","Bar","Club")))
  
  #simulate some data for the bus stop
  bus<-data.frame(BusStopID=1:5,BusStopName=letters[1:5],latitude=c(50.818,50.809,50.814,50.804,50.805),longitude=c(8.773,8.774,8.769,8.759,8.781),labels=c("<b>Hauptbahnof</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Uni</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Marienplatz</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Marktstrasse</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Weihenstephan</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>"))
  
  #link every store to the nearest bus stop (could change this to a specific distance radius in the future)
  #when the data are ready this will be set in the store dataframe
  dist_to_bus<-ddply(bus,"BusStopID",function(x) spDistsN1(as.matrix(stores[,c("longitude","latitude")]),as.numeric(x[,c("longitude","latitude")])))
  stores$BusStopID<-apply(dist_to_bus[,-1],2,function(x) which.min(x))
  
  #end of simulation part
  #will be replaced by data loading in the future
  ##################################################
  
  #create the icons for the stores and the conference center
  icon_uni<-makeIcon(iconUrl = "http://icons.iconarchive.com/icons/icons8/windows-8/32/Science-University-icon.png")
  icon_store<-iconList(
    Restaurant = makeIcon("http://icons.iconarchive.com/icons/icons8/windows-8/32/City-Restaurant-icon.png"),
    Bar= makeIcon("http://icons.iconarchive.com/icons/icons8/windows-8/32/Food-Bar-icon.png"),
    Club = makeIcon("http://icons.iconarchive.com/icons/icons8/windows-8/32/Music-Note-Music-icon.png"))
  
  
  #subset the store dataframe based on users selection
  points<-reactive({
    switch(input$group,
           "All" = stores,
           "Restaurant" = subset(stores,Group=="Restaurant"),
           "Bar" = subset(stores,Group=="Bar"),
           "Club" = subset(stores,Group=="Club"))
  })
  
  #
  #isClick<-reactiveValues(clickedMarker=NULL)
  #subset the stores again based on users click on Bus stop
  #points_b<-reactive({ifelse(is.null(),NULL,subset(points(),BusStopID==input$mymap_shape_click$id))})
  
  output$mymap <- renderLeaflet({
    
    #create the base map
    leaflet() %>%
      addTiles(urlTemplate='http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png') %>%
      addMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
      addCircles(data=bus,lng=~longitude,lat=~latitude,popup=~labels,color="red",radius=10,layerId=~BusStopID)
    })    
      
  #observe the users click on specific bus stop on the map
  #when the user click on the bus stop all stores related to this bus stop appear
  observe({
    proxy<-leafletProxy("mymap")
    if(!is.null(input$mymap_shape_click)){
      
      points_b<-subset(points(),BusStopID==input$mymap_shape_click$id)
      
      proxy%>%
        clearMarkers()%>% #to remove previously appearing stores
        addMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
        addMarkers(data=points_b,lng=~longitude,lat=~latitude,popup = ~infos,icon=~icon_store[Group])
    }
  })
  
  #if the user click on the map remove all store markers
  observe({
    proxy<-leafletProxy("mymap")
    if(!is.null(input$mymap_click)){
      proxy%>%
        clearMarkers()%>%
        addMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)
    }
  })
      
      #addPolylines(data=marb_l)
})

#for testing purposes
#leaflet() %>%
#  addTiles(urlTemplate='http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png') %>%
#  addMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
#  addMarkers(data=stores,lng=~longitude,lat=~latitude,popup = ~infos,icon=~icon_store[Group])%>%
#  addCircles(data=bus,lng=~longitude,lat=~latitude,popup=~labels,color="red",radius=10)

