#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)
library(lubridate)

#Define server logic for shiny app
server <- function(input, output) {
  
  #Read the data
  march_madness_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
  team_location_data <- read_csv("~/march-madness-predictor/data/Team locations.csv")
  
  #Code for Tab 1
  output$map <- renderLeaflet({
    if(input$location_type =="Game Locations") {
      march_madness_data <- march_madness_data %>%
        rename(lat = `Lat for City Where Game was played`,
               lng = `Lon for City Where Game was Played`,
               distance_favorite = `Distance to Favorite`,
               game_city = `City Where Game Was Played`,
               game_state = `State Where Game was Played`)
      
      game_total <- march_madness_data %>%
        count(lat, lng, game_city)
      
      game_total$popup_text <- paste0(game_total$game_city, ": ", game_total$n, " games")
      
      leaflet(data = game_total) %>%
        setView(lng = -96.25, lat = 39.5, zoom = 4) %>%
        addTiles()%>%
        addMarkers(popup = ~game_city, label = ~popup_text)
      
    } else {
      team_location_data <- team_location_data %>%
        unique() %>%
        filter(Lat > 0) %>%
        rename(lat = Lat,
               lng = Lon)
      icon.fa <- makeAwesomeIcon(
        icon = 'flag', 
        markerColor = 'orange', 
        library='fa', 
        iconColor = 'gray')
      
      leaflet(data = team_location_data) %>%
        setView(lng = -96.25, lat = 39.5, zoom = 4) %>%
        addTiles() %>%
        addAwesomeMarkers(
          popup = ~Team, 
          label = ~Team, 
          icon = icon.fa)
    }
  })

#Code for Tab 2 Part 1

#read the data
final_four_teams <- read_csv("~/march-madness-predictor/data/Final Four Teams.csv")
conference_data <- read_csv("~/march-madness-predictor/data/mach_madness_conference_list.csv")

new_data <- final_four_teams %>%
  left_join(conference_data, by = c("Team" = "Team"))

new_data[is.na(new_data)] <- "Non Power 6"

#Calculate and Display the probabilities
filtered_data <- reactive({
  new_data %>%
    filter(Conference == input$conference)
})

output$data_table <- renderTable({
  data_count <- filtered_data() %>%
    select(Year, Conference) %>%
    count(Conference, Year) %>%
    group_by(Conference, n) %>%
    count() %>%
    mutate(Probability = nn *100 / 83) %>%
    rename("Number of Teams Within Conference" = "n", 
           "Number of Times Occurred" = "nn") %>%
    mutate(Probability = round(Probability, digits = 2)) %>%
    mutate(Probability = paste0(Probability, "%"))
  return(data_count)
  
})

#Code for Tab 2 Part 2
  final_four_seeds <- read_csv("~/march-madness-predictor/data/Seed Data.csv")

  seed_count <- reactive({
    final_four_seeds %>%
      filter(Seed == input$seed_select)
  
})

output$data_table_seed <- renderTable({
  data <- seed_count() %>%
    select(Year, Seed) %>%
    count(Seed, Year) %>%
    group_by(Seed, n) %>%
    count() %>%
    mutate(prob_occurrence = (nn * 100) / 44) %>%
    rename("Number of Teams Of Given Seed" = "n",
           "Number of Times Occurred" = "nn") %>%
    mutate(prob_occurrence = round(prob_occurrence, digits = 0))
  return(data)
    
  })

#Code for Tab 3
#Load Data
distance_data <- read_csv("~/march-madness-predictor/data/Bio 185 March Madness Data Lats.csv")

#Calculate distances using haversine
haversine <- function(long1, lat1, long2, lat2, round = 3) {
  # convert to radians
  long1 = long1 * pi / 180
  lat1  = lat1  * pi / 180
  long2 = long2 * pi / 180
  lat2  = lat2  * pi / 180

  R = 6371 # Earth mean radius in km

  a = sin((lat2 - lat1)/2)^2 + cos(lat1) * cos(lat2) * sin((long2 - long1)/2)^2
  d = R * 2 * asin(sqrt(a))

  return( round(d,round) ) # distance in km
}

distance_data <- distance_data %>%
  mutate(distance_favorite = haversine(College_lon, College_lat, `Lon for City Where Game was Played`, `Lat for City Where Game was played`, round = 0))

distance_data <- distance_data %>%
  mutate(distance_underdog = haversine(Underdog_lon, Underdog_lat, `Lon for City Where Game was Played`, `Lat for City Where Game was played`, round = 0))

distance_data <- distance_data %>%
  select(Year, Favorite, Underdog, distance_favorite, distance_underdog, Round)

favorite_data_table <- distance_data %>%
  select(Year, Favorite, distance_favorite, Round) %>%
  group_by(Favorite, Year) %>%
  mutate(total_distance_favorite = sum(distance_favorite))

underdog_data_table <- distance_data %>%
  select(Year, Underdog, distance_underdog, Round) %>%
  group_by(Underdog, Year) %>%
  mutate(total_underdog_distance = sum(distance_underdog))

favorite_data_table <- favorite_data_table %>%
  mutate(team_name = Favorite)

underdog_data_table <- underdog_data_table %>%
  mutate(team_name = Underdog)

total_team_distance_traveled <- full_join(favorite_data_table, underdog_data_table, by = c("Year" = "Year", "team_name" = "team_name"))

total_team_distance_traveled <- total_team_distance_traveled %>%
  mutate(total_team_travel = (total_distance_favorite + total_underdog_distance))

total_team_distance_traveled$total_underdog_distance[is.na(total_team_distance_traveled$total_underdog_distance)] <- 0
total_team_distance_traveled$total_distance_favorite[is.na(total_team_distance_traveled$total_distance_favorite)] <- 0
total_team_distance_traveled$total_team_travel[is.na(total_team_distance_traveled$total_team_travel)] <- 0

#Filter out duplicate rows
total_team_distance_traveled <- total_team_distance_traveled %>%
  group_by(team_name, Year) %>%
  mutate(kilometers_traveled = pmax(total_distance_favorite, total_underdog_distance, total_team_travel))

total_team_distance_traveled %>%
  select(Year, team_name, kilometers_traveled,)

total_team_distance_traveled <- unique(total_team_distance_traveled[, c("team_name", "Year", "kilometers_traveled")])

total_team_distance_traveled <- total_team_distance_traveled %>%
  inner_join(final_four_teams, by = c("Year" = "Year", "team_name" = "Team"))

#Convert kilometers to miles
total_team_distance_traveled <- total_team_distance_traveled %>%
  mutate(miles_traveled = kilometers_traveled * .621371) %>%
  mutate(miles_traveled = as.integer(miles_traveled)) %>%
  mutate(Year = as.integer(Year)) %>%
  mutate(kilometers_traveled = as.integer(kilometers_traveled))

#display data table
  output$data_table_distances <- renderTable({
    team_name <- input$team_select
    filtered_data <- total_team_distance_traveled[total_team_distance_traveled$team_name == team_name, ]
    return(filtered_data)
  })

#Display a box chart for the total distance traveled
  output$box_chart <- renderPlot({
    team_name <- input$team_select
    filtered_data <- total_team_distance_traveled[total_team_distance_traveled$team_name == team_name, ]
    
    ggplot(filtered_data, aes(x = Year, y = miles_traveled)) +
      geom_boxplot(fill = "lightblue", color = "blue") +
      labs(
        title = paste("Total Distance Traveled by", team_name),
        x = "Year",
        y = "Miles Traveled"
      )
  })
  
#Code for Tab 4
  historical_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
  
  favorite_maximum_round <- historical_data %>%
    group_by(Favorite, Year) %>%
    mutate(maximum_round_favorite = max(Round)) %>%
    select(Year, Favorite, maximum_round_favorite)
  
  underdog_maximum_round <- historical_data %>%
    group_by(Underdog, Year) %>%
    mutate(maximum_round_underdog = max(Round)) %>%
    select(Year, Underdog, maximum_round_underdog)
  
  aggregate_maximum_round <- full_join(favorite_maximum_round, underdog_maximum_round, by = c("Year" = "Year", "Favorite" = "Underdog"))
  
  aggregate_maximum_round$maximum_round_favorite[is.na(aggregate_maximum_round$maximum_round_favorite)] <- 0
  aggregate_maximum_round$maximum_round_underdog[is.na(aggregate_maximum_round$maximum_round_underdog)] <- 0
  
  aggregate_maximum_round <- aggregate_maximum_round %>%
    group_by(Year, Favorite) %>%
    mutate(final_round = pmax(maximum_round_favorite, maximum_round_underdog)) %>%
    rename("Team" = "Favorite") %>%
    select(Year, Team, final_round) %>%
    distinct() %>%
    arrange(desc(Team)) %>%
    mutate(Round_Reached = factor(final_round,
                                levels = c(1, 2, 3, 4, 5, 6),
                                labels = c("First Round", "Second Round", "Sweet Sixteen", "Elite Eight", "Final Four", "Championship Game")))
  
  aggregate_maximum_round$Year <- round(aggregate_maximum_round$Year, digits = 0)
  
  output$historical_plot <- renderPlot({
    team_name <- input$team_round_select
    filtered_data <- aggregate_maximum_round[aggregate_maximum_round$Team == team_name, ]
    
    ggplot(filtered_data, aes(x = Year, y = Round_Reached)) +
      geom_point() +
      scale_x_continuous(breaks = seq(min(aggregate_maximum_round$Year), max(aggregate_maximum_round$Year), by = 1)) +
      labs(
        title = paste("Historical Performance by", team_name),
        x = "Year",
        y = "Round_Reached"
      )
  })
  
#Code for Tab 5
  #Read the Data 
  march_madness_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
  
  march_madness_data <- march_madness_data %>%
    group_by(Winner, Round) %>%
    count(Winner)
  
  win_pct_data <- march_madness_data %>%
    rename(number_of_wins = n) %>%
    ungroup(Winner) %>%
    mutate(total_games = sum(number_of_wins)) %>%
    group_by(Winner) %>%
    mutate(win_pct = number_of_wins / total_games) %>%
    select(Winner, number_of_wins, win_pct, Round)
  
  win_pct_data <- win_pct_data %>%
    mutate(Winner = as.character(Winner))
  
  win_pct_data <- win_pct_data %>%
    mutate(Winner = ifelse(Winner == "0","Underdog Won","Favorite Won"))
  
  output$round_plot <- renderPlot({
    round_selected <- input$round_slider
    
    win_pct_data %>%
      filter(Round == round_selected) %>%
      ggplot(mapping = aes(x = Winner, y = win_pct)) +
      geom_bar(stat="identity") +
      labs(
        title = paste("Win Percentage in Round", round_selected),
        x = "Winner",
        y = "Win Percentage"
      )
  })
}
#server should end on line 289
  