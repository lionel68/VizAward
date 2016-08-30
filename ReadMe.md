# Visualization Award GfO 2016

This repository is for sharing the code for the contribution of Lionel Hertzog and Nadja Simons to the visualization award of the GfÖ meeting in Marburg 2016.

Below is a short description of the repository.

## Data

This folder contains all the data used to make the map. Two R-scripts are provided to import the transport data (Data_ import.R) and to format the data (Data_preparation.R).

## Static_map

This folder contains the R code to create the static map.

## VizAwars_shiny

This folder contains the code to run the ShinyApp, if you want to run the App locally download this folder then run shinyAppDir("path-to-folder/VizAward_shiny") from R.

## Other objects

The repository also contains a pdf of the bus network of Marburg and an Rproject file for the data preparation.

## System requirements

All code was developed and tested on both a Windows system and a Linux system. It was developed with R version 3.3.0 (2016-05-03) -- "Supposedly Educational". You might need to update your R version to run some of the functions.

The following R packages need to be installed:

library(plyr) --> data handling
library(dplyr) --> more data handling, piping (%>%)
library(tidyr) --> more data management

library(sp) --> handle spatial objects
library(maps) --> free maps of the world
library(mapdata) --> world maps
library(RgoogleMaps) --> get google maps
library(raster)  --> handle raster data
library(rgdal)  --> input/output, projections of spatial data
library(rgeos)  --> geometry operations on spatial data

library(shiny)  --> for the shiny application
library(leaflet) --> creating maps with for shiny. You need to download the github version (instruction in the code)
library(RCurl) --> to load data directly from github
library(viridis) --> colour palette


## A note on pipes (%>%)

Most code is writing with pipes, read the pipe symbol e.g. in "dataset %>% my_function() %>% plot()" as "apply the function on the dataset and provide the output of this function for the plot".

