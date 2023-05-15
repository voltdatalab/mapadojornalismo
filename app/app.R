library(leaflet)
library(dplyr)
library(htmlwidgets)
library(shinyWidgets)
library(stringr)

  server <- function(input, output, session){
    
    dados <- reactive({
      
      # main_table <- read.csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vTZkC54Oei0Ab_YUbcayci0IHd3TMj5qKcnYFARoyx5l2hpFZRlO1TEV6diR3HE22gm2QT89z4itj2C/pub?gid=993866458&single=true&output=csv", header = T)
      
      if (input$cobre_cultura == "TRUE") {
      main_table <- main_table %>%
        filter(cobre_cultura == "sim")
      }
      
      if (input$nome != "") {
        main_table <- main_table %>%
          filter(str_detect(nome_veiculo, regex(input$nome, ignore_case = T)))
      }
      
      if (input$areas != "Todos") {
        main_table <- main_table[main_table$principal_cobertura == input$areas,]
      }
      
      if (input$localizacao != "Todas") {
        main_table <- main_table[main_table$localizacao == input$localizacao,]
      }
      
      main_table <- main_table %>%
        filter(formato == input$formato[1] | formato == input$formato[2] | formato == input$formato[3])
      
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
                       <h3>", dados$nome_veiculo, "</h3>", 
                       "<h4 class='subtitle'><strong>Localidade:</strong>", dados$localizacao, "</h4>",
                       "<span>",dados$formato, "</span><br>",
                       "<h4><strong>Segmentos de atuação</strong>:", dados$segmento_de_atuacao, "</h4>",
                       "<h4><strong>Principal cobertura</strong>:", dados$principal_cobertura, "</h4>",
                       "<h4><strong>Cobre Cultura</strong>:", dados$cobre_cultura, "</h4>",
                       if(dados$cobre_cultura == "sim")
                         {paste("<h4><strong>Tipo de cobertura cultural</strong>:", dados$topicos_cultura, "</h4>")},
                       if(dados$qtd_colaboradores != "S/I")
                       {paste("<h4><strong>Tamanho</strong>:", dados$qtd_colaboradores, "</h4>")},
                       "<h4><strong>Modelo de negócios</strong>:", dados$modelo_negocios, "</h4>",
                       "<h4><a href='", dados$link_social, "' target='_blank' style='color:#8368E0;font-weight:700'> &#9758; Saiba mais </a></h4></div>"
      )
      
      initial_lat = -23.65577
      initial_lng = -46.53956
      initial_zoom = 10
      
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
      tags$div(class="explain",tags$p(tags$b("Mapeamento busca veículos de comunicação periféricos em diversas cidades de São Paulo para entender a cobertura local")),
      tags$div(class="filtros_main", 
               switchInput(
                 inputId = "cobre_cultura",
                 label = tags$span( icon("hand-pointer"),"Mudar cobertura"),
                 value = TRUE,
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
      conditionalPanel(condition="input.cobre_cultura=='FALSE'",
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
      width = 650,
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
      column(6,checkboxGroupInput(inputId = "formato",
                                  label = "Segmento",
                                  #multiple = TRUE,
                                  choices = c("Impresso",
                                              "Online",
                                              "Rádio",
                                              "TV"),
                                  selected = c("Impresso",
                                               "Online",
                                               "Rádio",
                                               "TV"),
                                  inline = TRUE
      ))
      ),
      # column(12,
      # # column(4,radioButtons(inputId = "cobre_cultura",
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