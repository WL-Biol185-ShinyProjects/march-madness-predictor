library(shiny)

ui <- fluidPage(
  titlePanel("NYC Flights")

)
  
  
server <- function(input, output) {
  
  
}

shinyApp(ui, server)


march_madness <- read_csv("marchmadness.csv")
