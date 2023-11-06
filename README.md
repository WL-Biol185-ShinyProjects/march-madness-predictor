# march-madness-predictor
This project uses historical data from March Madness tournaments for the last 10 years to predict future outcomes.

NOTES FROM 10/16 Class time on 10/16 was spent collecting data. We are building our entire data set from scratch using ESPN and fivethirtyeight. 


Notes from 10/18: Class time on 10/18 was spent on collecting as well as planning ideas for our visual output

Notes from 10/23 - made the server and the UI also obtained baseline data set to be used for data wrangling and manipulation titled "Bio 185 March Madness Data" in data folder... will make changes offline and upload a new data set next class period

Notes from 10/25: began data wrangling and visualization work on an rmarkdown to be applied to our server later. Completed our first visual interactive page using leaflet to display a map of the U.S. with markers for the lat and lng of each of the games played along with the total count of the games played within a given city

Notes from 10/28: Completed first page on UI and Server.R. Started Page 2 work on R markdown document (joined tables), just completing manipulation.

Notes from 10/30: Completed second page (Final Four conference predictor and # of teams from a given conference within final four predictor) R markdown document. Beginning to implement changes on UI and server now.

Completed implementing the page 2 into the server and UI



Notes from 11/1 Expanded data set to include distances... figured out haversine function to incorporate distances for page 3

Notes from 11/5 Added extra data to lattitude longitude data table to find distances traveled for underdog teams

Notes from 11/6 Finished up code for page to find the total distances traveled by each of the teams for every team in every year of the data set (regardless if a team was a favorite or underdog)

Note: we are planning to join our finished table to the final four data set to filter out the distances traveled among final four teams then we will implement a slider bar to find the distances traveled among final four teams (teams on the west coast probably travel more)
        
#conditionalPanel - to make an optional pane on the sam page as something else in the UI