#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


#Make Layout nicer (TODO)
#Add more user controls (TODO)


library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Second draft of an interactive map in Shiny"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(sidebarPanel(
    #example of keeping only specific groups in the data
    selectInput("group", label=h2("Type of stores:"), 
                choices = list("All"="All","Restaurant"="restaurant","Bar"="bar_pub_bistro","Cafe"="cafe","Fast-Food"="imbiss","Pharmacy"="pharmacy","Supermarket"="supermarket","Taxi"="taxi","Bakery"="bakery","Hotel"="accomodation"),
                selected="All")),
    
    # Show a plot of the generated distribution
    mainPanel(
       leafletOutput("mymap")
    )
  )
))
