#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  points<-eventReactive(input$nb_pts,{data.frame(infos=paste("Point",1:input$nb_pts),longitude=8.774149+rnorm(input$nb_pts,0,0.001),latitude=50.810685+rnorm(input$nb_pts,0,0.001))})
  
  output$mymap <- renderLeaflet({
    
    # generate bins based on input$bins from ui.R
    leaflet() %>%
      addTiles(urlTemplate='http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png') %>%
      addCircles(lng=8.774149, lat=50.810685, popup="The conference venue",radius=10,color="red")%>%
      addMarkers(data=points(),lng=~longitude,lat=~latitude,popup = ~infos)
  })
})
