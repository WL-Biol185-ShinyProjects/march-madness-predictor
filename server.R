#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)

#Define server logic for shiny app
server <- function(input, output) {
  
  #Read the data
  march_madness_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
  
#Code for Tab 1
  march_madness_data <- march_madness_data %>%
    rename(lat = `Lat for City Where Game was played`,
           lng = `Lon for City Where Game was Played`,
           distance_favorite = `Distance to Favorite`,
           game_city = `City Where Game Was Played`,
           game_state = `State Where Game was Played`)
  
  game_total <- march_madness_data %>%
    count(lat, lng, game_city)
  
  game_total$popup_text <- paste0(game_total$game_city, ": ", game_total$n, " games")
  
  output$map <- renderLeaflet({
    leaflet(data = game_total) %>%
      setView(lng = -96.25, lat = 39.5, zoom = 4) %>%
      addTiles()%>%
      addMarkers(popup = ~game_city, label = ~popup_text)
})

#Code for Tab 2

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
}