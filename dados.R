library(jsonlite)
library(tidyverse)

d <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vTZkC54Oei0Ab_YUbcayci0IHd3TMj5qKcnYFARoyx5l2hpFZRlO1TEV6diR3HE22gm2QT89z4itj2C/pub?gid=993866458&single=true&output=csv", header = T)

names(d)

d <- d %>% select(latitude, longitude, nome_veiculo, localizacao, formato, segmento_titulo, segmentos, genero, raca, bairro, CEP, link_site, link_social)


d$segmentos <- as.list(d$segmentos)


write_json(d, "teste.json")
