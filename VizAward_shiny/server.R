########################################################################################
#                                    # # #                                             #
#This is the server part of the Shiny App for the Visualization awards GfOe 2016
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 02.08.2016
########################################################################################

#Next steps:
#Add templates for bus stop infos (DONE)
#Find markers for the different group of stores (DONE)
#Make appearance of stores reactive to the click on a nearby bus stop (DONE)
#Add lines for bus connection (TO DO)
#Allow the user to select only specific bus line (TO DO)
#Add store informations (ie website) in popup window (TODO)
#Issue with name encoding ... (TODO)

#to load the App use: shinyAppDir("~/Documents/PhD/Presentation/GfÖ_2016/Visualization/VizAward_shiny/")

#load the libraries
library(shiny)
library(leaflet) #github version
library(sp)
library(plyr)
library(RCurl) #to load data directly from github

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
  stores<-read.table(text=getURL("https://raw.githubusercontent.com/Lionel68/VizAward/master/Data/stores_busstops.csv"),head=TRUE,sep=",",stringsAsFactors = FALSE)
  
  #load bus stop
  bus<-read.table(text=getURL("https://raw.githubusercontent.com/Lionel68/VizAward/master/Data/busstops_near.csv"),head=TRUE,sep=",",stringsAsFactors = FALSE)
  
  #load bus line
  
  
  #create the icons for the stores and the conference center
  icon_uni<-makeAwesomeIcon(icon="university",library="fa",markerColor="red",iconColor="white")
 
  #have a look here for icons: http://fontawesome.io/icons/, http://getbootstrap.com/components/
  #and for making colors for the icons: http://www.hexcolortool.com/
  icons<-awesomeIconList(
    bar_pub_bistro=makeAwesomeIcon(icon = "beer",library = "fa",markerColor = "orange",iconColor = "green"),
    restaurant=makeAwesomeIcon(icon = "cutlery",library = "fa",markerColor = "white",iconColor = "darkred"),
    supermarket=makeAwesomeIcon(icon="shopping-cart",library = "glyphicon",markerColor = "cadetblue",iconColor = "#c3f971"),
    pharmacy=makeAwesomeIcon(icon="medkit",library="fa",markerColor = "darkblue"),
    accomodation=makeAwesomeIcon(icon="building-o",library="fa",markerColor = "darkblue"),
    bakery=makeAwesomeIcon(icon="grain",library="glyphicon",markerColor = "darkblue"),
    cafe=makeAwesomeIcon(icon="coffee",library="fa",markerColor = "darkblue"),
    imbiss=makeAwesomeIcon(icon="pizza",library="ion",markerColor = "white",iconColor="pink"),
    taxi=makeAwesomeIcon(icon="taxi",library="fa",markerColor = "darkblue")
  ) 
  
  
  #the map
  output$mymap <- renderLeaflet({
    
    #create the base map
    leaflet() %>%
      setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
      addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",option=tileOptions(minZoom=13,maxZoom=18))%>%
      addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
      addCircles(data=bus,lng=~Longitude,lat=~Latitude,color="red",radius=5,layerId=~BusStopID,label=~BusStopName,popup=~BusStopName)
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
  #the function to show the stores
  showStores<-function(ID){
    selectStores <- subset(subStores(),BusStopID==ID)
    if(dim(selectStores)[1]>0){
      leafletProxy("mymap")%>%
        addAwesomeMarkers(data=selectStores,lng=~Longitude,lat=~Latitude,icon=~icons[Group],label=~Labels,popup=~Labels)
    }
  }
  #set the different events that may happen based on users click on the map
  events <- reactiveValues(mouse_marker=NULL,mouse_out=NULL,click_marker=NULL,click_map=NULL)
  #if the mouse hover a bus stop show the nearby stores
  observeEvent(input$mymap_shape_mouseover,{
    mouse_out <- NULL
    if(is.null(events$click_marker)){
      events$mouse_marker <- input$mymap_shape_mouseover
      showStores(events$mouse_marker$id)
    }
  })
  #if the mouse leaves a bus stop clear the markers
  observeEvent(input$mymap_shape_mouseout,{
    events$mouse_marker <- NULL
    leafletProxy("mymap")%>%
      clearMarkers()%>%
      addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)
    if(!is.null(events$click_marker)){
      showStores(events$click_marker$id)
    }
  })
  #if the user click on a bus stop show the nearby stores
  observeEvent(input$mymap_shape_click,{
   events$click_map <- NULL
   events$click_marker <- input$mymap_shape_click
   showStores(events$click_marker$id)
 })
 #if the user click on the map remove the markers
 observeEvent(input$mymap_click,{
   events$click_marker <-NULL
   leafletProxy("mymap")%>%
     clearMarkers()%>%
     addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)
 })

})

#for testing purposes
#leaflet() %>%
#  setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
#  addPolylines(data=bus_line_list[[1]],label="Line 2",stroke=TRUE,color="green",noClip=TRUE)%>%
#  addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",option=tileOptions(minZoom=13,maxZoom=18))%>%
#  addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)%>%
#  addCircles(data=bus,lng=~Longitude,lat=~Latitude,label=~BusStopName,color="red",radius=10)%>%
#  addAwesomeMarkers(data=stores,lng=~Longitude,lat=~Latitude,icon=~icons[Group],label = ~Labels,labelOptions = list(opacity=5))
  
  

