library(leaflet)
library(dplyr)
library(htmlwidgets)
library(shinyWidgets)
library(stringr)
library(readr)

options(scipen=999)

  server <- function(input, output, session){
    
    dados <- reactive({
      
      #antiga https://docs.google.com/spreadsheets/d/e/2PACX-1vTZkC54Oei0Ab_YUbcayci0IHd3TMj5qKcnYFARoyx5l2hpFZRlO1TEV6diR3HE22gm2QT89z4itj2C/pub?gid=993866458&single=true&output=csv
      main_table <- read_csv("https://noco.db.enoisconteudo.com.br/api/v1/db/public/shared-view/6770570c-860c-4c7d-b6bf-41130dfecf4e/rows/export/csv", 
                             col_types = cols(Lat = col_number(), 
                                              Long = col_number()))
      
      if (input$cultura == "TRUE") {
      main_table <- main_table %>%
        filter(CobreCultura == "sim")
      }
      
      if (input$nome != "") {
        main_table <- main_table %>%
          filter(str_detect(NomeVeiculo, regex(input$nome, ignore_case = T)))
      }
      
      if (input$areas != "Todos") {
        main_table <- main_table[main_table$PrincipalCobertura == input$areas,]
      }
      
      if (input$cidade != "Todas") {
        main_table <- main_table[main_table$Cidade == input$cidade,]
      }
      
      # main_table <- main_table %>%
      #   filter(Formato == input$formato[1] | Formato == input$formato[2] | Formato == input$formato[3])

      # if (input$raca_responsavel != "Mostrar tudo") {
      #   main_table <- main_table[main_table$raca_responsavel == input$raca_responsavel,]
      # }
      # 
      # # Filtros 
      # if (input$genero_responsavel != "Todos") {
      # main_table <- main_table[main_table$genero_responsavel == input$genero_responsavel,]
      # }
      
      main_table
      
    })
    
    output$n_veiculos <- renderText({
      dados <- dados()
      
      n_veiculos <- dados %>% count()
      
      n_veiculos <- paste(n_veiculos, " veículos selecionados")
      
      n_veiculos
    })
    
    
    output$mapa <-  renderLeaflet({
      
      dados <- dados()
      
      content <- paste("<div class='popup_format'>
                       <h3>", dados$NomeVeiculo, "</h3>", 
                       "<h4 class='subtitle'><strong>Localidade:</strong>", dados$Cidade, "</h4>",
                       "<span>",dados$Formato, "</span><br>",
                       "<h4><strong>Segmentos de atuação</strong>:", dados$SegmentoDeAtuacao, "</h4>",
                       "<h4><strong>Principal cobertura</strong>:", dados$PrincipalCobertura, "</h4>",
                       "<h4><strong>Cobre Cultura</strong>:", dados$CobreCultura, "</h4>",
                       #if(dados$CobreCultura == "sim")
                      #   {paste("<h4><strong>Tipo de cobertura cultural</strong>:", dados$topicos_cultura, "</h4>")},
                       #if(dados$qtd_colaboradores != "S/I")
                       #{paste("<h4><strong>Tamanho</strong>:", dados$qtd_colaboradores, "</h4>")},
                       "<h4><strong>Modelo de negócios</strong>:", dados$ModeloNegocios, "</h4>",
                       "<h4><a href='", dados$LinkSocial, "' target='_blank' style='color:#8368E0;font-weight:700'> &#9758; Saiba mais </a></h4></div>"
      )
      
      initial_lat = -28.65577
      initial_lng = -60.53956
      initial_zoom = 4
      
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
        #addMarkers(clusterOptions = markerClusterOptions())
        addAwesomeMarkers(
          clusterOptions = markerClusterOptions(), label = dados$NomeVeiculo, popup = content, icon=icons
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
      tags$div(class="explain",tags$p(tags$b("Mapeamento busca veículos de comunicação periféricos em diversas cidades de São Paulo para entender a cobertura local")),
      tags$div(class="filtros_main", 
               switchInput(
                 inputId = "cultura",
                 label = tags$span( icon("hand-pointer"),"Mudar cobertura"),
                 value = FALSE,
                 onLabel = "Apenas cultura",
                 offLabel = "Todas as áreas",
                 onStatus = TRUE,
                 offStatus = FALSE,
                 size = "small",
                 labelWidth = "100px",
                 handleWidth = "100px",
                 disabled = FALSE,
                 inline = TRUE,
                 width = "100%"
               )
               
               ),
      tags$p(tags$b(textOutput("n_veiculos"))),
      tags$div(class="filtros_main", radioButtons(inputId = "checkbox", label = "FILTROS DE PESQUISA", choices = c("Mostrar", "Esconder"), inline = TRUE, selected = "Esconder")),
      conditionalPanel(condition="input.CobreCultura=='FALSE'",
      tags$p("Hoje, temos 21 milhões de habitantes nas 40 cidades que compõem São Paulo e Região Metropolitana. Grande parte dessa população é migrante e trouxe consigo hábitos e costumes locais pouco divulgados e valorizados nos territórios. Queremos identificar iniciativas para compreender como as periferias dessas regiões se reconhecem e o que sabem e divulgam sobre a informação e a produção cultural local.")))
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
      width = 550,
      height = "auto",
      tags$h5("FILTROS"),
      column(12, 
             column(6,
                    searchInput(inputId = "nome",
                                label = "Busque por nome",
                                value = "",
                                resetValue = "",
                                btnSearch = icon("search"),
                                btnReset = icon("remove"),
                                placeholder = "Digite aqui")
             ),
             column(6,
                    selectizeInput(inputId = "areas", 
                                   multiple = FALSE,
                                   label = 'Tema principal',
                                   choices  = c('Todos',
                                                'cotidiano',
                                                'cultura',
                                                'educação',
                                                'esporte',
                                                'gênero',
                                                'política',
                                                'proteção animal',
                                                'segurança pública',
                                                'terceira idade'),
                                   selected = 'Todos')
             )
             ),
      column(12,
      column(6,
             selectizeInput(inputId = "cidade", 
                            #multiple = TRUE,
                            label = 'Escolha a cidade',
                            choices  = c('Todas', 
                                         'Abadia de Goiás ',
                                         'Acorizal',
                                         'Alto Alegre',
                                         'Alto Paraguai',
                                         'Ananindeua ',
                                         'Aparecida de Goiânia ',
                                         'Aparecida do Rio Negro',
                                         'Araguaína',
                                         'Araguantins',
                                         'Barra do Bugres',
                                         'Barrolândia',
                                         'Bela Vista de Goiás',
                                         'Belém',
                                         'Benevides',
                                         'Boa Vista',
                                         'Bonfinópolis ',
                                         'Cáceres',
                                         'Campo Grande',
                                         'Candeias do Jamari',
                                         'Cantá',
                                         'Careiro da Várzea',
                                         'Chapada dos Guimarães',
                                         'Cuiabá',
                                         'Distrito Federal',
                                         'Divinópolis do Tocantins',
                                         'Fátima',
                                         'Goânia',
                                         'Goianira',
                                         'Goiás Velho ',
                                         'Guapó ',
                                         'Gurupi',
                                         'Inhumas',
                                         'Iranduba',
                                         'Itacoatiara ',
                                         'Lajeado',
                                         'Macapá',
                                         'Manacapuru',
                                         'Manaus',
                                         'Marituba',
                                         'Mazagão',
                                         'Miracema',
                                         'Miranorte',
                                         'Mucajaí',
                                         'Muricilândia',
                                         'Nerópolis',
                                         'Nobres ',
                                         'Nossa Senhora do Livramento',
                                         'Nova Gama',
                                         'Nova Veneza',
                                         'Novo Airão',
                                         'Pacaraima',
                                         'Palmas',
                                         'Paraíso do Tocantins',
                                         'Paranatinga',
                                         'Porto Espiridião',
                                         'Porto Nacional',
                                         'Porto Velho',
                                         'Presidente Figueiredo',
                                         'Rio Branco',
                                         'Rio Preto da Eva',
                                         'Santa Izabel ',
                                         'Santana',
                                         'Senador Canedo',
                                         'Taipas do Tocantins',
                                         'Tangará da Serra',
                                         'Trindade ',
                                         'Valparaíso de Goiás',
                                         'Várzea Grande',
                                         'Vila Bela da Santíssima Trindade '),
                            selected = "Todas")),
      # column(6,checkboxGroupInput(inputId = "formato",
      #                             label = "Segmento",
      #                             #multiple = TRUE,
      #                             choices = c("Impresso",
      #                                         "Online",
      #                                         "Rádio",
      #                                         "TV"),
      #                             selected = c("Impresso",
      #                                          "Online",
      #                                          "Rádio",
      #                                          "TV"),
      #                             inline = TRUE
      # ))
      ),
      # column(12,
      # # column(4,radioButtons(inputId = "CobreCultura",
      # #                             label = "Cobertura cultura",
      # #                             #multiple = TRUE,
      # #                             choices = c("Mostrar tudo",
      # #                                         "Só cobertura cultural" = "sim"),
      # #                             selected = c("Mostrar tudo"),
      # #                             inline = TRUE
      # # )),
      # column(6,selectizeInput(inputId = "genero_responsavel",
      #                         label = "Gênero",
      #                         #multiple = TRUE,
      #                         choices = c("Todos", 
      #                                     "homem cisgênero",
      #                                     "mulher cisgênero"),
      #                         selected = "Todos"
      # )),
      # column(6,selectizeInput(inputId = "raca_responsavel",
      #                         label = "Raça",
      #                         #multiple = TRUE,
      #                         choices = c("Mostrar tudo",
      #                                     "branca",
      #                                     "indígena",
      #                                     "parda",
      #                                     "preta",
      #                                     "outro"),
      #                         selected = c("Mostrar tudo")
      # ))
      # )
      
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
      height = "auto"
      #tags$img(src="footer2.svg")
    ),
    div(class = "outer", leafletOutput("mapa", height=900)),
    div(class = "baixo", tags$h1("Selecione ao menos um segmento")),
  )
  

shinyApp(ui, server)