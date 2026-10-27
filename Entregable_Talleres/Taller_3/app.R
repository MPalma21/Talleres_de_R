# ==============================================================================
# Aplicativo Shiny Interactivo - Taller 3
# Curso: Taller de Programación en R · 2026-2
# Facultad de Economía – Universidad de los Andes
# Grupo 10: Juan José Echeverry, Miguelangel Palma, Sergio López
#
# Pestaña 1: Datos Geoespaciales - IDF Departamental y Top 3 Municipios
# Pestaña 2: Series Financieras - SOFR, IBR y Devaluación Implícita
# Pestaña 3: Diseño Libre - Dualismo Laboral y Desarrollo Territorial
# ==============================================================================

# Paquetes adicionales identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: shiny (framework de aplicaciones web interactivas en R)
# [PAQUETE ADICIONAL]: bslib (arquitectura moderna de interfaz Bootstrap 5 y tarjetas)
# [PAQUETE ADICIONAL]: leaflet (cartografía web interactiva para polígonos espaciales)
# [PAQUETE ADICIONAL]: plotly (gráficos interactivos con zoom, hover y doble eje)
# [PAQUETE ADICIONAL]: sf (manejo de capas vectoriales Simple Features)
# [PAQUETE ADICIONAL]: scales (formateo de escalas numéricas y monetarias)

library(shiny)
library(bslib)
library(leaflet)
library(plotly)
library(dplyr)
library(sf)
library(readr)
library(scales)

# ------------------------------------------------------------------------------
# 1. Carga de datos pre-procesados
# ------------------------------------------------------------------------------
dir_data <- file.path(getwd(), "data_shiny")
if (!dir.exists(dir_data)) {
  # Fallback si se ejecuta desde la raíz del repo
  dir_data <- file.path(getwd(), "Entregable_Talleres", "Taller_3", "data_shiny")
}

shp_dpto_simp <- readRDS(file.path(dir_data, "shp_dpto_simp.rds"))
df_deptos     <- readRDS(file.path(dir_data, "df_deptos.rds"))
if (!"n_mpios" %in% names(df_deptos) && "n_municipios" %in% names(df_deptos)) {
  df_deptos$n_mpios <- df_deptos$n_municipios
}
if (!"n_mpios" %in% names(shp_dpto_simp) && "n_municipios" %in% names(shp_dpto_simp)) {
  shp_dpto_simp$n_mpios <- shp_dpto_simp$n_municipios
}
df_top3       <- readRDS(file.path(dir_data, "df_top3.rds"))
df_rates      <- readRDS(file.path(dir_data, "df_rates.rds"))
df_labor      <- readRDS(file.path(dir_data, "df_labor.rds"))

# Asegurar orden alfabético de departamentos para selectores
deptos_choices <- df_deptos %>%
  arrange(nom_dpto) %>%
  pull(nom_dpto)

regiones_choices <- sort(unique(df_labor$REGION))

# ------------------------------------------------------------------------------
# 2. Paleta de colores y tema bslib
# ------------------------------------------------------------------------------
tema_app <- bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#1e3d59",
  secondary = "#17b978",
  success = "#2b580c",
  base_font = font_google("Nunito Sans"),
  heading_font = font_google("Montserrat")
)

# ------------------------------------------------------------------------------
# 3. Interfaz de Usuario (UI)
# ------------------------------------------------------------------------------
ui <- page_navbar(
  title = "Taller 3 · Grupo 10 | Visualización Interactiva",
  theme = tema_app,
  fillable = TRUE,
  
  # ----------------------------------------------------------------------------
  # PESTAÑA 1: DATOS GEOESPACIALES (IDF ARTIFICIAL)
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "1. Desempeño Fiscal (IDF)",
    icon = icon("map-location-dot"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Control Territorial",
        width = 320,
        selectInput(
          inputId = "depto_sel",
          label = "Seleccione un Departamento:",
          choices = deptos_choices,
          selected = "Antioquia"
        ),
        hr(),
        card(
          card_header("Definición de Indicadores"),
          p(tags$b("Índice Departamental (Artificial):"), 
            "Media ponderada de los municipios del departamento usando como ponderador ",
            tags$code("w_i = (L_i * VA_i) / Σ(L_k * VA_k)"), 
            ", donde L es población 2024 y VA es valor agregado proyectado 2024."),
          p(tags$b("Índice Municipal:"), 
            "Calificación oficial del Nuevo IDF asignada directamente por el DNP a cada municipio (escala 0 - 100)."),
          class = "text-muted small"
        )
      ),
      
      layout_columns(
        col_widths = c(12),
        layout_columns(
          col_widths = c(4, 4, 4),
          value_box(
            title = "IDF Departamental Artificial",
            value = textOutput("vb_idf_depto"),
            showcase = icon("landmark"),
            theme = "primary"
          ),
          value_box(
            title = "Municipios Evaluados",
            value = textOutput("vb_n_mpios"),
            showcase = icon("city"),
            theme = "info"
          ),
          value_box(
            title = "Municipio Líder en el Dpto.",
            value = textOutput("vb_lider_mpio"),
            showcase = icon("trophy"),
            theme = "success"
          )
        )
      ),
      
      layout_columns(
        col_widths = c(7, 5),
        card(
          full_screen = TRUE,
          card_header("Mapa Departamental del IDF Ponderado"),
          leafletOutput("mapa_leaflet", height = "520px")
        ),
        card(
          card_header("Top 3 Municipios con Mayor IDF Municipal"),
          tableOutput("tabla_top3"),
          tags$small(class = "text-muted",
            "Ponderador w_i representa el peso relativo del municipio en la economía y población del departamento."
          )
        )
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # PESTAÑA 2: SERIES FINANCIERAS Y DEVALUACIÓN IMPLÍCITA
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "2. Tasas y Devaluación",
    icon = icon("chart-line"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Calculadora de Devaluación",
        width = 340,
        dateInput(
          inputId = "fecha_tasa",
          label = "Digite o seleccione una fecha:",
          value = "2024-10-15",
          min = "2020-01-02",
          max = "2025-10-31",
          format = "yyyy-mm-dd",
          language = "es"
        ),
        actionButton("btn_hoy", "Ver última fecha disponible", class = "btn-outline-primary btn-sm mb-3"),
        hr(),
        card(
          card_header("Instrucciones y Convención"),
          p("La calculadora consulta simultáneamente la tasa ", tags$b("IBR Overnight (Colombia)"),
            " y la tasa ", tags$b("SOFR Overnight (EE. UU.)"), " para el día exacto."),
          p("A partir de la condición de paridad, calcula la ", tags$b("Tasa de Devaluación Implícita (π):")),
          tags$div(style = "text-align: center; font-weight: bold; padding: 6px; background: #f8f9fa; border-radius: 4px;",
                   "π = (1 + i_d) / (1 + i_e) - 1"),
          p(class = "mt-2", 
            "Donde ", tags$code("i_d"), " es la IBR ON e ", tags$code("i_e"), 
            " es la SOFR ON, expresadas en términos decimales."),
          class = "text-muted small"
        )
      ),
      
      uiOutput("banner_alerta_fecha"),
      
      layout_columns(
        col_widths = c(4, 4, 4),
        value_box(
          title = "Tasa IBR ON (Colombia)",
          value = textOutput("vb_ibr"),
          showcase = icon("coins"),
          theme = "primary"
        ),
        value_box(
          title = "Tasa SOFR ON (EE. UU.)",
          value = textOutput("vb_sofr"),
          showcase = icon("dollar-sign"),
          theme = "secondary"
        ),
        value_box(
          title = "Devaluación Implícita (π)",
          value = textOutput("vb_pi"),
          showcase = icon("scale-balanced"),
          theme = "success"
        )
      ),
      
      card(
        full_screen = TRUE,
        card_header("Visualización Interactiva de Doble Eje (2020 - 2025)"),
        plotlyOutput("grafico_tasas_plotly", height = "450px")
      )
    )
  ),
  
  # ----------------------------------------------------------------------------
  # PESTAÑA 3: DISEÑO LIBRE - MERCADO LABORAL Y DESARROLLO REGIONAL (PLOTLY)
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "3. Diseño Libre (Plotly)",
    icon = icon("chart-pie"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Controles de Filtrado",
        width = 320,
        checkboxGroupInput(
          inputId = "regiones_sel",
          label = "Filtrar por Región:",
          choices = regiones_choices,
          selected = regiones_choices
        ),
        sliderInput(
          inputId = "ocupados_slider",
          label = "Mínimo de Ocupados (Miles):",
          min = 100,
          max = 4000,
          value = 100,
          step = 100,
          pre = ""
        ),
        hr(),
        card(
          card_header("Autoría y Metodología"),
          p(tags$b("Diseño e Implementación:"), " Grupo 10 (Juan José Echeverry, Miguelangel Palma, Sergio López)."),
          p(tags$b("Fuentes:"), " GEIH 2024 y EMICRON 2024 (DANE). Datos integrados en los Talleres 1 y 2."),
          class = "text-muted small"
        )
      ),
      
      card(
        full_screen = TRUE,
        card_header("Dualismo Territorial: Tasa de Informalidad vs. Ingreso Laboral Mediano"),
        plotlyOutput("grafico_libre_plotly", height = "480px"),
        hr(),
        card_body(
          tags$h5("Explicación Analítica de los Datos (Redacción Grupo 10)"),
          p("Esta visualización analiza la estructura de dualismo territorial en el mercado laboral colombiano a nivel departamental. ",
            "El eje horizontal ilustra la ", tags$b("Tasa de Informalidad Laboral (%)"), ", mientras que el eje vertical presenta la ",
            tags$b("Mediana del Ingreso Laboral (COP)"), " para los ocupados que generan ingresos positivos. ",
            "El tamaño de las burbujas es proporcional a la población ocupada expandida de cada departamento y los colores clasifican las regiones geográficas."),
          p("Se aprecia con claridad una pronunciada relación inversa: los departamentos con menores niveles de informalidad ",
            "(tales como Bogotá D.C. con 34,6% y Antioquia con 48,1%) concentran simultáneamente los mayores ingresos laborales medianos ",
            "(superiores a $1.400.000 COP). Por el contrario, los departamentos de la periferia (como Nariño con 82,6% y Sucre con 82,1%) ",
            "enfrentan una informalidad abrumadora con remuneraciones medianas que apenas rondan los $800.000 a $1.000.000 COP. ",
            "Esta brecha constata cómo la informalidad no es un fenómeno homogéneo, sino el reflejo de profundas asimetrías de productividad regional.")
        )
      )
    )
  )
)

# ------------------------------------------------------------------------------
# 4. Servidor (Server)
# ------------------------------------------------------------------------------
server <- function(input, output, session) {
  
  # ============================================================================
  # LÓGICA PESTAÑA 1: DATOS GEOESPACIALES
  # ============================================================================
  
  # Departamento seleccionado reactivo
  depto_actual <- reactive({
    req(input$depto_sel)
    df_deptos %>% filter(nom_dpto == input$depto_sel)
  })
  
  # Top 3 del departamento seleccionado
  top3_actual <- reactive({
    req(input$depto_sel)
    df_top3 %>% filter(nom_dpto == input$depto_sel)
  })
  
  output$vb_idf_depto <- renderText({
    d <- depto_actual()
    if (nrow(d) == 0) return("N/D")
    sprintf("%.2f pts", d$idf_departamental[1])
  })
  
  output$vb_n_mpios <- renderText({
    d <- depto_actual()
    if (nrow(d) == 0) return("N/D")
    as.character(d$n_mpios[1])
  })
  
  output$vb_lider_mpio <- renderText({
    t3 <- top3_actual()
    if (nrow(t3) == 0) return("N/D")
    paste0(t3$nom_mpio[1], " (", sprintf("%.1f", t3$idf_municipal[1]), ")")
  })
  
  # Tabla Top 3
  output$tabla_top3 <- renderTable({
    t3 <- top3_actual()
    if (nrow(t3) == 0) return(NULL)
    t3 %>%
      transmute(
        `#` = ranking_mpio,
        `Municipio` = nom_mpio,
        `IDF Municipal` = sprintf("%.2f", idf_municipal),
        `Ponderador (w_i)` = sprintf("%.4f (%.2f%%)", w_i, w_i * 100)
      )
  }, striped = TRUE, hover = TRUE, bordered = TRUE, align = "c")
  
  # Mapa Leaflet interactivo
  output$mapa_leaflet <- renderLeaflet({
    pal <- colorNumeric(
      palette = "viridis",
      domain = shp_dpto_simp$idf_departamental,
      na.color = "#cccccc"
    )
    
    leaflet(shp_dpto_simp) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -74.297333, lat = 4.570868, zoom = 5) %>%
      addPolygons(
        layerId = ~nom_dpto,
        fillColor = ~pal(idf_departamental),
        fillOpacity = 0.8,
        color = "white",
        weight = 1.2,
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#ffdd59",
          fillOpacity = 0.95,
          bringToFront = TRUE
        ),
        label = ~paste0(nom_dpto, ": ", round(idf_departamental, 2), " pts"),
        popup = ~paste0(
          "<b>Departamento: </b>", nom_dpto, "<br>",
          "<b>IDF Departamental (Artificial): </b>", round(idf_departamental, 2), " pts<br>",
          "<b>Municipios evaluados: </b>", n_mpios
        )
      ) %>%
      addLegend(
        pal = pal,
        values = ~idf_departamental,
        position = "bottomright",
        title = "IDF Departamental<br>(Artificial)",
        opacity = 0.9
      )
  })
  
  # Interacción: clic en el mapa actualiza el dropdown
  observeEvent(input$mapa_leaflet_shape_click, {
    click_id <- input$mapa_leaflet_shape_click$id
    if (!is.null(click_id) && click_id %in% deptos_choices) {
      updateSelectInput(session, "depto_sel", selected = click_id)
    }
  })
  
  # ============================================================================
  # LÓGICA PESTAÑA 2: SERIES FINANCIERAS Y DEVALUACIÓN IMPLÍCITA
  # ============================================================================
  
  observeEvent(input$btn_hoy, {
    max_fecha <- max(df_rates$fecha, na.rm = TRUE)
    updateDateInput(session, "fecha_tasa", value = max_fecha)
  })
  
  registro_fecha <- reactive({
    req(input$fecha_tasa)
    df_rates %>% filter(fecha == as.Date(input$fecha_tasa))
  })
  
  output$banner_alerta_fecha <- renderUI({
    reg <- registro_fecha()
    if (nrow(reg) == 0 || is.na(reg$sofr_on[1]) || is.na(reg$ibr_on[1])) {
      card(
        class = "bg-warning-subtle text-warning-emphasis border-warning p-3 mb-3",
        tags$b("Aviso de Disponibilidad: "),
        "Para la fecha seleccionada (", format(input$fecha_tasa, "%d/%m/%Y"), 
        ") no se registran cotizaciones activas simultáneas en ambos mercados financieros ",
        "(posible fin de semana o festivo bancario en Colombia o Estados Unidos). ",
        "Por favor elija un día hábil concurrente."
      )
    } else {
      NULL
    }
  })
  
  output$vb_ibr <- renderText({
    reg <- registro_fecha()
    if (nrow(reg) == 0 || is.na(reg$ibr_on[1])) return("No disponible")
    sprintf("%.2f %% E.A.", reg$ibr_on[1])
  })
  
  output$vb_sofr <- renderText({
    reg <- registro_fecha()
    if (nrow(reg) == 0 || is.na(reg$sofr_on[1])) return("No disponible")
    sprintf("%.2f %%", reg$sofr_on[1])
  })
  
  output$vb_pi <- renderText({
    reg <- registro_fecha()
    if (nrow(reg) == 0 || is.na(reg$ibr_on[1]) || is.na(reg$sofr_on[1])) return("No calculable")
    
    # Conversión a decimales
    id <- reg$ibr_on[1] / 100
    ie <- reg$sofr_on[1] / 100
    pi_val <- ((1 + id) / (1 + ie)) - 1
    sprintf("%.2f %%", pi_val * 100)
  })
  
  # Gráfico interactivo doble eje en Plotly
  output$grafico_tasas_plotly <- renderPlotly({
    fig <- plot_ly(df_rates, x = ~fecha) %>%
      add_lines(
        y = ~sofr_on,
        name = "SOFR ON (EE. UU.)",
        line = list(color = "#2ca02c", width = 2),
        yaxis = "y"
      ) %>%
      add_lines(
        y = ~ibr_on,
        name = "IBR ON (Colombia)",
        line = list(color = "#1f77b4", width = 2),
        yaxis = "y2"
      ) %>%
      layout(
        title = list(text = "<b>Trayectoria Diaria de Tasas Overnight (2020 - 2025)</b>"),
        xaxis = list(
          title = "Fecha",
          rangeslider = list(visible = TRUE),
          rangeselector = list(
            buttons = list(
              list(count = 6, label = "6M", step = "month", stepmode = "backward"),
              list(count = 1, label = "1A", step = "year", stepmode = "backward"),
              list(count = 3, label = "3A", step = "year", stepmode = "backward"),
              list(step = "all", label = "Todo")
            )
          )
        ),
        yaxis = list(
          title = "SOFR ON (%) [Eje Izquierdo]",
          titlefont = list(color = "#2ca02c"),
          tickfont = list(color = "#2ca02c"),
          side = "left"
        ),
        yaxis2 = list(
          title = "IBR ON (% E.A.) [Eje Derecho]",
          titlefont = list(color = "#1f77b4"),
          tickfont = list(color = "#1f77b4"),
          overlaying = "y",
          side = "right"
        ),
        legend = list(orientation = "h", x = 0.2, y = 1.15),
        hovermode = "x unified"
      )
    fig
  })
  
  # ============================================================================
  # LÓGICA PESTAÑA 3: DISEÑO LIBRE EN PLOTLY
  # ============================================================================
  
  datos_laboral_filtrados <- reactive({
    req(input$regiones_sel)
    min_ocup <- input$ocupados_slider * 1000
    df_labor %>%
      filter(REGION %in% input$regiones_sel, OCUPADOS_EXP >= min_ocup)
  })
  
  output$grafico_libre_plotly <- renderPlotly({
    df_plot <- datos_laboral_filtrados()
    if (nrow(df_plot) == 0) return(NULL)
    
    fig <- plot_ly(
      data = df_plot,
      x = ~TASA_INFORMALIDAD,
      y = ~INGRESO_MEDIANO,
      type = 'scatter',
      mode = 'markers+text',
      color = ~REGION,
      colors = "Set2",
      size = ~OCUPADOS_EXP,
      sizes = c(15, 65),
      marker = list(sizemode = 'diameter', opacity = 0.8, line = list(width = 1, color = '#333')),
      text = ~NOMBRE_DPTO,
      textposition = 'top right',
      hoverinfo = 'text',
      hovertext = ~paste0(
        "<b>", NOMBRE_DPTO, "</b> (", REGION, ")<br>",
        "• Informalidad: ", sprintf("%.1f%%", TASA_INFORMALIDAD), "<br>",
        "• Ingreso Mediano: $", format(round(INGRESO_MEDIANO), big.mark = "."), " COP<br>",
        "• Ocupados: ", format(round(OCUPADOS_EXP), big.mark = ".")
      )
    ) %>%
      layout(
        title = list(text = "<b>Informalidad Laboral vs. Ingreso Mediano Departamental</b>"),
        xaxis = list(
          title = "Tasa de Informalidad Laboral (%)",
          zeroline = FALSE,
          ticksuffix = "%"
        ),
        yaxis = list(
          title = "Ingreso Laboral Mediano (COP)",
          zeroline = FALSE,
          tickformat = "$,.0f"
        ),
        legend = list(title = list(text = "<b>Región Geográfica</b>")),
        margin = list(l = 60, r = 30, t = 50, b = 50)
      )
    fig
  })
}

# ------------------------------------------------------------------------------
# 5. Ejecución del Aplicativo
# ------------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
