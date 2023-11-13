#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)

#Define UI for the shiny app
ui <- fluidPage(
    titlePanel("March Madness Predictor"),
    
#set up tabs    
    navbarPage(
      "Tabs",
       tabPanel("Game Locations",
        leafletOutput("map"),
          textOutput("text1")
               ),
#UI for Tab 2
      tabPanel("Final Four Probability by Conference",
          selectInput("conference", "Select Conference", 
              choices = unique(new_data$Conference)
          ),
         fluidRow(
           column(6,
              selectInput("seed_select", "Select a Seed",
                  choices = unique(final_four_seeds$Seed),
                  )
              ),
         column(6,
              tableOutput("data_table_seed")
         )
      ),
          tableOutput("data_table"),
          textOutput("text2"),
     ),

#UI for Tab 3
    tabPanel("Distances",
      selectInput("team_select", "Select a Team That Has Made It To The Final Four In The Last 10 Years", 
          choices = unique(total_team_distance_traveled$team_name)
        ),
      plotOutput("box_chart"),
      tableOutput("data_table_distances")
    )
  ) 
)
