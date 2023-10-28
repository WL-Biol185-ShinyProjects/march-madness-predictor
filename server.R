library(shiny)
library(leaflet)
library(tidyverse)

#Define server logic for shiny app
server <- function(input, output) {
  
  #Read the data
  march_madness_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
  
  #Data manipulation
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
}

#Run the shiny app
#shinyApp(ui, server)






#server <- function(input, output) {
  
  
#}

#shinyApp(ui, server)



