#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)
library(lubridate)

#Read the Data
game_location_name <- read_csv("~/march-madness-predictor/data/game_location_data.csv")
team_location_data <- read_csv("~/march-madness-predictor/data/Team locations.csv")
distance_data <- read_csv("~/march-madness-predictor/data/total_distance_traveled.csv")
final_four_seeds <- read_csv("~/march-madness-predictor/data/seed_predictor.csv")
conference_data <- read_csv("~/march-madness-predictor/data/conference_predictor.csv")
historical_data <- read_csv("~/march-madness-predictor/data/historical_performance.csv")
win_percentage_by_round <- read_csv("~/march-madness-predictor/data/win_percentage_by_round.csv")

#Define server logic for shiny app
server <- function(input, output) {

  #Tab 1 - Game Locations & Team Locations 
  output$map <- renderLeaflet({
    if(input$location_type == "Game Locations") {

        leaflet(data = game_location_name) %>% 
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
        addTiles()%>%
        addAwesomeMarkers(
          popup = ~Team, 
          label = ~Team, 
          icon = icon.fa)
    }
  })
  
  #Tab 2 - Distances Traveled
  distance_data <- distance_data %>%
    select('team_name', 'Year', 'kilometers_traveled', 'miles_traveled')
    
  
  #display data table
  output$data_table_distances <- renderTable({
    team_name <- input$team_select
    filtered_data <- distance_data[distance_data$team_name == team_name, ]
    return(filtered_data)
  })
  
  #Display graph for distances traveled
  output$distance_plot <- renderPlot({
    team_name <- input$team_select
    team_data <- total_team_distance_traveled[distance_data$team_name == team_name, ]
    
    ggplot(data = total_team_distance_traveled, aes(x = miles_traveled)) +
      geom_density() +
      geom_vline(aes(xintercept = miles_traveled, color = factor(Year)), data = team_data) +
      labs(title = paste("Miles Traveled by", team_name, "for Each Year They Made the Final Four"),
           x = "Miles Traveled",
           color = "Year")
  })
  
  #Tab 3 - Final Four Predictor
  #Calculate and Display the probabilities
  conference_predict <- reactive({
    conference_data %>%
      filter(Conference == input$conference)
  })
  
  output$data_table <- renderTable({
    selected_data <- conference_predict() %>%
      select('Conference', 'Number of Teams Within Conference', 'Number of Times Occurred', 'prob_occurence') %>%
      rename(Probability = prob_occurence)
    return(selected_data)
    
  })
  
  seed_count <- reactive({
    final_four_seeds %>%
      filter(Seed == input$seed_select)
    
  })
  
  output$data_table_seed <- renderTable({
    data <- seed_count() %>%
      select(Seed, `Number of Teams Of Given Seed`, `Number of Times Occurred`, prob_occurence) %>%
      rename(Probability = prob_occurence)
    return(data)
    
  })
  
  #Tab 4 - Historical Performance
  output$historical_plot <- renderPlot({
    team_name <- input$team_round_select
    filtered_data <- historical_data[historical_data$Team == team_name, ]
    
    ggplot(filtered_data, aes(x = Year, y = Round_Reached)) +
      geom_point() +
      scale_x_continuous(breaks = seq(min(historical_data$Year), max(historical_data$Year), by = 1)) +
      labs(
        title = paste("Historical Performance by", team_name),
        x = "Year",
        y = "Round_Reached"
      )
  })
  
  #Tab 5 - Win Pecentage by Round
  output$round_plot <- renderPlot({
    round_selected <- input$round_slider
    
    win_percentage_by_round %>%
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