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
                                     h3("How to use this App"),
                                     p("Welcome to our App which helps you with moving around and finding the best bars in Marburg. These are the functionalities of this interactive map:"),
                                     HTML("<ul><li>When you hover your mouse on the bus stop, nearby stores will appear</li><li>Clicking on a bus stop will fix the stores. Some bus stop have a link to a detailed map like: <b><a target='_blank' href='http://www.stadtwerke-marburg.de/fileadmin/media/stadtverkehr/haltest/Erlenring.pdf'>Erlenring</a></b></li><li>Clicking on the bus line will make a link to the timetable appear like: <b><a target='_blank' href='http://www.stadtwerke-marburg.de/fileadmin/media/stadtverkehr/Fahrplan_2016/ab_11.04.16/Linie_1.pdf'>Linie 1</a></b></li><li>You can also restrict the type of stores shown by checking the specific boxes</li></ul>"),
                                     p("For example: To find the venue for the GfÖ Club Night/BBQ, select 'Restaurant' and bus line 10. Then search for the bus stop 'Ortenbergcenter' and a click on the bus icon will show you the restaurant."),
                                     p("Enjoy and have a nice time in Marburg!")
                                     
                              ),
                              fluidRow(
                                column(5,offset=1,
                                              checkboxGroupInput("stores_en", label = h3("Select the type of stores"), 
                                                                 choices = list("Bar" = "bar_pub_bistro", "Restaurant" = "restaurant", "Bakery" = "bakery","Hotel"="accomodation","Fast-food"="imbiss","Cafe"="cafe","Pharmacy"="pharmacy","Supermarket"="supermarket","Taxi"="taxi"),
                                                                 selected = "bar_pub_bistro",inline=TRUE)
                              ),
                              
                              column(5,
                                     radioButtons("lines_en",label=h3("Select a bus line"),choices=list("Line 1"=1,"Line 2"=2,"Line 3"=3,"Line 4"=4,"Line 5"=5,"Line 6"=6,"Line 7"=7,"Line 8"=8,"Line 9"=9,"Line 10"=10),selected=1,inline=TRUE)
                              )),
                              hr(),
                              column(8,offset=3,
                                     HTML("This App was developed by <b><a target='_blank' href=http://toek.wzw.tum.de/index.php?id=147>Lionel Hertzog</a></b> and <b><a target='_blank' href='http://toek.wzw.tum.de/index.php?id=106'>Nadja Simons</a></b>")
                              )
                            
                            )),
                   tabPanel("Deutsch",
                            fluidRow(
                              column(8,
                                     leafletOutput('mymap_de',height="450px")),
                              
                              column(4,
                                     h3("Eine kleine Hilfe für diese App"),
                                     p("Wilkommen in unserer App, die Dir dabei hilft dich in Marburg zurechtzufinden und die besten Bars in Marburg zu entdecken. Und so funktioniert's:"),
                                     HTML("<ul><li>Sobald Du die Maus über eine Bushaltestelle bewegst, werden die wichtigen Orte in der Nähe angezeigt</li><li>Beim Klicke auf die Bushaltestelle werden die Icons fixiert und mit einem Mausklick wird deren Beschreibung angezeigt. Einige Bushaltestellen enthalten einen Link zu einer detailierten Karte: <b><a target='_blank' href='http://www.stadtwerke-marburg.de/fileadmin/media/stadtverkehr/haltest/Erlenring.pdf'>Erlenring</a></b></li><li>Beim Klicken auf die Buslinie erscheint ein Link zu den Abfahrtszeiten: <b><a target='_blank' href='http://www.stadtwerke-marburg.de/fileadmin/media/stadtverkehr/Fahrplan_2016/ab_11.04.16/Linie_1.pdf'>Linie 1</a></b></li><li>Mit Hilfe der Auswahlboxen können spezielle Orte ausgewählt werden</li></ul>"),
                                     p("Um zum Beispiel das Restaurant für die Club Night zu finden, wähle 'Restaurant' und die Buslinie 10 aus. Suche die Haltestelle Ortenbergcenter und ein Klick auf das Bus-Icon zeigt dir das Restaurant."),
                                     p("Viel Spaß und eine gute Zeit in Marburg!")
                            )),
                            fluidRow(
                              column(5, offset = 1,
                                     checkboxGroupInput("stores_de", label = h3("Wähle eine oder mehrere Geschäfte:"), 
                                                        choices = list("Bar" = "bar_pub_bistro", "Restaurant" = "restaurant", "Bakerei" = "bakery","Hotel"="accomodation","Imbiss"="imbiss","Cafe"="cafe","Apotheke"="pharmacy","Supermarkt"="supermarket","Taxi"="taxi"),
                                                        selected = "bar_pub_bistro",inline=TRUE)
                              ),
                              column(5,
                                     radioButtons("lines_de",label=h3("Wähle eine oder mehrere Buslinien:"),choices=list("Linie 1"=1,"Linie 2"=2,"Linie 3"=3,"Linie 4"=4,"Linie 5"=5,"Linie 6"=6,"Linie 7"=7,"Linie 8"=8,"Linie 9"=9,"Linie 10"=10),selected=1,inline=TRUE)
                              ),
                            hr(),
                            column(8,offset=3,
                                   HTML("Diese App wurde von <b><a target='_blank' href=http://toek.wzw.tum.de/index.php?id=147>Lionel Hertzog</a></b> und <b><a target='_blank' href='http://toek.wzw.tum.de/index.php?id=106'>Nadja Simons</a></b> entwickelt")
                            )
                            ))
))