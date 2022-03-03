library(leaflet)
library(tidyverse)

dados <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vSR47dYcCeZtxIl14urVO7c9dafYWwZUTJ7kxay4ay2lqu92heURX1yxaYHFEgYEqp3kGBxFN4BkNz8/pub?gid=0&single=true&output=csv", header = T)

content <- paste(sep = "<br/>",
                 "<b><a href='http://www.samurainoodle.com'>", dados$nome_veiculo, "</a></b>",
                 dados$formato,
                 dados$localizacao
)

saveas <- function(map, file){
  class(map) <- c("saveas",class(map))
  attr(map,"filesave")=file
  map
}

print.saveas <- function(x, ...){
  class(x) = class(x)[class(x)!="saveas"]
  htmltools::save_html(x, file=attr(x,"filesave"))
}

initial_lat = -23.55577
initial_lng = -46.63956
initial_zoom = 9

lsl <- unique(dados$formato)
#lsl_genero <- unique(dados$genero)

# elementos do mapa
mt <- leaflet() %>%
  setView(lat = initial_lat, lng = initial_lng, zoom = initial_zoom) %>%
  addProviderTiles(providers$CartoDB.Positron)

for(i in 1:length(lsl)){
  l <- lsl[i]
  mt <- mt %>%
    addCircleMarkers(
      data = subset(dados, dados$formato == lsl[i])
      #data = origAddress
      , group = lsl[i],
      clusterOptions = markerClusterOptions(), label = dados$nome_veiculo, popup = content
    )
}

mt %>%   
  addLayersControl(
  overlayGroups = c(lsl),
  position = c("bottomleft"),
  options = layersControlOptions(collapsed = FALSE)
) 

saveWidget(mt, file="map1.html", selfcontained=FALSE)

# %>% saveas("mapedit.html")
  
# FORMATO
#addCircleMarkers(
#  data = impresso,
#  group = "formato",
#  clusterOptions = markerClusterOptions(), label = dados$nome_veiculo, popup = content
#) %>%

  
# %>% saveas("map-edit.html")

