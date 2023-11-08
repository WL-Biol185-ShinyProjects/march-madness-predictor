library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)

#Define UI for the shiny app
ui <- fluidPage(
    titlePanel("March Madness Predictor"),
    navbarPage("Tabs",
       tabPanel("Game Locations",
        leafletOutput("map"),
          textOutput("text1")
               ),
#UI for Tab 2       
    tabPanel("Final Four Probability by Conference",
    sidebarLayout(
      sidebarPanel(
        selectInput("conference", "Select Conference", choices = unique(new_data$Conference)),
      ),
      mainPanel(
        tableOutput("data_table")
      )
    )
)))       
        

