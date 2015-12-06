require(leaflet)

locations <- fast_food %>% subset(RESTAURANT %in% c("Burger King", "McDonalds"))
content <- paste(sep = "<br/>",
                 locations$RESTAURANT,
                 locations$ADDRESS,
                 paste(sep = " ", locations$CITY, locations$STATE, locations$ZIP
))
leaflet(data = locations) %>% addTiles() %>% 
  addMarkers( ~LONGI, ~LAT, popup = ~content ,
  clusterOptions = markerClusterOptions()
)
