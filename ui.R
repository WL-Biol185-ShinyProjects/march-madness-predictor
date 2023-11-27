#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)
library(shinythemes)
library(lubridate)

conference_data <- read_csv("~/march-madness-predictor/data/conference_predictor.csv")
final_four_seeds <- read_csv("~/march-madness-predictor/data/seed_predictor.csv")
historical_data <- read_csv("~/march-madness-predictor/data/historical_performance.csv")
win_percentage_by_round <- read_csv("~/march-madness-predictor/data/win_percentage_by_round.csv")
distance_data <- read_csv("~/march-madness-predictor/data/total_distance_traveled.csv")

#Define UI for the shiny app
ui <- fluidPage(
    theme = shinytheme("cerulean"),
    titlePanel("March Madness Predictor"),
    
#set up tabs    
    navbarPage(
      "Tabs",
       tabPanel("Leaflet Maps",
          selectInput("location_type", "Select to See Either Game or Team Locations",
                      choices = c("Game Locations","Team Locations")),
        leafletOutput("map"),
          textOutput("text1")
               ),
      
#UI for Tab 2
tabPanel("Distances",
               selectInput("team_select", "Select a Team That Has Made It To The Final Four In The Last 10 Years", 
                           choices = unique(distance_data$team_name)
               ),
               plotOutput("box_chart"),
               tableOutput("data_table_distances")
      ),

#UI for Tab 3
tabPanel("Final Four Predictor",
         fluidRow(
           column(10,
                  selectInput("conference", "Select Conference", 
                              choices = unique(conference_data$Conference)
                  ),
                  tableOutput("data_table")
           ),
           column(10,
                  selectInput("seed_select", "Select a Seed",
                              choices = unique(final_four_seeds$Seed)
                  ),
                  tableOutput("data_table_seed")
           )
          )
        ),
           
#UI for Tab 4
tabPanel("Historical Performance",
             selectInput("team_round_select", "Select a Team",
                         choices = unique(historical_data$Team)
             ),
             plotOutput("historical_plot")
    ),

#UI for Tab 5
tabPanel("Win Percentage by Round",
         sliderInput("round_slider", "Select Round", min = 1, max = 6, value = 1),
         plotOutput("round_plot")
    )
  )
)
 