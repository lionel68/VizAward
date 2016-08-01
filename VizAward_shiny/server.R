########################################################################################
#                                    # # #                                             #
#This is the server part of the Shiny App for the Visualization awards GfOe 2016
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 01.08.2016
########################################################################################

#Next steps:
#Add templates for bus stop infos (DONE)
#Find markers for the different group of stores (partly done)
#Make appearance of stores reactive to the click on a nearby bus stop (DONE)
#Add lines for bus connection (TO DO)

#to load the App use: shinyAppDir("~/Documents/PhD/Presentation/GfÖ_2016/Visualization/VizAward_shiny/")

#load the libraries
library(shiny)
library(leaflet) #github version
library(sp)
library(plyr)
#Define the server
shinyServer(function(input, output) {
  
  ################
  #simulation part
  set.seed(20160826)
  #simulate some data for the stores
  stores<-data.frame(infos=paste("Point",1:30),longitude=8.774149+rnorm(30,0,0.01),latitude=50.810685+rnorm(30,0,0.01),Group=gl(n = 6,k=5,length = 30,labels = c("Restaurant","Bar","Club","Market","Bank","Hospital")))
  
  #simulate some data for the bus stop
  bus<-data.frame(BusStopID=1:5,BusStopName=letters[1:5],latitude=c(50.818,50.809,50.814,50.804,50.805),longitude=c(8.773,8.774,8.769,8.759,8.781),labels=c("<b>Hauptbahnof</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Uni</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Marienplatz</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Marktstrasse</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>","<b>Weihenstephan</b><br/>Linie:<br/><b><a href='http://google.com'>1</a></b>"))
  
  #link every store to the nearest bus stop (could change this to a specific distance radius in the future)
  #when the data are ready this will be set in the store dataframe
  snap <- apply(spDists(as.matrix(stores[,c("longitude","latitude")]), as.matrix(bus[,c("longitude","latitude")])), 1, which.min)
  stores$BusStopID<-snap
  
  #end of simulation part
  #will be replaced by data loading in the future
  ##################################################
  
  #create the icons for the stores and the conference center
  icon_uni<-makeAwesomeIcon(icon="university",library="fa",markerColor="red",iconColor="white")
 
  #have a look here for icons: http://fontawesome.io/icons/, http://getbootstrap.com/components/
  #and for making colors for the icons: http://www.hexcolortool.com/
  icons<-awesomeIconList(
    Bar=makeAwesomeIcon(icon = "beer",library = "fa",markerColor = "orange",iconColor = "green"),
    Restaurant=makeAwesomeIcon(icon = "cutlery",library = "fa",markerColor = "white",iconColor = "darkred"),
    Club=makeAwesomeIcon(icon="music",library="fa",markerColor="purple",iconColor="thisle"),
    Market=makeAwesomeIcon(icon="shopping-cart",library = "glyphicon",markerColor = "cadetblue",iconColor = "#c3f971"),
    Bank=makeAwesomeIcon(icon="piggy-bank",library = "glyphicon",markerColor = "darkgreen",iconColor = "#a0aeca"),
    Hospital=makeAwesomeIcon(icon="medkit",library="fa",markerColor = "darkblue")
  ) 
  
  
  #subset the store dataframe based on users selection
  points<-reactive({
   switch(input$group,
         "All" = stores,
         "Restaurant" = subset(stores,Group=="Restaurant"),
         "Bar" = subset(stores,Group=="Bar"),
         "Club" = subset(stores,Group=="Club"),
         "Bank" = subset(stores,Group=="Bank"),
         "Hospital" = subset(stores,Group=="Hospital"))
  })
  
  #
  #isClick<-reactiveValues(clickedMarker=NULL)
  #subset the stores again based on users click on Bus stop
  #points_b<-reactive({ifelse(is.null(),NULL,subset(points(),BusStopID==input$mymap_shape_click$id))})
  
  output$mymap <- renderLeaflet({
    
    #create the base map
    leaflet() %>%
      addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw")%>%
      addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
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
        addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
        addAwesomeMarkers(data=points_b,lng=~longitude,lat=~latitude,popup = ~infos,label=~infos,icon=~icons[Group])
    }
  })
  
  #if the user click on the map remove all store markers
  observe({
    proxy<-leafletProxy("mymap")
    if(!is.null(input$mymap_click)){
      proxy%>%
        clearMarkers()%>%
        addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)
    }
  })
      
      #addPolylines(data=marb_l)
})

#for testing purposes
#leaflet() %>%
#  addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw")%>%
#  addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
#  addAwesomeMarkers(data=stores,lng=~longitude,lat=~latitude,icon=~icons[Group],label = ~Group,labelOptions = list(opacity=5))%>%
#  addCircles(data=bus,lng=~longitude,lat=~latitude,popup=~labels,color="red",radius=10)

