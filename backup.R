#Read the data
march_madness_data <- read_csv("~/march-madness-predictor/data/Bio_185_March_Madness_Data.csv")
print(colnames(march_madness_data))
team_location_data <- read_csv("~/march-madness-predictor/data/Team locations.csv")

#Code for Tab 1
output$map <- renderLeaflet({
  if(input$location_type == "Game Locations") {
    march_madness_data <- march_madness_data %>%
      rename(lat = `Lat for City Where Game was played`,
             lng = `Lon for City Where Game was Played`,
             distance_favorite = `Distance to Favorite`,
             game_city = `City Where Game Was Played`,
             game_state = `State Where Game was Played`)
    print(colnames(march_madness_data))
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