#load packages
library(shiny)
library(tidyverse)
library(ggplot2)
library(leaflet)
library(lubridate)
options(scipen = 999)

#Read the Data
game_location_name <- read_csv("data/game_location_data.csv")
team_location_data <- read_csv("data/Team locations.csv")
distance_data <- read_csv("data/total_distance_traveled.csv")
final_four_seeds <- read_csv("data/seed_predictor.csv")
conference_data <- read_csv("data/conference_predictor.csv")
historical_data <- read_csv("data/historical_performance.csv")
win_percentage_by_round <- read_csv("data/win_percentage_by_round.csv")
aggregate_distance_data <- read_csv("data/distance_traveled_v_winning.csv")

#Define server logic for shiny app
server <- function(input, output) {
  
  #Tab 0 - Download Dataset
  march_madness_data <- read_csv("data/march_madness_data_ten_years.csv")
  
  output$download_about_data <- downloadHandler(
    filename = function() {
      paste("march_madness_data", ".csv")
    },
    content = function(file) {
      write.csv(march_madness_data, file)
    }
  ) 
  
  #Tab 1 - Game Locations & Team Locations 
  output$map <- renderLeaflet({
    if(input$location_type == "Game Locations") {

        leaflet(data = game_location_name) %>% 
          setView(lng = -96.25, lat = 39.5, zoom = 4) %>%
          addTiles()%>%
        addCircleMarkers(radius = ~n, label = ~popup_text)
      
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
    select('team_name', 'Year', 'miles_traveled')
    
  
  #display data table
  output$data_table_distances <- renderTable({
    team_name <- input$team_select
    filtered_data <- distance_data[distance_data$team_name == team_name, ]
    return(filtered_data)
  }, digits = 0)
  
  #Display graph for distances traveled
  output$distance_plot <- renderPlot({
    team_name <- input$team_select
    team_data <- distance_data[distance_data$team_name == team_name, ]
    
    ggplot(data = distance_data, aes(x = miles_traveled)) +
      geom_density() +
      geom_vline(aes(xintercept = miles_traveled, color = factor(Year)), data = team_data) +
      labs(title = paste("Miles Traveled by", team_name, "for Each Year They Made the Final Four"),
           x = "Miles Traveled",
           color = "Year")
  })
    #Display graph for all distances
    output$aggregate_distance_plot <- renderPlot({
      
      ggplot(data = aggregate_distance_data, mapping = aes(x = Winner, y = distance_favorite)) +
        geom_boxplot() +
        labs(title = "Relationship Between Distance Traveled and Winning", x = "Winner", y = "Miles Traveled")
  })
  
  #Tab 3 - Final Four Predictor
  #Calculate and Display the probabilities
  conference_predict <- reactive({
    conference_data %>%
      filter(Conference == input$conference)
  })
  
  output$data_table <- renderTable({
    selected_data <- conference_predict() %>%
      select('Conference', 'Number of Teams from the Conference in the Final Four', 'Number of Times Occurred', 'prob_occurence') %>%
      rename(Probability = prob_occurence)
    return(selected_data)
    
  }, digits = 0)
  
  seed_count <- reactive({
    final_four_seeds %>%
      filter(Seed == input$seed_select)
    
  })
  
  output$data_table_seed <- renderTable({
    data <- seed_count() %>%
      select(Seed, `Number of Teams Of Given Seed in the Final Four`, `Number of Times Occurred`, prob_occurence) %>%
      rename(Probability = prob_occurence)
    return(data)
    
  }, digits = 0)
  
  #Tab 4 - Historical Performance
  
  historical_data <- historical_data %>%
    mutate(Round_Reached = factor(final_round,
                                  levels = c(1, 2, 3, 4, 5, 6),
                                  labels = c("First Round", "Second Round", "Sweet Sixteen", "Elite Eight", "Final Four", "Championship Game")))
  
  output$historical_plot <- renderPlot({
    team_name <- input$team_round_select
    filtered_data <- historical_data[historical_data$Team == team_name, ]
    
    ggplot(filtered_data, aes(x = Year, y = Round_Reached)) +
      geom_tile(color = "skyblue") +
      scale_x_continuous(breaks = seq(min(historical_data$Year), max(historical_data$Year), by = 1)) +
      labs(
        title = paste("Historical Performance by", team_name),
        x = "Year",
        y = "Round Reached"
      )
  })
  
  #Tab 5 - Win Percentage by Round
  output$round_plot <- renderPlot({
    round_selected <- input$round_slider
    
    win_percentage_by_round %>%
      filter(Round == round_selected) %>%
      ggplot(mapping = aes(x = Winner, y = win_pct)) +
      geom_bar(stat="identity", fill = "skyblue") +
      geom_text(aes(label = win_pct), vjust = 1.6, color = "black", size = 7) +
      labs(
        title = paste("Win Percentage in Round", round_selected),
        x = "Winner",
        y = "Win Percentage"
      )
  })
}