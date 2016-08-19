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
shinyUI(navbarPage("GfÖ 2016",id="tabs",
                   tabPanel("English",
                            fluidRow(
                              column(8,
                                     leafletOutput('mymap_en',height="450px")),
                              
                              column(4,
                                     h3("Some help on the App"),
                                     p("Welcome to our App helping you moving around and finding the best bars in Marburg, below are described the functionalities of this interactive map:"),
                                     HTML("<ul><li>When you hover your mouse on the bus stop nearby stores will appear</li><li>Clicking on a bus stop will fix the stores, in addition some bus stop have a link to a detailed map</li><li>You can select the bus line below, clicking on the bus line will send you to the timetable like: <b><a href='http://google.com'>here</a></b></li><li>You can also restrict the type of stores shown by using the drop down menu</li></ul>")
                                     
                              ),
                              fluidRow(
                                column(5,offset=1,
                                              checkboxGroupInput("stores_en", label = h3("Select the type of stores"), 
                                                                 choices = list("Bar" = "bar_pub_bistro", "Restaurant" = "restaurant", "Bakery" = "bakery","Hotel"="accomodation","Fast-food"="imbiss","Cafe"="cafe","Pharmacy"="pharmacy","Supermarket"="supermarket","Taxi"="taxi"),
                                                                 selected = "bar_pub_bistro",inline=TRUE)
                              ),
                              
                              column(5,
                                     radioButtons("lines_en",label=h3("Select a bus line"),choices=list("Line 1"=1,"Line 2"=2,"Line 3"=3,"Line 4"=4,"Line 5"=5,"Line 6"=6,"Line 7"=7,"Line 8"=8,"Line 9"=9,"Line 10"=10),selected=1,inline=TRUE)
                              ))
                              
                            )),
                   tabPanel("Deutsch",
                            fluidRow(
                              column(8,
                                     leafletOutput('mymap_de',height="450px")),
                              
                              column(4,
                                     h3("Hilfe bei den App"),
                                     p("Hier wird alles Deutsch geschrieben"),
                                     p("Ich meine alles"))
                            ),
                            fluidRow(
                              column(5, offset = 1,
                                     checkboxGroupInput("stores_de", label = h3("Geschäftsauswahl:"), 
                                                        choices = list("Bar" = "bar_pub_bistro", "Restaurant" = "restaurant", "Bakerei" = "bakery","Hotel"="accomodation","Imbiss"="imbiss","Cafe"="cafe","Apotheke"="pharmacy","Supermarkt"="supermarket","Taxi"="taxi"),
                                                        selected = "bar_pub_bistro",inline=TRUE)
                              ),
                              column(5,
                                     radioButtons("lines_de",label=h3("Buslinie Auswahlen:"),choices=list("Linie 1"=1,"Linie 2"=2,"Linie 3"=3,"Linie 4"=4,"Linie 5"=5,"Linie 6"=6,"Linie 7"=7,"Linie 8"=8,"Linie 9"=9,"Linie 10"=10),selected=1,inline=TRUE)
                              ))
                            )
))