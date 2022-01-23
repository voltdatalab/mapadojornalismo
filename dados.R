library(jsonlite)
library(tidyverse)

d <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vThnMdUqiWW3-dvmfNhO4mYYN3gcGjaCL1-sCKSsYgn4cQrUFhlPG1U3vIdPsuBcC1WO0WeUFJDyR3X/pub?gid=2051789888&single=true&output=csv", header = T)

names(d)

d <- d %>% select(latitude, longitude, nome_veiculo, localizacao, formato, segmento_titulo, segmentos, genero, raca, bairro, CEP, link_site, link_social)


d$segmentos <- as.list(d$segmentos)


write_json(d, "teste.json")
