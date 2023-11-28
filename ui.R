#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)
library(shinythemes)
library(lubridate)

#Read the Data
conference_data <- read_csv("~/march-madness-predictor/data/conference_predictor.csv")
final_four_seeds <- read_csv("~/march-madness-predictor/data/seed_predictor.csv")
historical_data <- read_csv("~/march-madness-predictor/data/historical_performance.csv")
win_percentage_by_round <- read_csv("~/march-madness-predictor/data/win_percentage_by_round.csv")
distance_data <- read_csv("~/march-madness-predictor/data/total_distance_traveled.csv")

#Define UI for the shiny app
ui <- fluidPage(
    theme = shinytheme("cerulean"),
    titlePanel("March Madness Predictor"),
    
#Tab 0 - About    
    navbarPage(
      "Tabs",
      tabPanel("About",
               fluidPage(
                 tags$h3("About Our App!"),
                 tags$p("Welcome to our app. As two March Madness fans we are really excited about this project"),
                 tags$h3("Data Collection"),
                 tags$p("We realized that March Madness Data is not available on the web. So we created our own dataset for this project using data directly from ESPN's website. The first dataset includes the last ten years of data for every game played in the tournament. It includes which team was considred the Favorite or Underdog, who the winner of each game was, what the seed was for the favorite team and for the underdog team, the city and state where the game was played, the round of each game, and the latitude and longitude data for the cities (using data from US Postal Offices)"),
                 
               )),
       
#Tab 1 - Game Locations & Team Locations    
      tabPanel("Game Locations & Team Locations",
        fluidPage(
          tags$h3("Where are Games Being Played & Where are Teams Located?"),
          tags$p("This tab allows you to do some cool things!")
        ),
          selectInput("location_type", "Select to See Either Game or Team Locations",
                      choices = c("Game Locations","Team Locations")),
        leafletOutput("map"),
          textOutput("text1")
               ),
      
#Tab 2 - Distances Traveled
tabPanel("Distances Traveled",
               selectInput("team_select", "Select a Team That Has Made It To The Final Four In The Last 10 Years", 
                           choices = unique(distance_data$team_name)
               ),
               plotOutput("distance_plot"),
               tableOutput("data_table_distances")
      ),

#Tab 3 - Final Four Predictor
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
           
#Tab 4 - Historical Performance
tabPanel("Historical Performance",
             selectInput("team_round_select", "Select a Team",
                         choices = unique(historical_data$Team)
             ),
             plotOutput("historical_plot")
    ),

#Tab 5 - Win Pecentage by Round
tabPanel("Win Percentage by Round",
         sliderInput("round_slider", "Select Round", min = 1, max = 6, value = 1),
         plotOutput("round_plot")
    )
  )
)
 