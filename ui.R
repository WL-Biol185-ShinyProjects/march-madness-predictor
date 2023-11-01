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
    tabPanel("Probability Predictor",
      sidebarLayout(
        sidebarPanel(
          h4("Data Count"),
          dataTableOutput("data_count_table")
        ),
        mainPanel(
          h4("Team Data"),
          dataTableOutput("team_data_table")
        )
      )
    )
)
)
             
        

