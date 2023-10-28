library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)

#Define UI for the shiny app
ui <- fluidPage(
    titlePanel("March Madness Game Locations"),
    leafletOutput("map")
  )






#ui <- fluidPage(
  #titlePanel("title panel"),
  
  #sidebarLayout(
   # sidebarPanel("sidebar panel"),
   # mainPanel("main panel")
 # )
#)