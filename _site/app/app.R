library(leaflet)
library(dplyr)
library(htmlwidgets)
library(shinyWidgets)

  server <- function(input, output, session){
    
    dados <- reactive({
      
      main_table <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vSR47dYcCeZtxIl14urVO7c9dafYWwZUTJ7kxay4ay2lqu92heURX1yxaYHFEgYEqp3kGBxFN4BkNz8/pub?gid=0&single=true&output=csv", header = T)
      
      if (input$cobre_cultura != "Mostrar tudo") {
      main_table <- main_table %>%
        filter(cobre_cultura == input$cobre_cultura[1])
      }
      
      if (input$localizacao != "Todas") {
        main_table <- main_table[main_table$localizacao == input$localizacao,]
      }
      
      if (input$localizacao != "Todas") {
        main_table <- main_table[main_table$localizacao == input$localizacao,]
      }
      
      main_table <- main_table %>%
        filter(formato == input$formato[1] | formato == input$formato[2] | formato == input$formato[3])
      
      if (input$raca != "Mostrar tudo") {
        main_table <- main_table[main_table$raca == input$raca,]
      }
      
      if (input$cobre_periferia != "Mostrar tudo") {
        main_table <- main_table[main_table$cobre_periferia == input$raca,]
      }
      
      # Filtros 
      if (input$genero != "Todos") {
      main_table <- main_table[main_table$genero == input$genero,]
      }
      
      main_table
      
    })
      
    
    output$mapa <-  renderLeaflet({
      
      dados <- dados()
      
      content <- paste("<div class='popup_format'>
                       <h3>", dados$nome_veiculo, "</h3>", 
                       "<h4 class='subtitle'><strong>Localidade:</strong>", dados$localizacao, "</h4>",
                       "<span>",dados$formato, "</span><br>",
                       "<h4><strong>Segmentos de atuação</strong>:", dados$segmentos, "</h4>",
                       "<h4><strong>Principal cobertura</strong>:", dados$principal_cobertura, "</h4>",
                       "<h4><strong>Cobre Cultura</strong>:", dados$cobre_cultura, "</h4>",
                       if(dados$cobre_cultura == "Sim")
                         {paste("<h4><strong>Tipo de cobertura cultural</strong>:", dados$tipicos_cultura, "</h4>")},
                       "<h4><a href='", dados$link_social, "' target='_blank' style='color:#8368E0;font-weight:700'> <i class='fas fa-link'></i> Saiba mais </a></h4></div>"
      )
      
      initial_lat = -23.85577
      initial_lng = -46.53956
      initial_zoom = 9
      
      icons <- awesomeIcons(
        icon = 'newspaper',
        iconColor = '#A2F37C',
        library = 'fa',
        markerColor = "darkpurple"
      )
      
      # elementos do mapa
      mt <- dados %>%
        leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        setView(lat = initial_lat, lng = initial_lng, zoom = initial_zoom) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addAwesomeMarkers(
          clusterOptions = markerClusterOptions(), label = dados$nome_veiculo, popup = content, icon=icons
        )
      
      mt
    })
  }
  
  ui <- fluidPage(
    theme = "custom.css",
    absolutePanel(
      id = "controls-filters",
      class = "panel panel-default intro",
      fixed = TRUE,
      draggable = TRUE,
      top = 0,
      left = 0,
      right = "auto",
      bottom = "auto",
      width = 300,
      height = "auto",
      tags$img(src="logo.svg", class = "logo"),
      tags$div(class="explain",tags$p(tags$b("Mapeamento busca veículos de comunicação periféricos nas 40 cidades de São Paulo para entender a cobertura local")),
      tags$p("Hoje, temos 21 milhões de habitantes nas 40 cidades que compõem São Paulo e Região Metropolitana. Grande parte dessa população é migrante e trouxe consigo hábitos e costumes locais pouco divulgados e valorizados nos territórios. Queremos identificar iniciativas para compreender como as periferias dessas regiões se reconhecem e o que sabem e divulgam sobre a informação e a produção cultural local.")),
      tags$div(class="filtros_main", radioButtons(inputId = "checkbox", label = "FILTROS DE PESQUISA", choices = c("Mostrar", "Esconder"), inline = TRUE, selected = "Esconder"))
    ),
    conditionalPanel(condition="input.checkbox=='Mostrar'",
    tags$div(class = "map-controls",
    absolutePanel(
      id = "controls-filters",
      class = "panel panel-default filtros",
      fixed = TRUE,
      draggable = TRUE,
      #top = 0,
      #left = 300,
      #right = "auto",
      #bottom = "auto",
      width = 850,
      height = "auto",
      tags$h5("FILTROS"),
      column(12,
      column(4,
             selectizeInput(inputId = "localizacao", 
                            #multiple = TRUE,
                            label = 'Escolha a cidade',
                            choices  = c('Todas', 'Arujá',
                                         'Barueri',
                                         'Biritiba Mirim',
                                         'Caieiras',
                                         'Cajamar',
                                         'Carapicuíba',
                                         'Cotia',
                                         'Diadema',
                                         'Embu das Artes',
                                         'Embu-Guaçu',
                                         'Ferraz de Vasconcelos',
                                         'Francisco Morato',
                                         'Franco da Rocha',
                                         'Guararema',
                                         'Guarulhos',
                                         'Itapecerica da Serra',
                                         'Itapevi',
                                         'Itaquaquecetuba',
                                         'Jandira',
                                         'Juquitiba',
                                         'Mairiporã',
                                         'Mauá',
                                         'Mogi das Cruzes',
                                         'Osasco',
                                         'Pirapora do Bom Jesus',
                                         'Poá',
                                         'Ribeirão Pires',
                                         'Rio Grande da Serra',
                                         'Salesópolis',
                                         'Santa Isabel',
                                         'Santana de Parnaíba',
                                         'Santo André',
                                         'São Bernardo do Campo',
                                         'São Caetano do Sul',
                                         'São Lourenço da Serra',
                                         'São Paulo',
                                         'Suzano',
                                         'Taboão da Serra',
                                         'Vargem Grande Paulista'),
                            selected = "Todas")),
      column(4,selectizeInput(inputId = "raca",
                              label = "Raça",
                              #multiple = TRUE,
                              choices = c("Mostrar tudo",
                                          "Amarela",
                                          "Branca",
                                          "Indígena",
                                          "Outro",
                                          "Parda",
                                          "Preta"),
                              selected = c("Mostrar tudo")
      )),
      column(4,selectizeInput(inputId = "genero",
                            label = "Gênero",
                            #multiple = TRUE,
                            choices = c("Todos", 
                                        "Homem cis" = "Homem cisgênero",
                                        "Mulher cis" = "Mulher cisgênero"),
                            selected = "Todos"
      ))),
      column(12,
      column(4,radioButtons(inputId = "cobre_cultura",
                                  label = "Cobertura cultura",
                                  #multiple = TRUE,
                                  choices = c("Mostrar tudo",
                                              "Só cobertura cultural" = "Sim"),
                                  selected = c("Mostrar tudo"),
                                  inline = TRUE
      )),
      column(4,radioButtons(inputId = "cobre_periferia",
                            label = "Cobertura de periferia",
                            #multiple = TRUE,
                            choices = c("Mostrar tudo",
                                        "Cobre periferia" = "Sim"),
                            selected = c("Mostrar tudo"),
                            inline = TRUE
      )),
      column(4,checkboxGroupInput(inputId = "formato",
                                  label = "Segmento",
                                  #multiple = TRUE,
                                  choices = c("Impresso",
                                              "Online",
                                              "Rádio"),
                                  selected = c("Impresso",
                                               "Online",
                                               "Rádio"),
                                  inline = TRUE
      )))
      
    ))
    #fecha conditional panel
    ),
    absolutePanel(
      class = "creditos",
      fixed = TRUE,
      draggable = TRUE,
      top = "auto",
      left = "auto",
      right = 0,
      bottom = 0,
      width = 830,
      height = "auto",
      tags$img(src="footer2.svg")
    ),
    div(class = "outer", leafletOutput("mapa", height=900)),
    div(class = "baixo", tags$h1("Selecione ao menos um segmento")),
  )
  

shinyApp(ui, server)