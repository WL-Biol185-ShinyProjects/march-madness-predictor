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
                 tags$br(),
                 tags$p("One important thing to note is that 2020 data for the March Madness Tournament does not exist because the tournament was not played that year due to COVID-19."),
               ),
      downloadButton("download_about_data", "Download the Dataset", href = "~/march-madness-predictor/data/march_madness_data_2013-2023.xlsx", class = "btn-success"),
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
               selectInput("team_select", "Select a Team", 
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
                  selectInput("seed_select", "Select Seed",
                              choices = unique(final_four_seeds$Seed)
                  ),
                  tableOutput("data_table_seed"),
                  tags$h3("Our Takeaways"),
                  tags$p("An interesting point to note is that in all of March Madness History no seed beyond 11 (12-16) has ever made the final four. If you click on a 1 seed, you can see different occurrences such as the probability of one team that is given a “1 seed” designation making it to the final four is quite high at 41%. It is also interesting to note that the probability of two teams with a “1 seed” designation making the final four is the same probability at 41%. Three teams with a “1 seed” designation making the final four has a probability around 9%. One time in March Madness History, all the final four teams were the “1 seed.”")
           )
          )
        ),
           
#Tab 4 - Historical Performance
tabPanel("Historical Performance",
         fluidPage(
           tags$h3("Could Past Performance be Indicative of the Future?"),
           tags$p("This tab allows you to view how each team over the past ten years has performed in the March Madness Tournament for every year they made it. Select different teams and compare their historical performance over the ten years.")
         ),
             selectInput("team_round_select", "Select a Team",
                         choices = unique(historical_data$Team)
             ),
             plotOutput("historical_plot"),
              tags$h3("Our Takeaways"),
              tags$p("We believe that past performance might be indicative of future play for two reasons: consistency and potential. Usually, some teams will not only make the March Madness Tournament every year, but they will also achieve a given threshold every year on a consistent basis. If a given team makes the Sweet Sixteen every year for the past three years, they will probably make that round again one year later. One example we recommend viewing is Gonzaga. Gonzaga has made it to at least the Sweet Sixteen every year since 2016. Given their consistence, we think they will make at least the Sweet Sixteen in 2024. Another way to help predict how far a given team will make the March Madness tournament could be based on potential. This idea revolves around a team improving or matching the round they reached the prior year and making a later round a subsequent year. To visualize this, we recommend viewing teams such as UNC or Tennessee. From 2013-2017 UNC improved on the round that they reached, making it to the second round twice, then the Sweet Sixteen, then the Championship Game twice. Similarly for Tennessee from 2021 to 2023 Tennessee reached a later round from year to year making it to the first round in 2021, second round in 2022, and Sweet Sixteen in 2023.")
    ),

#Tab 5 - Win Pecentage by Round
tabPanel("Win Percentage by Round",
         fluidPage(
           tags$h3("How Often Does the “Favorite” Actually Win?"),
           tags$p("Use the slider to pick a different round of the March Madness Tournament and watch how the Favorite Won percentage and Underdog Won percentage change on each round.")
         ),
         sliderInput("round_slider", "Select Round", min = 1, max = 6, value = 1),
         plotOutput("round_plot"),
         tags$h3("Our Takeaways"),
         tags$p("Typically, March Madness pickers will choose the favorites to win on a given round, but is this always the best choice? As we can see in round 1, the favorite wins roughly 75% of the time, and as we progress all the way to round 4 (the Elite Eight), the odds of the favorite winning a game dwindles to a 50-50 split. This dramatic change in the probability of the favorite winning is primarily due to the level of play shifting as the tournament progresses. As we saw earlier most teams that have made the Final Four (round 5) in the past are high seeds (seeds 1-4). From round to round each of these teams typically must play a better seed as the tournament progresses. Therefore, as the Elite Eight is reached, the difference and level of play between two teams is small as compared to rounds 1, 2 and 3. "),
         tags$br(),
         tags$p("It is also interesting to see that in the Final Four and Championship Game, the favorite wins on average over 60% of the time. This may be due to the quality of competition worsening at the Final Four stage. By the time the Final Four is reached, any team of a given seed from 1-16 can reach the Final Four. While on average, higher seeds (specifically 1 and 2 seeds) make the Final Four, teams can sometimes have “Cinderella stories” or dream runs in which lower rated seeds make the Final Four. Let’s say for the sake of simplicity a 1 seed (the favorite) matches up with a 5 seed in the Final Four. This type of matchup would be the equivalent of a potential matchup a 1 seed would face in the Sweet Sixteen (round 3). Therefore, it is not surprising that the win percentage reverts to the ratio we see in rounds 1-3. ")
    )
  )
)
 