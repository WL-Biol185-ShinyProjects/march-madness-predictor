library(shiny)
library(leaflet)
library(tidyverse)

#Define server logic for shiny app
server <- function(input, output) {
  
  #Read the data
  march_madness_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
  
#Data manipulation for page 1 of app
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

#Data manipulation for page 2 of app
  
final_four_teams <- read_csv("~/march-madness-predictor/data/Final Four Teams.csv")
conference_data <- read_csv("~/march-madness-predictor/data/mach_madness_conference_list.csv")

new_data <- final_four_teams %>%
  left_join(conference_data, by = c("Team" = "Team"))

new_data[is.na(new_data)] <- "Non Power 6"

data_count <- new_data %>%
  select(Year, Conference) %>%
  count(Conference, Year)

data_count <- data_count %>%
  group_by(Conference, n) %>%
  count()

#Calculate and display probabilities
prob_occurrence <- data_count %>%
  mutate(prob_occurence = nn / 83)

output$prob_occurrence_table <- renderTable({
  prob_occurrence
})

output$team_data_table <- renderDataTable({
  new_data
})

output$prob_text <- renderText({
  paste("Probability of Occurrence: ", prob_occurrence$prob_occurrence)
  })
}



