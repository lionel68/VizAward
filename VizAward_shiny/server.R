########################################################################################
#                                    # # #                                             #
#This is the server part of the Shiny App for the Visualization awards GfOe 2016
#code written by Lionel R. Hertzog and Nadja Simmons

#Updated: 30.08.2016
########################################################################################

#load the libraries
library(shiny)
library(leaflet) #github version
library(sp)
library(plyr)
library(RCurl) #to load data directly from github
library(viridis)

# load the data
# load the actual store data from GitHub
# stores<-read.table(text=getURL("https://raw.githubusercontent.com/Lionel68/VizAward/master/Data/stores_busstops.csv"),head=TRUE,sep=",",stringsAsFactors = FALSE)
stores<-read.table("./Data/stores_busstops.csv",sep=" ",head=TRUE,stringsAsFactors = FALSE)
# load bus stop
# bus<-read.table(text=getURL("https://raw.githubusercontent.com/Lionel68/VizAward/master/Data/busstops_near.csv"),head=TRUE,sep=",",stringsAsFactors = FALSE)
bus<-read.table("./Data/busstops_near.csv",sep=" ",head=TRUE,stringsAsFactors = FALSE)
 
# load bus line
load("./Data/bus_line_list.RData",envir=.GlobalEnv)
names(bus_line_list)<-as.character(1:10)


# Define the server
shinyServer(function(input, output) {
  
  # create the icons for the stores and the conference center
  icon_uni<-makeAwesomeIcon(icon="university",library="fa",markerColor="red",iconColor="white")
 
  icon_bus<-makeAwesomeIcon(icon="bus",library = "fa",markerColor="darkblue",iconColor="white")
  # have a look here for icons: http://fontawesome.io/icons/, http://getbootstrap.com/components/
  # and for making colors for the icons: http://www.hexcolortool.com/
  icons<-awesomeIconList(
    bar_pub_bistro=makeAwesomeIcon(icon = "beer",library = "fa",markerColor = "white",iconColor = "#8dd3c7"),
    restaurant=makeAwesomeIcon(icon = "cutlery",library = "fa",markerColor = "white",iconColor = "#e6e600"),
    supermarket=makeAwesomeIcon(icon="shopping-cart",library = "glyphicon",markerColor = "white",iconColor = "#bebada"),
    pharmacy=makeAwesomeIcon(icon="medkit",library="fa",markerColor = "white",iconColor="#fb8072"),
    accomodation=makeAwesomeIcon(icon="building-o",library="fa",markerColor = "white",iconColor = "#80b1d3"),
    bakery=makeAwesomeIcon(icon="grain",library="glyphicon",markerColor = "white",iconColor="#fdb462"),
    cafe=makeAwesomeIcon(icon="coffee",library="fa",markerColor = "white",iconColor="#b3de69"),
    imbiss=makeAwesomeIcon(icon="pizza",library="ion",markerColor = "white",iconColor="#d90d76"),
    taxi=makeAwesomeIcon(icon="taxi",library="fa",markerColor = "white",iconColor = "#737373")
  ) 
  
  # color palette for the bus line
  col_line <- colorFactor(viridis(10),as.character(1:10))
  

  # reactive element to only select the bus stop along the selected bus line
  subBus<-reactive({
    if(input$tabs=="English"){
      if(input$lines_en==1){
        tmp<-bus[grep(input$lines_en,bus$Lines),]
        #remove the 10 that are also matched by 1
        tmp[-grep("10",tmp$Lines),]
      }
      else{
        bus[grep(input$lines_en,bus$Lines),]
      }
    }
    else{
      if(input$lines_de==1){
        tmp<-bus[grep(input$lines_de,bus$Lines),]
        #remove the 10 that are also matched by 1
        tmp[-grep("10",tmp$Lines),]
      }
      else{
        bus[grep(input$lines_de,bus$Lines),]
      }
    }
    
  })
  
  # if the user set a specific group
  subStores<-reactive({
    if(input$tabs=="English"){
      subset(stores,Group%in%input$stores_en)
    }
    else{
      subset(stores,Group%in%input$stores_de)
    }
  })
  
  
  # if the user select certain bus line
  subLines<-reactive({
    if(input$tabs=="English"){
      bus_line_list[input$lines_en][[1]]
    }
    else{
      bus_line_list[input$lines_de][[1]]
    }
  })
  
  # dynamically set the popup window for the timetable of the bus line
  line_popup<-reactive({
    if(input$tabs=="English"){
      paste0("<b><a target='_blank' href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/Fahrplan_2016/ab_11.04.16/Linie_",input$lines_en,".pdf'>Linie ",input$lines_en,"</a></b>")
    }
    else{
      paste0("<b><a target= '_blank' href='http://stadtwerke-marburg.de/fileadmin/media/stadtverkehr/Fahrplan_2016/ab_11.04.16/Linie_",input$lines_de,".pdf'>Linie ",input$lines_de,"</a></b>")
      
    }
 })


  # the function to show the stores
  showStores<-function(ID,lg){
    if(!is.null(ID)){
      selectStores <- subset(subStores(),BusStopID==ID)
      if(dim(selectStores)[1]>0){
        leafletProxy(paste0("mymap_",lg))%>%
          showGroup("Stores")%>%
          addAwesomeMarkers(data=selectStores,lng=~Longitude,lat=~Latitude,icon=~icons[Group],label=~Labels,popup=~Labels,layerId=~StoreID,group="Stores")
      }
    }
  }
  
  # the base map for the english part
  output$mymap_en <- renderLeaflet({
    
    leaflet() %>%
      setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
      addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",option=tileOptions(minZoom=13,maxZoom=18))%>%
      addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="The conference venue",icon=icon_uni)
  })
  
  # add the bus line
  observe({
    leafletProxy("mymap_en")%>%
      clearGroup("Line")%>%
      addPolylines(data=subLines(),color = ~col_line(input$lines_en),label = paste("Line",input$lines_en),group = "Line",popup = line_popup())%>%
      showGroup("Line")
  })
  # add the bus stop
  observe({
    leafletProxy("mymap_en",data=subBus())%>%
      clearGroup("Stop")%>%
      addAwesomeMarkers(lng=~Longitude,lat=~Latitude,icon=icon_bus,group="Stop",layerId=~BusStopID,label=~BusStopName,popup=~Tag)%>%
      showGroup("Stop")
  })
  

  
  # set the different events that may happen based on users click on the map
  events <- reactiveValues(mouse_marker=NULL,mouse_out=NULL,click_marker=NULL,click_map=NULL)
  # if the mouse hover a bus stop show the nearby stores
  observeEvent(input$mymap_en_marker_mouseover,{
    events$mouse_out <- NULL
    if(is.null(events$click_marker)){
      events$mouse_marker <- input$mymap_en_marker_mouseover
      showStores(events$mouse_marker$id,"en")
    }
  })
  # if the mouse leaves a bus stop clear the markers
  observeEvent(input$mymap_en_marker_mouseout,{
    events$mouse_marker <- NULL
    leafletProxy("mymap_en")%>%
      clearGroup("Stores")
    if(!is.null(events$click_marker)){
      showStores(events$click_marker$id,"en")
    }
  })
  # if the user click on a bus stop show the nearby stores
  observeEvent(input$mymap_en_marker_click,{
    events$click_map <- NULL
    events$click_marker <- input$mymap_en_marker_click
    if(!is.null(events$click_marker$id)){
      if(length(grep("Stop",events$click_marker$id)!=0))
        showStores(events$click_marker$id,"en")
    }
  })
  # if the user click on the map remove the markers
  observeEvent(input$mymap_en_click,{
    events$click_marker <-NULL
    leafletProxy("mymap_en")%>%
      clearGroup("Stores")
  })
  
  
  # German version
  output$mymap_de <- renderLeaflet({
    
    leaflet() %>%
      setView(lng=8.774149, lat=50.810685,zoom = 14)%>%
      addTiles("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibGlvbmVsNjgiLCJhIjoiY2lyOHVtY2ZqMDAycmlsbHd3cXF4azhzdiJ9.FHJtGBW1bhjCr-JLnC4brw",option=tileOptions(minZoom=13,maxZoom=18))%>%
      addAwesomeMarkers(lng=8.774149, lat=50.810685, popup="Konferenzzentrum",icon=icon_uni)
  })
  
  # add the bus line
  observe({
    leafletProxy("mymap_de")%>%
      clearGroup("Line")%>%
      addPolylines(data=subLines(),color = ~col_line(input$lines_de),label = paste("Line",input$lines_de),group = "Line",popup = line_popup())%>%
      showGroup("Line")
  })
  # add the bus stop
  observe({
    leafletProxy("mymap_de",data=subBus())%>%
      clearGroup("Stop")%>%
      addAwesomeMarkers(lng=~Longitude,lat=~Latitude,icon=icon_bus,group="Stop",layerId=~BusStopID,label=~BusStopName,popup=~Tag)%>%
      showGroup("Stop")
  })
  
  
  
  # set the different events that may happen based on users click on the map
  events <- reactiveValues(mouse_marker=NULL,mouse_out=NULL,click_marker=NULL,click_map=NULL)
  # if the mouse hover a bus stop show the nearby stores
  observeEvent(input$mymap_de_marker_mouseover,{
    events$mouse_out <- NULL
    if(is.null(events$click_marker)){
      events$mouse_marker <- input$mymap_de_marker_mouseover
      showStores(events$mouse_marker$id,"de")
    }
  })
  # if the mouse leaves a bus stop clear the markers
  observeEvent(input$mymap_de_marker_mouseout,{
    events$mouse_marker <- NULL
    leafletProxy("mymap_de")%>%
      clearGroup("Stores")
    if(!is.null(events$click_marker)){
      showStores(events$click_marker$id,"de")
    }
  })
  # if the user click on a bus stop show the nearby stores
  observeEvent(input$mymap_de_marker_click,{
    events$click_map <- NULL
    events$click_marker <- input$mymap_de_marker_click
    if(!is.null(events$click_marker$id)){
      if(length(grep("Stop",events$click_marker$id)!=0))
        showStores(events$click_marker$id,"de")
    }
  })
  # if the user click on the map remove the markers
  observeEvent(input$mymap_de_click,{
    events$click_marker <-NULL
    leafletProxy("mymap_de")%>%
      clearGroup("Stores")
  })
    
 
 

})
