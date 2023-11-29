#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)
library(shinythemes)
library(lubridate)
options(scipen = 999)

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
                 tags$p("Welcome to our app. As two March Madness fans we are really excited about this project. Given our historically poor performance making March Madness Brackets in the past, we wanted to create something that analyzes variables to see if they can predict different outcomes that should be considered when making brackets. We considered variables such as Location, Distances Traveled by a Team, Seeds, Conferences, And Favorite vs. Underdog designations. From our work, we believe we can now help basketball dummies make quality predictions."),
                 tags$h3("Data Collection"),
                 tags$p("We realized that March Madness Data is not easily attainable or standardized under one single free data table on the web. So, we created our own dataset for this project using data directly from ESPN and fivethirtyeight’s websites. We have two primary datasets that we created for our app. The first dataset includes the last ten years of data for every game played in the March Madness tournament. It includes which team was considered the Favorite or Underdog, who the winner of each game was, what the seed was for the favorite team and for the underdog team, the city and state where the game was played, the round of each game, the latitude and longitude data for the cities (using data from US Postal Offices), and the latitude and longitude data for each team who competed within the tournament. The second dataset that we created includes all teams that have made the Final Four since the tournament’s inception, highlighting each team’s seed and conference. Being able to aggregate all this data into two common sources was a taxing and time-consuming process. We believe that our data collection process targeted towards standardization helps achieve easy accessibility that has not always been seen in the past. Now you can have access to this data too by pressing the download button!"),
               ),
      downloadButton("download_about_data", "Download the Dataset", href = "~/march-madness-predictor/data/march_madness_data_2013-2023.xlsx", class = "btn-success"),
                tags$br(),
                tags$p("One important thing to note is that 2020 data for the March Madness Tournament does not exist because the tournament was not played that year due to COVID-19.")
    ),
       
#Tab 1 - Game Locations & Team Locations    
      tabPanel("Game Locations & Team Locations",
        fluidPage(
          tags$h3("Where are Games Played & Where are Teams Located?"),
          tags$p("Use the drop-down box to select either Game Locations or Team Locations. Game Locations will show you where all the games in the March Madness tournament in the last ten years were played. Team Locations will show you where all the teams that have played in the tournament are located.")
        ),
          selectInput("location_type", "Select Either Game or Team Locations",
                      choices = c("Game Locations","Team Locations")),
        leafletOutput("map"),
          tags$h3("Our Takeaways"),
          tags$p("The main takeaway on this map is that most teams that have made the tournament are located on the eastern half of the U.S., predominantly the southeast, east coast, and Midwest. Similarly, most games that are being played also are primarily on the eastern half of the U.S. While these maps only give viewers an understanding on where teams and games are located, we will later explore how location matters for these teams and whether traveling a long distance has an impact on winning a game.")
               ),
      
#Tab 2 - Distances Traveled
tabPanel("Distances Traveled",
         fluidPage(
           tags$h3("Does Distance Traveled by a Team Affect Who Wins?"),
           tags$p("Use the drop-down box to select a team that has made it to the final four in the last ten years. The graph shows the aggregate minimum, average, and maximum distance traveled by teams who have made the final four. The average distance traveled is about 4,300 miles. The table will show you each year the team has made the final four and what the total distance traveled was in miles and kilometers.")
         ),
               selectInput("team_select", "Select a Team That Has Made It To The Final Four In The Last 10 Years", 
                           choices = unique(distance_data$team_name)
               ),
               plotOutput("distance_plot"),
               tableOutput("data_table_distances")
      ),

#Tab 3 - Final Four Predictor
tabPanel("Final Four Predictor",
         fluidPage(
           tags$h3("Does a Team’s Conference or Seed Impact the Probability of Reaching the Final Four?"),
           tags$p("This tab uses historical data of all teams that have made the Final Four since the tournament’s inception. Select a Conference to view the number of teams within that conference that have made the final four in any given year. You can also view the probability of each of these occurrences.")
         ),
         
         fluidRow(
           column(10,
                  selectInput("conference", "Select Conference", 
                              choices = unique(conference_data$Conference)
                  ),
                  tableOutput("data_table"),
                  tags$h3("Our Takeaways"),
                  tags$p("For instance, the ACC has been one of the most consistent conferences when it comes to getting a team into the final four. You can see that the probability that there will be at least one team from the ACC that makes it into the final four is 46%. The probability that two teams from the ACC make it to the final four is 16%. And once since the tournament’s inception, three teams from the ACC have made it to the final four."),
                  tags$br(),
                  tags$p("Like the conference analysis, in the second table you can select a seed and view the probability of that seed making it to the final four in any given year.")
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
 