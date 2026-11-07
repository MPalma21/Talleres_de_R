# =============================================================================
# Clase 9 (Parte 2): Introducción a Shiny para Aplicaciones Web Interactivas
# Profesor: Santiago Neira Hernández
# Objetivos:
# - Comprender la arquitectura básica de una aplicación Shiny (UI, Server, App)
# - Crear interfaces de usuario con diferentes tipos de inputs
# - Implementar outputs que respondan automáticamente a los inputs
# - Entender y aplicar el concepto de reactividad (reactive())
# - Integrar en Shiny los htmlwidgets de la Parte 1 (plotly, DT)
# - Desarrollar un dashboard básico con shinydashboard
# - Conocer las opciones para publicar aplicaciones Shiny
#
# NOTA: este script acompaña a 09_Clase_9_1_RMarkdown.R. Allá la
# interactividad la resolvía el navegador (htmlwidgets); aquí R recalcula
# en vivo cada vez que el usuario cambia algo.
# =============================================================================


# =============================================================================
# CONFIGURACIÓN
# =============================================================================

# Si falta algún paquete, corran primero Scripts NEW/00_reinstalar_paquetes.R
# (con la sesión de R recién reiniciada). Ahí ya están todos los de esta clase.
library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(gapminder)
library(plotly)
library(DT)

# Este script no lee ni escribe archivos, así que no necesita setwd().


# =============================================================================
# CONCEPTOS HTML BÁSICOS PARA ENTENDER SHINY
# =============================================================================

# Una página web se escribe en HTML. Shiny genera ese HTML por nosotros,
# pero ayuda conocer la estructura:
#
# <html>
#   <head> <title>Título</title> </head>    # metadatos (título, estilos)
#   <body>                                  # contenido visible
#     <h1>Encabezado</h1>                   # títulos (h1, h2, h3...)
#     <p>Párrafo</p>                        # texto
#     <div>Contenedor</div>                 # divisiones o secciones
#     <input type="text">                   # campos de entrada
#     <button>Botón</button>                # botones
#   </body>
# </html>
#
# EQUIVALENCIAS SHINY -> HTML:
#   titlePanel()   -> <h1>
#   h2(), h3()     -> <h2>, <h3>
#   p()            -> <p>
#   div()          -> <div>
#   textInput()    -> <input type="text">
#   actionButton() -> <button>
#
# CSS controla el estilo (colores, tamaños) y JavaScript la interactividad.
# Shiny se encarga de los tres: nosotros solo escribimos R.


# =============================================================================
# ¿QUÉ ES SHINY?
# =============================================================================

# Shiny permite crear aplicaciones web interactivas usando solo R.
#
# Toda aplicación Shiny tiene tres partes:
#   1. ui:      la interfaz de usuario (lo que se VE)
#   2. server:  la lógica (lo que se CALCULA)
#   3. shinyApp(ui, server): conecta las dos y lanza la app
#
# CUIDADO: mientras una app está corriendo, la consola de R queda OCUPADA
# (aparece "Listening on http://127.0.0.1:..." y un botón rojo de STOP).
# Uno podría pensar que se colgó; no es así, está atendiendo la app.
# Para seguir con el script hay que cerrar la app: botón STOP de la consola
# o tecla Esc. Si no, la siguiente línea que corran no se ejecuta.


# =============================================================================
# EJEMPLO 1: ANATOMÍA BÁSICA
# =============================================================================

# PASO 1: la interfaz de usuario (ui)
ui <- fluidPage(
  titlePanel("Mi Primera Aplicación Shiny"),

  sidebarLayout(
    sidebarPanel(
      h3("Panel de Control"),
      p("Aquí van los controles del usuario:"),
      p("filtros, botones, deslizadores, etc.")
    ),

    mainPanel(
      h2("Panel Principal"),
      p("Aquí van los resultados:"),
      tags$ul(
        tags$li("Gráficos"),
        tags$li("Tablas"),
        tags$li("Análisis")
      )
    )
  )
)

# PASO 2: la lógica del servidor (server)
server <- function(input, output) {
  # Por ahora está vacío: aquí irá la lógica que procesa los datos
}

# PASO 3: crear y ejecutar la aplicación
shinyApp(ui = ui, server = server)


# =============================================================================
# EJEMPLO 2: INPUTS Y OUTPUTS BÁSICOS
# =============================================================================

# La regla de oro de Shiny:
#   - En la ui, cada input tiene un ID:   textInput("nombre", ...)
#   - En el server se lee con:            input$nombre
#   - En la ui, cada output tiene un ID:  textOutput("saludo")
#   - En el server se llena con:          output$saludo <- renderText({ ... })
#
# Cada tipo de output tiene su pareja render*():
#   textOutput()  <-> renderText()       tableOutput() <-> renderTable()
#   plotOutput()  <-> renderPlot()       verbatimTextOutput() <-> renderPrint()

ui <- fluidPage(
  titlePanel("Inputs y Outputs en Shiny"),

  sidebarLayout(
    sidebarPanel(
      h3("Controles"),
      textInput("nombre", "Tu nombre:", value = "Estudiante"),
      numericInput("edad", "Tu edad:", value = 25, min = 1, max = 100),
      selectInput("color", "Color favorito:",
                  choices = c("Azul" = "blue", "Rojo" = "red", "Verde" = "green")),
      sliderInput("numero", "Escoge un número:", min = 1, max = 100, value = 50)
    ),

    mainPanel(
      h3("Resultados"),

      h4("Saludo:"),
      textOutput("saludo"),
      br(),

      h4("Información:"),
      tableOutput("tabla_info"),
      br(),

      h4("Gráfico personalizado:"),
      plotOutput("mi_grafico")
    )
  )
)

server <- function(input, output) {

  # Output 1: texto que cambia según los inputs
  output$saludo <- renderText({
    paste0("Hola ", input$nombre, "! Tienes ", input$edad, " años")
  })

  # Output 2: tabla con la información ingresada
  output$tabla_info <- renderTable({
    data.frame(
      Campo = c("Nombre", "Edad", "Color", "Número"),
      Valor = c(input$nombre, input$edad, input$color, input$numero)
    )
  })

  # Output 3: gráfico de ggplot2 que usa los inputs
  output$mi_grafico <- renderPlot({
    datos <- data.frame(
      x = 1:4,
      y = c(input$numero, input$numero - 10, input$numero + 5, input$numero - 20)
    )

    ggplot(datos, aes(x = x, y = y)) +
      geom_bar(stat = "identity", fill = input$color) +
      labs(title = paste("Gráfico en color", input$color)) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)


# =============================================================================
# CONCEPTO CLAVE: REACTIVIDAD
# =============================================================================

# REACTIVIDAD = actualización automática.
# Cuando cambias un input, Shiny:
#   1. Detecta qué outputs dependen de ese input
#   2. Recalcula SOLO esos outputs
#   3. Actualiza la pantalla
#
#   input$nombre -> renderText()  -> textOutput("saludo")
#   input$color  -> renderPlot()  -> plotOutput("mi_grafico")
#
# En el Ejemplo 2, cambiar el nombre NO vuelve a dibujar el gráfico, porque
# el gráfico no usa input$nombre.
#
# ¿Y si varios outputs necesitan los MISMOS datos filtrados? En vez de repetir
# el filtro en cada render*(), se calcula una sola vez con reactive():
#
#   datos_filtrados <- reactive({ ... filtro ... })
#
# y luego se usa como si fuera una función: datos_filtrados()
# (CUIDADO: con paréntesis. Sin ellos R devuelve la "receta", no los datos.)


# =============================================================================
# EJEMPLO 3: REACTIVIDAD CON DATOS REALES (gapminder)
# =============================================================================

ui <- fluidPage(
  titlePanel("Análisis de Gapminder con Shiny"),

  sidebarLayout(
    sidebarPanel(
      h3("Controles"),

      sliderInput("anio", "Año:",
                  min = 1952, max = 2007, value = 2007, step = 5, sep = ""),

      checkboxGroupInput("continentes", "Continentes:",
                         choices = levels(gapminder$continent),
                         selected = levels(gapminder$continent)),

      numericInput("filas", "Filas a mostrar en la tabla:",
                   value = 10, min = 1, max = 50)
    ),

    mainPanel(
      # Pestañas para organizar el contenido
      tabsetPanel(
        tabPanel("Gráfico", plotOutput("grafico")),
        tabPanel("Datos",   tableOutput("tabla")),
        tabPanel("Resumen", verbatimTextOutput("resumen"))
      )
    )
  )
)

server <- function(input, output) {

  # REACTIVE: el filtro se calcula UNA vez y lo usan los tres outputs
  datos_filtrados <- reactive({
    gapminder %>%
      filter(year == input$anio,
             continent %in% input$continentes)
  })

  output$grafico <- renderPlot({
    ggplot(datos_filtrados(), aes(x = gdpPercap, y = lifeExp,
                                  size = pop, color = continent)) +
      geom_point(alpha = 0.7) +
      scale_x_log10() +
      labs(title = paste("PIB vs Expectativa de Vida -", input$anio),
           x = "PIB per cápita (escala log)", y = "Expectativa de vida",
           color = "Continente", size = "Población") +
      theme_minimal()
  })

  output$tabla <- renderTable({
    datos_filtrados() %>%
      arrange(desc(lifeExp)) %>%
      head(input$filas)
  })

  output$resumen <- renderPrint({
    summary(datos_filtrados())
  })
}

shinyApp(ui = ui, server = server)
# Las tres pestañas usan el mismo
# datos_filtrados(), que solo se recalcula cuando cambia el año o los continentes.
# Cambiar "Filas a mostrar" solo actualiza la tabla: el gráfico no usa input$filas,
# así que Shiny no lo vuelve a dibujar.


# =============================================================================
# EJEMPLO 4: HTMLWIDGETS DENTRO DE SHINY
# =============================================================================

# Los widgets de la Parte 1 (plotly, DT) también funcionan dentro de Shiny.
# Solo cambian las parejas output/render:
#   plotlyOutput()  <-> renderPlotly()
#   DTOutput()      <-> renderDT()
#
# Es la misma app del Ejemplo 3, ahora con gráfico y tabla interactivos,
# y una casilla para agregar la línea de tendencia.

ui_gapminder <- fluidPage(
  titlePanel("Explorador Gapminder Interactivo"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("anio", "Año:",
                  min = 1952, max = 2007, value = 2007, step = 5, sep = ""),

      checkboxGroupInput("continentes", "Continentes:",
                         choices = levels(gapminder$continent),
                         selected = levels(gapminder$continent)),

      checkboxInput("tendencia", "Mostrar línea de tendencia", TRUE),

      hr(),
      h4("Estadísticas del año seleccionado:"),
      verbatimTextOutput("estadisticas")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Gráfico Interactivo", plotlyOutput("grafico", height = "600px")),
        tabPanel("Datos",               DTOutput("tabla"))
      )
    )
  )
)

server_gapminder <- function(input, output) {

  datos_filtrados <- reactive({
    gapminder %>%
      filter(year == input$anio,
             continent %in% input$continentes)
  })

  output$grafico <- renderPlotly({
    datos <- datos_filtrados()

    p <- ggplot(datos, aes(x = gdpPercap, y = lifeExp,
                           text = paste0("País: ", country,
                                         "<br>PIB: ", round(gdpPercap),
                                         "<br>Expectativa: ", round(lifeExp, 1),
                                         "<br>Población: ", scales::comma(pop)))) +
      geom_point(aes(size = pop, color = continent), alpha = 0.7) +
      scale_color_viridis_d() +
      scale_size(range = c(3, 15)) +
      scale_x_log10() +
      labs(x = "PIB per cápita (escala log)",
           y = "Expectativa de vida (años)",
           title = paste("Año:", input$anio)) +
      theme_minimal()

    # Agregar la tendencia solo si la casilla está marcada
    if (input$tendencia && nrow(datos) > 1) {
      p <- p + geom_smooth(aes(x = gdpPercap, y = lifeExp), inherit.aes = FALSE,
                           method = "lm", formula = y ~ x,
                           color = "black", linewidth = 0.8, se = TRUE, alpha = 0.2)
    }

    ggplotly(p, tooltip = "text")
  })

  output$tabla <- renderDT({
    datatable(datos_filtrados(),
              options = list(pageLength = 10, scrollX = TRUE))
  })

  output$estadisticas <- renderText({
    datos <- datos_filtrados()
    if (nrow(datos) > 0) {
      paste0(
        "Países: ", nrow(datos), "\n",
        "PIB promedio: ", round(mean(datos$gdpPercap)), "\n",
        "Expectativa promedio: ", round(mean(datos$lifeExp), 1), "\n",
        "Población total: ", scales::comma(sum(datos$pop))
      )
    } else {
      "No hay datos para los filtros seleccionados"
    }
  })
}

shinyApp(ui = ui_gapminder, server = server_gapminder)

# CUIDADO: geom_smooth() hereda por defecto TODOS los aesthetics del ggplot()
# general, incluido "text" (un texto distinto por país). Uno podría pensar que
# no importa, pero ggplot lo usa para agrupar y la línea de tendencia no se
# dibuja. Con inherit.aes = FALSE le decimos que solo use los aes que le damos.


# =============================================================================
# EJEMPLO 5: DASHBOARD CON SHINYDASHBOARD
# =============================================================================

# shinydashboard da una apariencia más profesional:
#   dashboardPage()    = la página completa
#   dashboardHeader()  = barra superior
#   dashboardSidebar() = menú lateral (con los controles)
#   dashboardBody()    = contenido, organizado en filas (fluidRow) y cajas (box)
#   valueBox()         = las "tarjetas" con un número destacado

ui <- dashboardPage(
  dashboardHeader(title = "Dashboard Gapminder"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Principal", tabName = "principal", icon = icon("house")),
      menuItem("Acerca de", tabName = "acerca",    icon = icon("circle-info"))
    ),

    # Controles globales
    selectInput("continente", "Continente:",
                choices = levels(gapminder$continent), selected = "Americas"),
    sliderInput("anio", "Año:",
                min = 1952, max = 2007, value = 2007, step = 5, sep = "")
  ),

  dashboardBody(
    tabItems(
      tabItem(tabName = "principal",
              fluidRow(
                valueBoxOutput("num_paises"),
                valueBoxOutput("exp_vida"),
                valueBoxOutput("poblacion")
              ),

              fluidRow(
                box(title = "PIB vs Expectativa de vida",
                    status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("grafico_dash")),

                box(title = "Top 5: expectativa de vida",
                    status = "info", solidHeader = TRUE, width = 4,
                    tableOutput("top5"))
              ),

              fluidRow(
                box(title = "Datos", status = "success", solidHeader = TRUE,
                    width = 12, DTOutput("tabla_dash"))
              )
      ),

      tabItem(tabName = "acerca",
              h2("Acerca de este dashboard"),
              p("Datos: paquete gapminder (Jennifer Bryan), basado en Gapminder.org.")
      )
    )
  )
)

server <- function(input, output) {

  datos_dash <- reactive({
    gapminder %>%
      filter(continent == input$continente, year == input$anio)
  })

  # Tarjetas de valores
  output$num_paises <- renderValueBox({
    valueBox(value = nrow(datos_dash()), subtitle = "Países",
             icon = icon("flag"), color = "blue")
  })

  output$exp_vida <- renderValueBox({
    valueBox(value = round(mean(datos_dash()$lifeExp), 1),
             subtitle = "Expectativa de vida promedio",
             icon = icon("heart-pulse"), color = "green")
  })

  output$poblacion <- renderValueBox({
    valueBox(value = paste(round(sum(datos_dash()$pop) / 1e6), "M"),
             subtitle = "Población total",
             icon = icon("users"), color = "yellow")
  })

  # Gráfico interactivo
  output$grafico_dash <- renderPlotly({
    p <- ggplot(datos_dash(), aes(x = gdpPercap, y = lifeExp, text = country)) +
      geom_point(aes(size = pop), color = "steelblue", alpha = 0.7) +
      scale_x_log10() +
      labs(x = "PIB per cápita (escala log)", y = "Expectativa de vida") +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # Top 5 países
  output$top5 <- renderTable({
    datos_dash() %>%
      arrange(desc(lifeExp)) %>%
      head(5) %>%
      select(country, lifeExp)
  })

  # Tabla interactiva
  output$tabla_dash <- renderDT({
    datatable(datos_dash(), options = list(pageLength = 5, scrollX = TRUE))
  })
}

shinyApp(ui = ui, server = server)


# =============================================================================
# OTROS INPUTS ÚTILES
# =============================================================================

# - dateInput():     seleccionar fechas
# - fileInput():     cargar archivos
# - radioButtons():  selección única entre pocas opciones
# - checkboxInput(): una casilla de sí/no (la usamos en el Ejemplo 4)
# - actionButton():  un botón para ejecutar algo solo cuando se presiona.
#                    En el server se usa con observeEvent(input$boton, { ... })


# =============================================================================
# CÓMO PUBLICAR UNA APLICACIÓN SHINY
# =============================================================================

# ESTRUCTURA DE ARCHIVOS: la app se guarda en su propia carpeta, en un archivo
# llamado app.R (con ui, server y shinyApp()), junto con los datos que use.
# En RStudio: File > New Project > New Directory > Shiny Application.

# OPCIÓN 1: shinyapps.io (la más fácil; tiene plan gratuito)
# 1. Crear una cuenta en https://www.shinyapps.io
# 2. install.packages("rsconnect")
# 3. Configurar la cuenta (los datos los da la página):
#    rsconnect::setAccountInfo(name = "tu_usuario",
#                              token = "tu_token",
#                              secret = "tu_secret")
# 4. Publicar desde la carpeta de la app:
#    rsconnect::deployApp()

# OPCIÓN 2: servidor propio (Shiny Server en Linux)

# OPCIÓN 3: compartir el código (por ejemplo en GitHub);
#           otros lo ejecutan con shiny::runGitHub()


# =============================================================================
# RECURSOS
# =============================================================================

# - https://shiny.posit.co/            Página oficial
# - https://shiny.posit.co/r/gallery/  Galería de ejemplos
# - https://mastering-shiny.org/       Libro gratuito (Hadley Wickham)
# - Stack Overflow: etiqueta [shiny]
